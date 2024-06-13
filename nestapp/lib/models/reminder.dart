import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:nestapp/models/repeatInterval.dart';
import 'event.dart';

class Reminder {
  String id;
  String name;
  String? desc;
  String groupID;
  bool autofinish;
  bool repeat;
  RepeatInterval? repeatInterval;
  DateTime firstDate;

  Reminder({
    required this.id,
    required this.name,
    this.desc,
    required this.groupID,
    required this.autofinish,
    required this.repeat,
    this.repeatInterval,
    required this.firstDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'groupID': groupID,
      'autofinish': autofinish,
      'repeat': repeat,
      'repeatInterval': repeat ? repeatInterval?.toMap() : null,
      'firstDate': firstDate.toIso8601String(),
    };
  }

  static Reminder fromMap(Map<String, dynamic> map) {
    return Reminder(
      id: map['id'],
      name: map['name'],
      desc: map['desc'],
      groupID: map['groupID'],
      autofinish: map['autofinish'],
      repeat: map['repeat'],
      repeatInterval: map['repeat'] ? RepeatInterval.fromMap(map['repeatInterval']) : null,
      firstDate: DateTime.parse(map['firstDate']),
    );
  }
}
