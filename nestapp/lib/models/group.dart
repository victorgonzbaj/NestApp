import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../utils/idGenerator.dart';

class Group {
  static List<Group> _groupList = List.empty(growable: true);

  static List<Group> get groupList => _groupList;

  static set groupList(List<Group> value) {
    _groupList = value;
  }

  static late Group? _currentGroup;

  static Group? get currentGroup => _currentGroup;

  static set currentGroup(Group? value) {
    _currentGroup = value;
  }

  static final CollectionReference _groupCollection =
      FirebaseFirestore.instance.collection('Groups');

  late final String _id;
  late String _name;

  String get name => _name;

  set name(String value) {
    _name = value;
  }

  late String? _desc;
  late String? _photo;
  late List<String> _userList = List.empty(growable: true);

  Group.new(this._name, this._desc, this._photo) {
    _id = generateID(prefix: "group.");
    _groupList.add(this);
  }

  Group.created({
    required String id,
    required String name,
    required String? desc,
    required String? photo,
    required List<String> userList,
  })  : _userList = userList,
        _photo = photo,
        _desc = desc,
        _name = name,
        _id = id {
    _groupList.add(this);
  }

  Map<String, dynamic> toMap() {
    return {
      'id': _id,
      'name': _name,
      'desc': _desc,
      'photo': _photo,
      'memberList': _userList
    };
  }

  static Group fromMap(Map map) {
    return Group.created(
      id: map['id'],
      name: map['name'],
      desc: map['desc'],
      photo: map['photo'],
      userList: map['memberList'],
    );
  }

  String? get desc => _desc;

  set desc(String? value) {
    _desc = value;
  }

  String? get photo => _photo;

  set photo(String? value) {
    _photo = value;
  }

  void addUser(User user) {
    _userList.add(user.uid);
  }

  void removeUser(User user) {
    _userList.remove(user.uid);
  }

  Future<void> addGroupToFirestore() async {
    await _groupCollection.doc(_id).set(toMap());
  }

  void addGroupToList() {
    _groupList.add(this);
  }

  static Future<Group?> getGroupFromFirestore(String groupId) async {
    DocumentReference groupDocument = _groupCollection.doc(groupId);
    DocumentSnapshot<Object?> groupMap = await groupDocument.get();
    return fromMap(groupMap as Map);
  }

  static Group? getGroupFromList(String groupId) {
    for (var group in _groupList) {
      if (group._id == groupId) {
        return group;
      }
    }
    return null;
  }

  static Future<List<Group>?> getGroupListFromFirestore() async {
    List<Group> groupList = List.empty(growable: true);
    QuerySnapshot<Object?> allDocuments = await _groupCollection.get();

    for (var groupDoc in allDocuments.docs) {
      Map<String, dynamic> groupData = groupDoc.data() as Map<String, dynamic>;
      groupList.add(fromMap(groupData));
    }
    return groupList;
  }

  static Future<void> updateGroupListFromFirestore() async{
    groupList.clear();
    groupList.addAll(getGroupListFromFirestore() as Iterable<Group>);
  }


}
