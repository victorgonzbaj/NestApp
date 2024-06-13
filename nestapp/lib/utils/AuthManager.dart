import 'package:firebase_auth/firebase_auth.dart';
import '../models/member.dart';
import '../models/group.dart';

class AuthManager {
  static Future<bool> signIn(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Actualizar currentMember
      Member? member = await Member.getMemberFromFirestore(userCredential.user!.uid);
      if (member != null) {
        Member.currentMember = member;
        if (member.groupID != null) {
          Group.currentGroup = await Group.getGroupFromFirestore(member.groupID!);
        }
      }

      return true;
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
      return false;
    }
  }

  static Future<void> signOut() async {
    try {
      await FirebaseAuth.instance.signOut();
      Member.currentMember = null;
      Group.currentGroup = null;
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  static Future<bool> createAccount(String email, String password, String name, String surname) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await userCredential.user?.updateDisplayName('$name $surname');
      await userCredential.user?.sendEmailVerification();

      // Crear y guardar el nuevo miembro
      Member newMember = Member(
        userUID: userCredential.user!.uid,
        name: '$name $surname',
        email: email,
      );
      await newMember.addToFirestore();
      Member.currentMember = newMember;

      return true;
    } catch (e) {
      print('Error durante la creación de la cuenta: $e');
      return false;
    }
  }

  static Future<void> resetPassword(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar el correo de restablecimiento de contraseña: $e');
    }
  }

  static Future<String?> getUserUID() async {
    return FirebaseAuth.instance.currentUser?.uid;
  }

  static Future<bool> isLoged() async {
    User? user = FirebaseAuth.instance.currentUser;
    return user != null;
  }

  static Future<bool> isEmailVerified() async {
    User? user = FirebaseAuth.instance.currentUser;
    await user?.reload();
    return user?.emailVerified ?? false;
  }

  static Future<void> resendEmailVerification() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.emailVerified) {
      await user.sendEmailVerification();
    }
  }

  static Future<Group?> getUserGroup() async {
    if (Member.currentMember != null) {
      return await Group.getGroupFromFirestore(Member.currentMember!.groupID!);
    }
    return null;
  }
}
