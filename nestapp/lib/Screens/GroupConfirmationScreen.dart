import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../utils/AuthManager.dart';
import 'GroupCreationScreen.dart';
import 'MainScreen.dart';

class GroupConfirmationScreen extends StatefulWidget {
  @override
  _GroupConfirmationScreenState createState() => _GroupConfirmationScreenState();
}

class _GroupConfirmationScreenState extends State<GroupConfirmationScreen> {
  final TextEditingController _groupIdController = TextEditingController();
  bool _isLoading = false;

  Future<void> _joinGroup() async {
    String groupId = _groupIdController.text.trim();

    if (groupId.isEmpty) {
      _showErrorDialog('El ID del grupo es obligatorio');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    Group? group = await Group.getGroupFromFirestore(groupId);
    if (group != null) {
      String? userId = await AuthManager.getUserUID();
      if (userId != null) {
        Member? member = Member.currentMember;
        if (member != null) {
          group.addMember(member);
          await group.addGroupToFirestore();
          member.groupID = groupId;
          await member.addToFirestore();
          Member.currentMember = member;
          Group.currentGroup = group;
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        } else {
          _showErrorDialog('No se pudo obtener la información del miembro');
        }
      } else {
        _showErrorDialog('No se pudo obtener el UID del usuario');
      }
    } else {
      _showErrorDialog('No se encontró el grupo');
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmación de Grupo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => GroupCreationScreen()),
                );
              },
              child: Text('Crear Grupo'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _groupIdController,
              decoration: InputDecoration(
                labelText: 'ID del Grupo',
              ),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _joinGroup,
              child: Text('Unirme al Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
