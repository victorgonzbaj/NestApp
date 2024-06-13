import '../models/group.dart';
import '../models/member.dart';

Future<void> refreshData() async {
  if (Group.currentGroup != null) {
    await Group.currentGroup!.refresh();
  }

  if (Member.currentMember != null) {
    await Member.currentMember!.refresh();
  }

  // Actualiza memberList de Member en función de los miembros en memberList de Group
  if (Group.currentGroup != null) {
    List<Member> updatedMemberList = [];
    for (String memberId in Group.currentGroup!.memberList) {
      Member? member = await Member.getMemberFromFirestore(memberId);
      if (member != null) {
        updatedMemberList.add(member);
      }
    }
    Member.memberList = updatedMemberList;

    // Genera eventos basados en los reminders del grupo
    await Group.currentGroup!.generateEvents();
  }
}
