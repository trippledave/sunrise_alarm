import 'dart:async';

import 'package:rxdart/rxdart.dart';
import 'package:sunrise_alarm/alarm/alarm.dart';
import 'package:sunrise_alarm/service/alarm_service.dart';

class AlarmBloc {
  final _alarmService = AlarmService();
  final _alarms = BehaviorSubject<List<Alarm>>();
  final _alarmEditedController = StreamController<Alarm>();
  final _alarmRemovalController = StreamController<Alarm>();

  /// This is the input of additions to the cart. Use this to signal
  /// to the component that user is trying to buy a product.
  Sink<Alarm> get alarmEdit => _alarmEditedController.sink;
  Sink<Alarm> get alarmRemoval => _alarmRemovalController.sink;

  AlarmBloc() {
    _alarmService.init().then((List<Alarm> alarms) {
      _alarms.add(alarms);
    });

    _alarmEditedController.stream.listen(_handleEdit);
    _alarmRemovalController.stream.listen(_handleRemoval);
  }

  void _handleEdit(Alarm alarm) {
    alarm.selectedDays.sort();
    _alarmService.update(alarm).then((bool worked) {
      _alarms.add(_alarmService.alarms);
    });
  }

  void _handleRemoval(Alarm alarm) {
    _alarmService.remove(alarm).then((_) {
      _alarms.add(_alarmService.alarms);
    });
  }

  /// This is the stream of alarms. Use this to show the contents
  /// of the alarms in detail
  ValueObservable<List<Alarm>> get alarms => _alarms.stream;

  /// Take care of closing streams.
  void dispose() {
    _alarms.close();
    _alarmEditedController.close();
    _alarmRemovalController.close();
  }
}
