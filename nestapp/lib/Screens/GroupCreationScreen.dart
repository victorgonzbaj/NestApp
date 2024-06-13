import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/group.dart';
import '../models/member.dart';
import '../utils/idGenerator.dart';
import '../utils/AuthManager.dart';
import 'MainScreen.dart';

class GroupCreationScreen extends StatefulWidget {
  @override
  _GroupCreationScreenState createState() => _GroupCreationScreenState();
}

class _GroupCreationScreenState extends State<GroupCreationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  Future<void> _createGroup() async {
    String name = _nameController.text.trim();
    String desc = _descController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog('El nombre del grupo es obligatorio');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    String? userId = await AuthManager.getUserUID();
    if (userId != null) {
      Group newGroup = Group.new(name: name, desc: desc);
      Member? member = Member.currentMember;
      if (member != null) {
        newGroup.addMember(member);
        await newGroup.addGroupToFirestore();
        member.groupID = newGroup.id;
        await member.addToFirestore();
        Member.currentMember = member;
        Group.currentGroup = newGroup;

        setState(() {
          _isLoading = false;
        });

        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
      } else {
        _showErrorDialog('No se pudo obtener la información del miembro');
        setState(() {
          _isLoading = false;
        });
      }
    } else {
      _showErrorDialog('No se pudo obtener el UID del usuario');
      setState(() {
        _isLoading = false;
      });
    }
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
        title: Text('Crear Grupo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: 'Nombre del Grupo',
              ),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descController,
              decoration: InputDecoration(
                labelText: 'Descripción del Grupo',
              ),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _createGroup,
              child: Text('Crear Grupo'),
            ),
          ],
        ),
      ),
    );
  }
}
