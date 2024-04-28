import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nestapp/models/member.dart';

import '../utils/idGenerator.dart';

class Group {
  static List<Group> groupList = List.empty(growable: true);
  static CollectionReference groupCollection = FirebaseFirestore.instance
      .collection('Groups');

  late String id;
  late String name;
  late String? desc;
  late String? photo;
  late List<String> memberList = List.empty(growable: true);

  Group.new(this.name, this.desc, this.photo) {
    id = generateID(prefix: "group.");
    groupList.add(this);
  }

  Group.created({
    required this.id,
    required this.name,
    required this.desc,
    required this.photo,
    required this.memberList,
  }) {
    groupList.add(this);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'desc': desc,
      'photo': photo,
      'memberList': memberList
    };
  }

  static Group fromMap(Map map) {
    return Group.created(
      id: map['id'],
      name: map['name'],
      desc: map['desc'],
      photo: map['photo'],
      memberList: map['memberList'],
    );
  }

}
