class Alarm {
  int id;
  int offset = 0;
  List<int> selectedDays = new List();
  bool active = true;
  DateTime nextAlarm;
  DateTime sunrise;

  Alarm();

  @override
  String toString() {
    return 'Alarm: $id + $selectedDays + $active + $nextAlarm';
  }

  Alarm.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        offset = json['offset'],
        selectedDays = json['selectedDays'].cast<int>(),
        active = json['active'],
        nextAlarm = DateTime.parse(json['nextAlarm']);

  Map<String, dynamic> toJson() => {
        'id': id,
        'offset': offset,
        'selectedDays': selectedDays,
        'active': active,
        'nextAlarm': nextAlarm.toIso8601String(),
      };
}
