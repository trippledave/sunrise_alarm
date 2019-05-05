import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_alarm/alarm/alarm.dart';
import 'package:sunrise_alarm/alarm/alarm_provider.dart';
import 'package:sunrise_alarm/i18n.dart';
import 'package:sunrise_alarm/service/time_service.dart';
import 'package:sunrise_alarm/ui/aboutDialog.dart';
import 'package:sunrise_alarm/ui/create_alarm_page.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final alarmBloc = AlarmProvider.of(context);

    return Scaffold(
      body: CustomScrollView(
        slivers: <Widget>[
          SliverAppBar(
            floating: true,
            title: Text(AppTranslations.of(context).text('title')),
            actions: <Widget>[
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'Toolbar menu') {
                    showGalleryAboutDialog(context);
                  }
                },
                itemBuilder: (BuildContext context) => <PopupMenuItem<String>>[
                      PopupMenuItem<String>(
                        value: 'Toolbar menu',
                        child: Text(AppTranslations.of(context).text('about')),
                      ),
                    ],
              ),
            ],
          ),
          StreamBuilder<List<Alarm>>(
              stream: alarmBloc.alarms,
              builder: (BuildContext context, AsyncSnapshot snapshot) {
                if (snapshot.data?.isEmpty ?? true) {
                  return SliverList(
                    delegate: SliverChildListDelegate(
                      [
                        Container(
                          child: Text(
                            AppTranslations.of(context).text('no_alarms_info'),
                            style: Theme.of(context).textTheme.display1,
                          ),
                          padding: EdgeInsets.symmetric(horizontal: 10),
                        )
                      ],
                    ),
                  );
                } else {
                  return SliverList(
                      delegate: SliverChildListDelegate(snapshot.data
                          .map<Widget>((Alarm x) => AlarmLine(x, context))
                          .toList()));
                }
              }),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            CupertinoPageRoute(
              builder: (context) => CreateAlarmPage(alarm: Alarm()),
            ),
          );
        },
        //tooltip: AppTranslations.of(context).text('create_alarm'),
        child: Icon(Icons.add),
      ),
    );
  }
}

class AlarmLine extends Dismissible {
  AlarmLine(Alarm alarm, BuildContext context)
      : super(
          // Each Dismissible must contain a Key. Keys allow Flutter to
          // uniquely identify Widgets.
          key: ValueKey<Alarm>(alarm),
          child: Container(
            child: Row(
              children: <Widget>[
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      CupertinoPageRoute(
                        builder: (context) => CreateAlarmPage(alarm: alarm),
                      ),
                    );
                  },
                  child: Text(
                    DateFormat.jm(Localizations.localeOf(context).toString())
                        // .format(alarm.nextAlarm.toLocal()),
                        .format(
                            alarm.nextAlarm.add(Duration(hours: alarm.offset)).toLocal()),
                    style: Theme.of(context).textTheme.display1,
                  ),
                ),
                Expanded(
                  child: ActiveWeekDaysText(alarm),
                ),
                Switch(
                    value: alarm.active,
                    onChanged: (bool value) {
                      alarm.active = value;
                      final alarmBloc = AlarmProvider.of(context);
                      alarmBloc.alarmEdit.add(alarm);
                    }),
              ],
            ),
            padding: EdgeInsets.all(10),
          ),
          // We also need to provide a function that tells our app
          // what to do after an item has been swiped away.
          onDismissed: (direction) {
            // Remove the item from our data source.
            AlarmProvider.of(context).alarmRemoval.add(alarm);
            // Then show a snackbar!
            Scaffold.of(context).showSnackBar(SnackBar(
                content: Text(
                    AppTranslations.of(context).text('alarm_removed')))); //
          },
          // Show a red background as the item is swiped away
          background: Container(
            alignment: AlignmentDirectional.centerEnd,
            color: Colors.red,
            child: Padding(
              padding: EdgeInsets.fromLTRB(0.0, 0.0, 10.0, 0.0),
              child: Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
          ),
        );
}

//Text that displays the active days like: Mo Di Mi
class ActiveWeekDaysText extends StatelessWidget {
  final Alarm _alarm;

  ActiveWeekDaysText(this._alarm);

  @override
  Widget build(BuildContext context) {
    final DateFormat formatter =
        DateFormat.E(Localizations.localeOf(context).toString());
    final String daysJoined = _alarm.selectedDays
        .map<String>(
            (intVal) => TimeService.getWeekDayString(intVal, formatter))
        .join(" ")
        .toString();

    return Text(
      daysJoined,
      textAlign: TextAlign.center,
    );
  }
}
