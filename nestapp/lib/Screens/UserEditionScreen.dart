import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/member.dart';
class UserEditionScreen extends StatefulWidget {
  @override
  _UserEditionScreenState createState() => _UserEditionScreenState();
}

class _UserEditionScreenState extends State<UserEditionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = Member.currentMember?.name ?? '';
    _emailController.text = Member.currentMember?.email ?? '';
  }

  Future<void> _updateUser() async {
    String name = _nameController.text.trim();
    String email = _emailController.text.trim();

    if (name.isEmpty || email.isEmpty) {
      _showErrorDialog('Nombre y correo electrónico no pueden estar vacíos');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      User? user = FirebaseAuth.instance.currentUser;
      await user?.updateEmail(email);
      await user?.updateDisplayName(name);

      Member.currentMember?.name = name;
      Member.currentMember?.email = email;
      await Member.currentMember?.addToFirestore();

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al actualizar la información del usuario');
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
        title: Text('Editar Usuario'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Correo Electrónico'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateUser,
              child: Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
