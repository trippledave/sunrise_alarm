import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_alarm/alarm/alarm.dart';
import 'package:sunrise_alarm/alarm/alarm_provider.dart';
import 'package:sunrise_alarm/i18n.dart';
import 'package:sunrise_alarm/service/background_service.dart';
import 'package:sunrise_alarm/service/time_service.dart';
import 'package:sunrise_alarm/ui/home_page.dart';

class CreateAlarmState extends State<CreateAlarmPage> {
  final Alarm _alarm;
  DateTime sunriseDateTime;

  CreateAlarmState(this._alarm);

  @override
  Widget build(BuildContext context) {
    final alarmBloc = AlarmProvider.of(context);

    return Scaffold(
        appBar: AppBar(
            title: Text(
          AppTranslations.of(context).text('create_alarm'),
        )),
        body: Form(
          child: ListView(
            padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
            children: <Widget>[
              Text(
                AppTranslations.of(context).text('alarm_time'),
                style: Theme.of(context).textTheme.subhead,
              ),
              FutureBuilder<CreateAlarmDateTimesModel>(
                future:
                    TimeService.getNextAlarmDateTime(sunriseDateTime, _alarm),
                builder: (BuildContext context,
                    AsyncSnapshot<CreateAlarmDateTimesModel> snapshot) {
                  if (snapshot.hasData) {
                    sunriseDateTime = snapshot.data.sunriseDateTime;
                    _alarm.nextAlarm = sunriseDateTime;

                    return Text(
                      DateFormat.jm(Localizations.localeOf(context).toString())
                          .format(
                              snapshot.data.calculatedAlarmDateTime.toLocal()),
                      style: Theme.of(context).textTheme.display1,
                    );
                  } else if (snapshot.hasError) {
                    return Text(
                        AppTranslations.of(context).text('error_connection'),
                        style: TextStyle(color: Colors.red));
                  }
                  // By default, show a loading spinner
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: CircularProgressIndicator(),
                  );
                },
              ),
              Text(
                AppTranslations.of(context).text("offset"),
                style: Theme.of(context).textTheme.subhead,
              ),
              Row(
                children: <Widget>[
                  Expanded(
                    child: Slider(
                      value: _alarm.offset.toDouble(),
                      min: -10.0,
                      max: 10.0,
                      onChanged: (double value) {
                        setState(() {
                          _alarm.offset = value.round();
                        });
                      },
                    ),
                  ),
                  Semantics(
                    child: Container(
                      width: 48,
                      height: 48,
                      child: TextField(
                        onSubmitted: (String value) {
                          final double newValue = double.tryParse(value);
                          if (newValue != null && newValue != _alarm.offset) {
                            setState(() {
                              _alarm.offset = newValue.clamp(0, 100);
                            });
                          }
                        },
                        keyboardType: TextInputType.number,
                        controller: TextEditingController(
                          text: _alarm.offset.toStringAsFixed(0),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              Text(
                AppTranslations.of(context).text("selectedDays"),
                style: Theme.of(context).textTheme.subhead,
              ),
              WeekDaySelector(_alarm),
              Builder(builder: (BuildContext context) {
                //Builder needed to get Scaffold for SnackBar
                return RaisedButton(
                  onPressed: () {
                    if (sunriseDateTime != null) {
                      //if sunrise could not be loaded then alarm can not be saved
                      alarmBloc.alarmEdit.add(_alarm);
                      Navigator.of(context).pop(context);
                    } else {
                      Scaffold.of(context).showSnackBar(SnackBar(
                          content: Text(AppTranslations.of(context)
                              .text('save_no_internet')))); //
                    }
                  },
                  child: Text(AppTranslations.of(context).text("save")),
                  color: Theme.of(context).buttonTheme.colorScheme.primary,
                  textColor: Colors.white,
                );
              }),
            ],
          ),
        ));
  }
}

class WeekDaySelector extends StatefulWidget {
  final Alarm _alarm;

  WeekDaySelector(this._alarm);

  @override
  State<StatefulWidget> createState() => WeekDayState(_alarm);
}

class WeekDayState extends State<WeekDaySelector> {
  final Alarm _alarm;

  WeekDayState(this._alarm);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter =
        DateFormat.EEEE(Localizations.localeOf(context).toString());

    List<Widget> filterChips(final List<int> dayValues) {
      return dayValues.map<Widget>((int dayValue) {
        return Container(
          child: FilterChip(
            key: ValueKey<int>(dayValue),
            label: Text(TimeService.getWeekDayString(dayValue, formatter)),
            selected: _alarm.selectedDays.contains(dayValue),
            onSelected: (bool value) {
              setState(() {
                if (value) {
                  _alarm.selectedDays.add(dayValue);
                } else {
                  _alarm.selectedDays.remove(dayValue);
                }
              });
            },
          ),
          padding: EdgeInsets.symmetric(horizontal: 5),
        );
      }).toList();
    }

    return Column(children: [
      Row(children: filterChips([1, 2, 3])),
      Row(children: filterChips([4, 5])),
      Row(children: filterChips([6, 7])),
    ]);
  }
}

class CreateAlarmPage extends StatefulWidget {
  final Alarm alarm;

  CreateAlarmPage({Key key, @required this.alarm}) : super(key: key);

  @override
  State<StatefulWidget> createState() => CreateAlarmState(alarm);
}
