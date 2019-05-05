import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:sunrise_alarm/alarm/alarm.dart';
import 'package:sunrise_alarm/service/background_service.dart';

//persists the alarms and schedules them
class AlarmService {
  //persist the alarms
  final List<Alarm> _alarms = <Alarm>[];

  List<Alarm> get alarms => _alarms;

  Future<bool> update(Alarm alarm) async {
    if (alarm.id == null) {
      alarm.id = _getNewAlarmId();
      _alarms.add(alarm);
    }

    debugPrint("update ALARM: " + json.encode(alarm.toJson()));
    BackgroundService.scheduleAlarm(alarm);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.setString(alarm.id.toString(), json.encode(alarm.toJson()));
  }

  Future<bool> remove(Alarm alarm) async {
    _alarms.remove(alarm);
    BackgroundService.unscheduleAlarm(alarm.id);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.remove(alarm.id.toString());
  }

  //returns null Future, it is possible to wait for this function
  Future<List<Alarm>> init() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    void getAlarmForKey(String key) {
      //prefs.remove(key);
      final alarmJsonString = prefs.getString(key);
      final Alarm alarm = Alarm.fromJson(json.decode(alarmJsonString));
      _alarms.add(alarm);
    }

    prefs.getKeys().forEach((String key) => getAlarmForKey(key));
    return _alarms;
  }

  int _getNewAlarmId() {
    //use the existing alarms to find the lowest empty id
    final List<int> alarmIds =
        _alarms.map((Alarm alarm) => alarm.id).toList(growable: false);

    int i = 0;
    while (alarmIds.contains(i)) {
      i++;
    }
    return i;
  }
}
