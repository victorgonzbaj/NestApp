import 'package:cloud_firestore/cloud_firestore.dart';

class Event {
  final String id;
  final String reminderId;
  final DateTime date;
  final List<String> assignedUsersUID;
  late final bool autofinish;
  final String name;
  final String desc;
  bool finished;

  Event({
    required this.id,
    required this.reminderId,
    required this.date,
    required this.assignedUsersUID,
    required this.autofinish,
    required this.name,
    required this.desc,
    this.finished = false,
  });

  // Método para convertir Event a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'reminderId': reminderId,
      'date': date.toIso8601String(),
      'assignedUsersUID': assignedUsersUID,
      'autofinish': autofinish,
      'name': name,
      'desc': desc,
      'finished': finished,
    };
  }

  // Método para crear Event desde un Map<String, dynamic>
  static Event fromMap(Map<String, dynamic> map) {
    return Event(
      id: map['id'],
      reminderId: map['reminderId'],
      date: DateTime.parse(map['date']),
      assignedUsersUID: List<String>.from(map['assignedUsersUID']),
      autofinish: map['autofinish'] ?? false,
      name: map['name'],
      desc: map['desc'],
      finished: map['finished'] ?? false,
    );
  }
}
