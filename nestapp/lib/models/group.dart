import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nestapp/models/repeatInterval.dart';
import 'expense.dart';
import 'notice.dart';
import 'member.dart';
import 'reminder.dart';
import 'event.dart';
import '../utils/idGenerator.dart';

class Group {
  static List<Group> groupList = [];
  static Group? currentGroup;

  final String id;
  String name;
  String? desc;
  List<String> memberList;
  List<Expense> expenseList = [];
  List<Notice> noticeList = [];
  List<Reminder> reminderList = [];
  List<Event> eventList = [];

  Group.new({required this.name, this.desc})
      : id = generateID(),
        memberList = List<String>.empty(growable: true) {
    groupList.add(this);
  }

  Group.created({
    required this.id,
    required this.name,
    this.desc,
    required this.memberList,
  }) {
    groupList.add(this);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'memberList': memberList,
      'expenseList': expenseList.map((e) => e.toMap()).toList(),
      'noticeList': noticeList.map((n) => n.toMap()).toList(),
      'reminderList': reminderList.map((r) => r.toMap()).toList(),
      'eventList': eventList.map((e) => e.toMap()).toList(),
    };
  }

  static Group fromMap(Map<String, dynamic> map) {
    return Group.created(
      id: map['id'],
      name: map['name'],
      desc: map['desc'],
      memberList: List<String>.from(map['memberList'] ?? []),
    )
      ..expenseList = (map['expenseList'] as List<dynamic>?)
          ?.map((e) => Expense.fromMap(e))
          .toList() ?? []
      ..noticeList = (map['noticeList'] as List<dynamic>?)
          ?.map((n) => Notice.fromMap(n))
          .toList() ?? []
      ..reminderList = (map['reminderList'] as List<dynamic>?)
          ?.map((r) => Reminder.fromMap(r))
          .toList() ?? []
      ..eventList = (map['eventList'] as List<dynamic>?)
          ?.map((e) => Event.fromMap(e))
          .toList() ?? [];
  }

  Future<void> addGroupToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .set(toMap());
    } catch (e) {
      if (kDebugMode) {
        print('Error adding group to Firestore: $e');
      }
    }
  }

  Future<void> addMember(Member newMember) async {
    try {
      memberList.add(newMember.userUID);
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .update({'memberList': FieldValue.arrayUnion([newMember.userUID])});
    } catch (e) {
      if (kDebugMode) {
        print('Error adding member to Firestore: $e');
      }
    }
  }

  Future<void> removeMember(Member oldMember) async {
    try {
      memberList.remove(oldMember.userUID);
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .update({'memberList': FieldValue.arrayRemove([oldMember.userUID])});
    } catch (e) {
      if (kDebugMode) {
        print('Error removing member from Firestore: $e');
      }
    }
  }

  Future<void> addExpenseToFirestore(Expense expense) async {
    try {
      expenseList.add(expense);
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .update({'expenseList': FieldValue.arrayUnion([expense.toMap()])});
    } catch (e) {
      if (kDebugMode) {
        print('Error adding expense to Firestore: $e');
      }
    }
  }

  Future<void> addNoticeToFirestore(Notice notice) async {
    try {
      noticeList.add(notice);
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .update({'noticeList': FieldValue.arrayUnion([notice.toMap()])});
    } catch (e) {
      if (kDebugMode) {
        print('Error adding notice to Firestore: $e');
      }
    }
  }

  Future<void> addReminder(Reminder reminder) async {
    try {
      reminderList.add(reminder);
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .update({'reminderList': FieldValue.arrayUnion([reminder.toMap()])});
    } catch (e) {
      if (kDebugMode) {
        print('Error adding reminder to Firestore: $e');
      }
    }
  }

  Future<void> removeReminder(Reminder reminder) async {
    try {
      reminderList.removeWhere((r) => r.id == reminder.id);
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(id)
          .update({'reminderList': FieldValue.arrayRemove([reminder.toMap()])});
    } catch (e) {
      if (kDebugMode) {
        print('Error removing reminder from Firestore: $e');
      }
    }
  }

  static Future<Group?> getGroupFromFirestore(String groupId) async {
    try {
      DocumentSnapshot groupDoc = await FirebaseFirestore.instance
          .collection('Groups')
          .doc(groupId)
          .get();
      if (groupDoc.exists) {
        return fromMap(groupDoc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error getting group from Firestore: $e');
      }
    }
    return null;
  }

  static Group? getGroupFromList(String groupId) {
    try {
      return groupList.firstWhere((group) => group.id == groupId);
    } catch (e) {
      return null;
    }
  }

  static Future<List<Group>> getGroupListFromFirestore() async {
    try {
      QuerySnapshot allDocuments = await FirebaseFirestore.instance
          .collection('Groups')
          .get();
      return allDocuments.docs
          .map((doc) {
        return fromMap(doc.data() as Map<String, dynamic>);
      })
          .toList();
    } catch (e) {
      if (kDebugMode) {
        print('Error getting group list from Firestore: $e');
      }
      return [];
    }
  }

  static Future<void> updateGroupListFromFirestore() async {
    try {
      groupList.clear();
      groupList.addAll(await getGroupListFromFirestore());
    } catch (e) {
      if (kDebugMode) {
        print('Error updating group list from Firestore: $e');
      }
    }
  }

  Future<void> refresh() async {
    Group? updatedGroup = await getGroupFromFirestore(id);
    if (updatedGroup != null) {
      expenseList = updatedGroup.expenseList;
      noticeList = updatedGroup.noticeList;
      memberList = updatedGroup.memberList;
      reminderList = updatedGroup.reminderList;
      eventList = updatedGroup.eventList;
      name = updatedGroup.name;
      desc = updatedGroup.desc;
    }
  }

  Future<void> generateEvents() async {
    for (Reminder reminder in reminderList) {
      DateTime currentDate = reminder.firstDate;

      while (currentDate.isBefore(DateTime.now().add(Duration(days: 180)))) {
        if (!eventList.any((e) => e?.reminderId == reminder.id && e.date == currentDate)) {
          eventList.add(Event(
            id: generateID(),
            reminderId: reminder.id,
            date: currentDate,
            assignedUsersUID: [],
            autofinish: reminder.autofinish,
            name: reminder.name,
            desc: reminder.desc ?? '',
          ));
        }

        if (reminder.repeatInterval != null) {
          currentDate = _getNextOccurrence(reminder, currentDate);
        } else {
          break;
        }
      }
    }

    // Marcar eventos autofinish como finalizados
    for (Event event in eventList) {
      if (event.autofinish && event.date.isBefore(DateTime.now())) {
        event.finished = true;
      }
    }

    await addGroupToFirestore();
  }

  DateTime _getNextOccurrence(Reminder reminder, DateTime currentDate) {
    switch (reminder.repeatInterval!.type) {
      case RepeatIntervalType.eachXDays:
        return currentDate.add(Duration(days: reminder.repeatInterval!.dayInterval!));
      case RepeatIntervalType.eachXDayOfTheWeek:
        return _getNextWeekDay(reminder.repeatInterval!.daysOfTheWeek!, currentDate);
      case RepeatIntervalType.eachXDayOfTheMonth:
        return _getNextMonthDay(reminder.repeatInterval!.daysOfTheMonth!, currentDate);
      default:
        return currentDate;
    }
  }

  DateTime _getNextWeekDay(List<bool> daysOfTheWeek, DateTime currentDate) {
    int dayIndex = currentDate.weekday % 7;
    for (int i = 1; i <= 7; i++) {
      if (daysOfTheWeek[(dayIndex + i) % 7]) {
        return currentDate.add(Duration(days: i));
      }
    }
    return currentDate.add(Duration(days: 7)); // Fallback: next week
  }

  DateTime _getNextMonthDay(List<bool> daysOfTheMonth, DateTime currentDate) {
    int dayIndex = currentDate.day - 1;
    for (int i = 1; i <= 31; i++) {
      if (daysOfTheMonth[(dayIndex + i) % 31]) {
        return DateTime(currentDate.year, currentDate.month, (dayIndex + i) % 31 + 1);
      }
    }
    return DateTime(currentDate.year, currentDate.month + 1, 1); // Fallback: next month
  }
}
