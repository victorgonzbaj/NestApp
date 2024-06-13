import 'package:flutter/material.dart';
import '../models/group.dart';
import '../utils/AuthManager.dart';
import '../utils/Validator.dart';
import 'EmailConfirmationScreen.dart';
import 'GroupConfirmationScreen.dart';
import 'MainScreen.dart';
import 'RegisterScreen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Iniciar sesión'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _signIn();
                },
                child: Text('Iniciar sesión'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _resetPassword();
                },
                child: Text('He olvidado la contraseña'),
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => RegisterView()),
                  );
                },
                child: Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _signIn() async {
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();

    bool success = await AuthManager.signIn(email, password);

    if (success) {
      bool isVerified = await AuthManager.isEmailVerified();
      if (isVerified) {
        Group? userGroup = await AuthManager.getUserGroup();
        if (userGroup == null) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => GroupConfirmationScreen()));
        } else {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MainScreen()));
        }
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => EmailConfirmationScreen()));
      }
    } else {
      _showErrorDialog('Error al iniciar sesión. Por favor, inténtelo de nuevo.');
    }
  }

  Future<void> _resetPassword() async {
    String email = _emailController.text.trim();

    if (!Validator.validateEmail(email)) {
      _showErrorDialog('Correo electrónico inválido');
      return;
    }

    await AuthManager.resetPassword(email);
    _showInfoDialog('Se ha enviado un correo para restablecer su contraseña.');
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

  void _showInfoDialog(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Información'),
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
