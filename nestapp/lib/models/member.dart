import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'expense.dart';
import 'notice.dart';

class Member {
  static List<Member> memberList = List.empty(growable: true);
  static Member? currentMember;

  final String userUID;
  String? groupID;
  String name;
  String email;
  List<Expense> expenseList = [];
  List<Notice> noticeList = [];

  // Constructor
  Member({
    required this.userUID,
    required this.name,
    required this.email,
    this.groupID,
  });

  // Método para convertir Member a Map<String, dynamic>
  Map<String, dynamic> toMap() {
    return {
      'userUID': userUID,
      'groupID': groupID,
      'name': name,
      'email': email,
      'expenseList': expenseList.map((expense) => expense.toMap()).toList(),
      'noticeList': noticeList.map((notice) => notice.toMap()).toList(),
    };
  }

  // Método estático para crear una instancia de Member desde un Map<String, dynamic>
  static Member fromMap(Map<String, dynamic> map) {
    return Member(
      userUID: map['userUID'],
      name: map['name'],
      email: map['email'],
      groupID: map['groupID'],
    )
      ..expenseList = map['expenseList'] != null
          ? List<Expense>.from(
          (map['expenseList'] as List<dynamic>).map((expense) => Expense.fromMap(expense)))
          : []
      ..noticeList = map['noticeList'] != null
          ? List<Notice>.from(
          (map['noticeList'] as List<dynamic>).map((notice) => Notice.fromMap(notice)))
          : [];
  }

  // Método para agregar la instancia a Firestore
  Future<void> addToFirestore() async {
    try {
      await FirebaseFirestore.instance
          .collection('Members')
          .doc(userUID)
          .set(toMap());
    } catch (e) {
      // Manejar la excepción
      print('Error adding Member to Firestore: $e');
    }
  }

  // Método estático para obtener una instancia de Member desde Firestore
  static Future<Member?> getMemberFromFirestore(String userUID) async {
    try {
      DocumentSnapshot doc = await FirebaseFirestore.instance
          .collection('Members')
          .doc(userUID)
          .get();
      if (doc.exists) {
        return fromMap(doc.data() as Map<String, dynamic>);
      }
    } catch (e) {
      // Manejar la excepción
      print('Error getting Member from Firestore: $e');
    }
    return null;
  }

  // Método estático para obtener todos los miembros desde Firestore
  static Future<List<Member>> getMemberListFromFirestore() async {
    try {
      QuerySnapshot allDocuments =
      await FirebaseFirestore.instance.collection('Members').get();
      return allDocuments.docs.map((doc) {
        return fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
    } catch (e) {
      // Manejar la excepción
      print('Error getting member list from Firestore: $e');
      return [];
    }
  }

  // Método estático para actualizar la lista local desde Firestore
  static Future<void> updateMemberListFromFirestore() async {
    try {
      memberList.clear();
      memberList.addAll(await getMemberListFromFirestore());
    } catch (e) {
      // Manejar la excepción
      print('Error updating member list from Firestore: $e');
    }
  }

  Future<void> refresh() async {
    if (currentMember != null) {
      Member? updatedMember =
      await getMemberFromFirestore(currentMember!.userUID);
      if (updatedMember != null) {
        currentMember = updatedMember;
      }
    }
  }
}
