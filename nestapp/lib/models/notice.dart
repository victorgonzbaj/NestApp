import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

import 'group.dart';
import 'member.dart';

class Notice {
  final String id;
  final String authorUID;
  final DateTime date;
  final List<String> involvedUIDs;
  final String actionType;
  final String message;

  Notice({
    required this.id,
    required this.authorUID,
    required this.date,
    required this.involvedUIDs,
    required this.actionType,
    required this.message,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'authorUID': authorUID,
      'date': date.toIso8601String(),
      'involvedUIDs': involvedUIDs,
      'actionType': actionType,
      'message': message,
    };
  }

  static Notice fromMap(Map<String, dynamic> map) {
    return Notice(
      id: map['id'],
      authorUID: map['authorUID'],
      date: DateTime.parse(map['date']),
      involvedUIDs: List<String>.from(map['involvedUIDs']),
      actionType: map['actionType'],
      message: map['message'],
    );
  }

  Future<void> addNoticeToFirestore({bool isGroupNotice = true}) async {
    try {
      if (isGroupNotice) {
        await FirebaseFirestore.instance
            .collection('Groups')
            .doc(Group.currentGroup?.id)
            .update({
          'noticeList': FieldValue.arrayUnion([toMap()])
        });
      } else {
        await FirebaseFirestore.instance
            .collection('Members')
            .doc(Member.currentMember?.userUID)
            .update({
          'noticeList': FieldValue.arrayUnion([toMap()])
        });
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error adding notice to Firestore: $e');
      }
    }
  }
}
