import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:sunrise_alarm/alarm/alarm.dart';
import 'package:sunrise_alarm/service/background_service.dart';
import 'package:sunrise_alarm/service/location_service.dart';

class TimeService {
  //weekDay uses DateTimes weekday constants (1 = monday) to retzrb Strubg
  static String getWeekDayString(int weekDay, DateFormat formatter) {
    //so the 21 is easter sunday + 1 for monday equals easter monday
    var calculatedDay = DateTime(2019, 4, 21).add(Duration(days: weekDay));
    return formatter.format(calculatedDay);
  }

  static List<int> getWeeksValues() {
    return [
      DateTime.monday,
      DateTime.tuesday,
      DateTime.wednesday,
      DateTime.thursday,
      DateTime.friday,
      DateTime.saturday,
      DateTime.sunday,
    ];
  }

  static Future<DateTime> _retrieveNextSunriseTime(Position position) async {
    final String url =
        'https://api.sunrise-sunset.org/json?lat=${position.latitude}&lng=${position.longitude}&formatted=0';

    debugPrint("URL: $url");
    final Response response = await http.get(url);

    if (response != null && response.statusCode == 200) {
      // If the call to the server was successful, parse the JSON
      _SunriseApiJSON sunriseJSON =
          _SunriseApiJSON.fromJson(json.decode(response.body));
      return DateTime.parse(sunriseJSON.sunrise);
    } else {
      // If that call was not successful, throw an error.
      throw Exception('Failed to load post');
    }
  }

  static Future<CreateAlarmDateTimesModel> getNextAlarmDateTime(
      DateTime currentSunrise, Alarm alarm) async {
    //currentSunrise is cached so that it does not have to be retrieved on every change
    Future<DateTime> sunriseFuture;

    if (currentSunrise == null) {
      //TODO let user choose location
//      await LocationService.getLocation().then((Position position) {
//        sunriseFuture = TimeService._retrieveNextSunriseTime(position);
//      }).catchError((_) {
//        sunriseFuture = TimeService._retrieveNextSunriseTime(new Position(
//            latitude: 48.8797799, longitude: 8.9653794)); //Mannheim, Germany
//      });
//

      sunriseFuture = TimeService._retrieveNextSunriseTime(new Position(
          48.8797799, 8.9653794)); //Mannheim, Germany

      await sunriseFuture.then((DateTime nextAlarm) {
        currentSunrise = nextAlarm;
      });


    }
    final DateTime calculatedAlarmDateTime =
        currentSunrise.add(Duration(hours: alarm.offset));

    return CreateAlarmDateTimesModel(currentSunrise, calculatedAlarmDateTime);
  }
}

class Position {
  var latitude;
  var longitude;
  Position(this.latitude,this.longitude);
}

class _SunriseApiJSON {
  Map<String, dynamic> _results;
  String _status;

  _SunriseApiJSON.fromJson(Map<String, dynamic> json)
      : _results = json['results'],
        _status = json['status'];

  String get sunrise => _results['sunrise'];

  String get status => _status;
}

class CreateAlarmDateTimesModel {
  final DateTime sunriseDateTime;
  final DateTime calculatedAlarmDateTime;

  CreateAlarmDateTimesModel(this.sunriseDateTime, this.calculatedAlarmDateTime);
}
