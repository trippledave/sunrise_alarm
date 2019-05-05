// This sample shows adding an action to an [AppBar] that opens a shopping cart.

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:sunrise_alarm/alarm/alarm_bloc.dart';
import 'package:sunrise_alarm/alarm/alarm_provider.dart';
import 'package:sunrise_alarm/i18n.dart';
import 'package:sunrise_alarm/ui/home_page.dart';

class AlarmApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return AlarmProvider(
      alarmBloc: AlarmBloc(),
      child: MaterialApp(
        localizationsDelegates: [
          const AppTranslationsDelegate(),
          //provides localised strings
          GlobalMaterialLocalizations.delegate,
        ],
        supportedLocales: AppTranslationsDelegate.supportedLocales,
        onGenerateTitle: (context) => AppTranslations.of(context).text("title"),
        theme: ThemeData(primarySwatch: Colors.teal),
        home: HomePage(),
      ),
    );
  }
}

void main() => runApp(AlarmApp());
