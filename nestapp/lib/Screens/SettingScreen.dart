import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nestapp/Screens/LoginScreen.dart';
import 'package:nestapp/Screens/MemberExpelScreen.dart';

import '../models/group.dart';
import '../utils/AuthManager.dart';
import 'GroupEditionScreen.dart';
import 'UserEditionScreen.dart';

class SettingsScreen extends StatefulWidget {
  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  bool _isDarkTheme = false;
  String _accentColor = 'Red';
  List<String> _accentColors = ['Red', 'Blue', 'Green', 'Yellow', 'Pink', 'Purple', 'Teal', 'Brown'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajustes'),
      ),
      body: ListView(
        children: [
          ExpansionTile(
            title: Text('Tema'),
            children: [
              SwitchListTile(
                title: Text('Tema oscuro'),
                value: _isDarkTheme,
                onChanged: (value) {
                  setState(() {
                    _isDarkTheme = value;
                  });
                  // Cambiar el tema aquí
                },
              ),
              ListTile(
                title: Text('Color de acento'),
                trailing: DropdownButton<String>(
                  value: _accentColor,
                  items: _accentColors.map((String color) {
                    return DropdownMenuItem<String>(
                      value: color,
                      child: Text(color),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _accentColor = newValue!;
                    });
                    // Cambiar el color de acento aquí
                  },
                ),
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Usuario'),
            children: [
              ListTile(
                title: Text('Editar Usuario'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => UserEditionScreen()),
                  );
                },
              ),
              ListTile(
                title: Text('Desconectarse'),
                onTap: _signOut,
              ),
            ],
          ),
          ExpansionTile(
            title: Text('Grupo'),
            children: [
              ListTile(
                title: Text('Salirse del Grupo'),
                onTap: _leaveGroup,
              ),
              ListTile(
                title: Text('Editar Grupo'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => GroupEditionScreen()),
                  );
                },
              ),
              ListTile(
                title: Text('Expulsar Miembros'),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => MembersExpelScreen()),
                  );
                },
              ),
              ListTile(
                title: Text('Ver ID del Grupo'),
                onTap: _showGroupId,
              ),
              ListTile(
                title: Text('Borrar Grupo'),
                onTap: _deleteGroup,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _signOut() async {
    await AuthManager.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
    );
  }

  Future<void> _leaveGroup() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('¿Estás seguro de que deseas salir del grupo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Implementar la lógica para salir del grupo
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteGroup() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmar'),
          content: Text('¿Estás seguro de que deseas borrar el grupo?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancelar'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);
                // Implementar la lógica para borrar el grupo
              },
              child: Text('Confirmar'),
            ),
          ],
        );
      },
    );
  }

  void _showGroupId() {
    String? groupId = Group.currentGroup?.id;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('ID del Grupo'),
          content: Text(groupId ?? 'No perteneces a ningún grupo'),
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
}
