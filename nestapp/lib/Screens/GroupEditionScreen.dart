import 'package:flutter/material.dart';
import '../models/group.dart';

class GroupEditionScreen extends StatefulWidget {
  @override
  _GroupEditionScreenState createState() => _GroupEditionScreenState();
}

class _GroupEditionScreenState extends State<GroupEditionScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController.text = Group.currentGroup?.name ?? '';
    _descController.text = Group.currentGroup?.desc ?? '';
  }

  Future<void> _updateGroup() async {
    String name = _nameController.text.trim();
    String desc = _descController.text.trim();

    if (name.isEmpty) {
      _showErrorDialog('El nombre del grupo no puede estar vacío');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      Group.currentGroup?.name = name;
      Group.currentGroup?.desc = desc;
      await Group.currentGroup?.addGroupToFirestore();

      setState(() {
        _isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al actualizar la información del grupo');
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
        title: Text('Editar Grupo'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Nombre del Grupo'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _descController,
              decoration: InputDecoration(labelText: 'Descripción del Grupo'),
            ),
            SizedBox(height: 16.0),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _updateGroup,
              child: Text('Actualizar'),
            ),
          ],
        ),
      ),
    );
  }
}
