import 'package:flutter/material.dart';
import '../models/group.dart';
import '../models/member.dart';
class MembersExpelScreen extends StatefulWidget {
  @override
  _ExpelMembersScreenState createState() => _ExpelMembersScreenState();
}

class _ExpelMembersScreenState extends State<MembersExpelScreen> {
  bool _isLoading = false;

  Future<void> _expelMember(Member member) async {
    setState(() {
      _isLoading = true;
    });

    try {
      Group.currentGroup?.removeMember(member);
      await Group.currentGroup?.addGroupToFirestore();

      setState(() {
        _isLoading = false;
      });

      _showConfirmationDialog('El miembro ha sido expulsado');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorDialog('Error al expulsar el miembro');
    }
  }

  void _showConfirmationDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirmación'),
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
    List<Member> members = Member.memberList;

    return Scaffold(
      appBar: AppBar(
        title: Text('Expulsar Miembros'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: members.length,
        itemBuilder: (context, index) {
          return ListTile(
            title: Text(members[index].name),
            subtitle: Text(members[index].email),
            trailing: IconButton(
              icon: Icon(Icons.remove_circle, color: Colors.red),
              onPressed: () {
                showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text('Confirmar Expulsión'),
                      content: Text('¿Estás seguro de que deseas expulsar a este miembro?'),
                      actions: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text('Cancelar'),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                            _expelMember(members[index]);
                          },
                          child: Text('Confirmar'),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
