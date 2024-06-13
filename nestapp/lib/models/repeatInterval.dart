enum RepeatIntervalType {
  eachXDays,
  eachXDayOfTheWeek,
  eachXDayOfTheMonth,
}

class RepeatInterval {
  RepeatIntervalType type;
  int? dayInterval;
  List<bool>? daysOfTheWeek; // 7 booleanos
  List<bool>? daysOfTheMonth; // 31 booleanos

  RepeatInterval({
    required this.type,
    this.dayInterval,
    this.daysOfTheWeek,
    this.daysOfTheMonth,
  });

  Map<String, dynamic> toMap() {
    return {
      'type': type.toString().split('.').last,
      'dayInterval': dayInterval,
      'daysOfTheWeek': daysOfTheWeek,
      'daysOfTheMonth': daysOfTheMonth,
    };
  }

  static RepeatInterval fromMap(Map<String, dynamic> map) {
    RepeatIntervalType type = RepeatIntervalType.values.firstWhere((e) => e.toString() == 'RepeatIntervalType.${map['type']}');
    return RepeatInterval(
      type: type,
      dayInterval: map['dayInterval'],
      daysOfTheWeek: List<bool>.from(map['daysOfTheWeek'] ?? []),
      daysOfTheMonth: List<bool>.from(map['daysOfTheMonth'] ?? []),
    );
  }
}
