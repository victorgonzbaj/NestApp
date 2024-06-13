import 'package:flutter/material.dart';
import '../utils/AuthManager.dart';
import 'MainScreen.dart';

class EmailConfirmationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Confirmar Correo Electrónico'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Debe confirmar su correo electrónico para continuar. Por favor, revise su bandeja de entrada.',
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                AuthManager.resendEmailVerification();
              },
              child: Text('Reenviar correo de verificación'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () async {
                bool isVerified = await AuthManager.isEmailVerified();
                if (isVerified) {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
                } else {
                  _showErrorDialog(context, 'El correo electrónico aún no está verificado.');
                }
              },
              child: Text('Actualizar'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: () {
                AuthManager.signOut();
                Navigator.popUntil(context, (route) => route.isFirst);
              },
              child: Text('Salir'),
            ),
          ],
        ),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String message) {
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
}
