import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nestapp/models/group.dart';

class Member {
  static List<Member> memberList = List.empty(growable: true);
  static CollectionReference memberCollection =
      FirebaseFirestore.instance.collection('Members');

  late String id;
  late String name;
  late String? desc;
  late String? photo;
  late String? groupId;

  Member(
    this.desc,
    this.groupId,
  ) {
    id = FirebaseAuth.instance.currentUser!.uid;
    name = FirebaseAuth.instance.currentUser!.displayName!;
    photo = FirebaseAuth.instance.currentUser?.photoURL;
    memberList.add(this);
  }

  Member.created({
    required this.id,
    required this.name,
    required this.desc,
    required this.photo,
    required this.groupId,
  }) {
    memberList.add(this);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'photo': photo,
      'groupId': groupId,
    };
  }

  static Member fromMap(Map map) {
    return Member.created(
      id: map['id'],
      name: map['name'],
      desc: map['desc'],
      photo: map['photo'],
      groupId: map['groupId'],
    );
  }
}
