import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:nestapp/Screens/EmailConfirmationScreen.dart';
import 'package:nestapp/Screens/LoginScreen.dart';
import 'package:nestapp/utils/Refresh.dart';
import 'Screens/GroupConfirmationScreen.dart';
import 'Screens/MainScreen.dart';
import 'firebase_options.dart';
import 'models/group.dart';
import 'models/member.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    name: 'nestApp',
    options: DefaultFirebaseOptions.currentPlatform,
  );
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: true,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'NestApp',
      theme: ThemeData.light(),
      darkTheme: ThemeData.dark(),
      themeMode: ThemeMode.system,
      home: AuthChecker(),
    );
  }
}

class AuthChecker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<User?>(
      future: _checkAuthState(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return CircularProgressIndicator();
        } else {
          if (snapshot.hasData) {
            return _handleUserState(snapshot.data!);
          } else {
            return LoginScreen();
          }
        }
      },
    );
  }

  Future<User?> _checkAuthState() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      await user.reload();
      if (user.emailVerified) {
        Member? member = await Member.getMemberFromFirestore(user.uid);
        if (member != null) {
          Member.currentMember = member;
          if (member.groupID != null) {
            Group.currentGroup = await Group.getGroupFromFirestore(member.groupID!);
          }
          refreshData();
        }
      }
    }
    return user;
  }

  Widget _handleUserState(User user) {
    if (!user.emailVerified) {
      return EmailConfirmationScreen();
    } else if (Member.currentMember?.groupID == null || Group.currentGroup == null) {
      return GroupConfirmationScreen();
    } else {
      return MainScreen();
    }
  }
}

