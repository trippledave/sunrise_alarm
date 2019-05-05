import 'dart:io';
import 'dart:isolate';
import 'dart:ui';

import 'package:android_alarm_manager/android_alarm_manager.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:sunrise_alarm/alarm/alarm.dart';
import 'package:sunrise_alarm/service/alarm_service.dart';
import 'package:android_intent/android_intent.dart';

DebugPrintCallback debugPrint = debugPrintThrottled;

class BackgroundService {
  //TODO maybe schedule Alarm in android with broadcast handler that can show message
  static Future onAlarm() async {
    debugPrint("onAlarm");
    if (Platform.isAndroid) {
      final DateTime now = DateTime.now().toLocal().add(Duration(minutes: 1));
      AndroidIntent setAlarm = AndroidIntent(
        action: "android.intent.action.SET_ALARM",
        //https://developer.android.com/reference/android/provider/AlarmClock.html
        arguments: {
          "android.intent.extra.alarm.MESSAGE": "Sonnenaufgangswecker",
          "android.intent.extra.alarm.HOUR": now.hour,
          "android.intent.extra.alarm.MINUTES": now.minute,
          "android.intent.extra.alarm.SKIP_UI": true
        },
      );
      await setAlarm.launch();
    }

    //cant access id of alarm so this is pretty messy
    //just reschedule all alarms
    AlarmService alarmService = AlarmService();
    alarmService.init().then((List<Alarm> alarms) {
      alarms.forEach((Alarm alarm) => scheduleAlarm(alarm));
    });
  }

  static Future<Null> scheduleAlarm(Alarm alarm) async {
    if (alarm.active && alarm.selectedDays.isNotEmpty) {
      //when should alarm run next time?
      DateTime nextRun;
      final DateTime now = DateTime.now().toUtc();

      DateTime currentAlarm = DateTime.utc(now.year, now.month, now.day,
          alarm.nextAlarm.hour, alarm.nextAlarm.minute);
      currentAlarm = currentAlarm.add(Duration(hours: alarm.offset));

      //alarm some day in future
      for (int i = -1; i < 7; i++) {
        //since monday = 1, with +1 at currentWeekDay, we get the right day
        //alarm has to be somewhere in the next 8 days //today twice, since alarm may have already started today
        //find the next day in selectedDays
        final int currentWeekDay = ((now.weekday + i) % 7) + 1;
        if (alarm.selectedDays.contains(currentWeekDay)) {
          //if the current day is selected, then check if alarm already started today
          if (now.day == currentAlarm.day && now.isAfter(currentAlarm)) {
            currentAlarm = currentAlarm.add(Duration(days: 1));
          } else {
            nextRun = currentAlarm;
            break;
          }
        } else {
          currentAlarm = currentAlarm.add(Duration(days: 1));
        }
      }

      if (nextRun != null) {
        debugPrint("Scheduling alarm with id: ${alarm.id} at: $nextRun");

        await AndroidAlarmManager.initialize();
        await DelayedSchedulingAlarmManager.oneShotAt(
            //TODO use updated time from internet
            //DateTime.now().add(Duration(seconds: 10)),
            nextRun,
            alarm.id,
            onAlarm,
            exact: true,
            rescheduleOnReboot: false, //not working with api v24
            wakeup: true);
      }
    } else {
      unscheduleAlarm(alarm.id);
    }
  }

  static void unscheduleAlarm(int id) async {
    await AndroidAlarmManager.initialize();
    AndroidAlarmManager.cancel(id);
  }
}

// since current AndroidAlarmManager does not permit scheduling with variable first run, we do our own
class DelayedSchedulingAlarmManager extends AndroidAlarmManager {
  static const String _channelName = 'plugins.flutter.io/android_alarm_manager';
  static const MethodChannel _channel =
      MethodChannel(_channelName, JSONMethodCodec());

  static Future<bool> periodicWithDelay(
    Duration duration,
    DateTime first,
    int id,
    dynamic Function() callback, {
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) async {
    final int period = duration.inMilliseconds;
    final CallbackHandle handle = PluginUtilities.getCallbackHandle(callback);
    if (handle == null) {
      return false;
    }
    final bool r =
        await _channel.invokeMethod<bool>('Alarm.periodic', <dynamic>[
      id,
      exact,
      wakeup,
      first.millisecondsSinceEpoch,
      period,
      rescheduleOnReboot,
      handle.toRawHandle()
    ]);
    return (r == null) ? false : r;
  }

  static Future<bool> oneShotAt(
    DateTime at,
    int id,
    dynamic Function() callback, {
    bool exact = false,
    bool wakeup = false,
    bool rescheduleOnReboot = false,
  }) async {
    final CallbackHandle handle = PluginUtilities.getCallbackHandle(callback);
    if (handle == null) {
      return false;
    }
    final bool r = await _channel.invokeMethod<bool>('Alarm.oneShot', <dynamic>[
      id,
      exact,
      wakeup,
      at.millisecondsSinceEpoch,
      rescheduleOnReboot,
      handle.toRawHandle(),
    ]);
    return (r == null) ? false : r;
  }
}
