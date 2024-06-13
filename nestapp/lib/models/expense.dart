import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:nestapp/models/member.dart';

import 'group.dart';

class Expense {
  final String id;
  final String expenseName;
  final double amount;
  final String payerUID;
  final List<String> sharedWithUIDs;

  Expense({
    required this.id,
    required this.expenseName,
    required this.amount,
    required this.payerUID,
    required this.sharedWithUIDs,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expenseName': expenseName,
      'amount': amount,
      'payerUID': payerUID,
      'sharedWithUIDs': sharedWithUIDs,
    };
  }

  static Expense fromMap(Map<String, dynamic> map) {
    return Expense(
      id: map['id'],
      expenseName: map['expenseName'],
      amount: map['amount'],
      payerUID: map['payerUID'],
      sharedWithUIDs: List<String>.from(map['sharedWithUIDs']),
    );
  }

  Future<void> addExpenseToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Groups')
          .doc(Group.currentGroup?.id)
          .update({
        'expenseList': FieldValue.arrayUnion([toMap()])
      });
    } catch (e) {
      if (kDebugMode) {
        print('Error adding expense to Firestore: $e');
      }
    }
  }
}
