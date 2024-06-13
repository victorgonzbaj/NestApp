import 'package:flutter/material.dart';
import '../models/group.dart';
import '../utils/AuthManager.dart';
import '../utils/Validator.dart';
import 'EmailConfirmationScreen.dart';
import 'GroupConfirmationScreen.dart';
import 'MainScreen.dart';

class RegisterView extends StatefulWidget {
  const RegisterView({Key? key}) : super(key: key);

  @override
  _RegisterViewState createState() => _RegisterViewState();
}

class _RegisterViewState extends State<RegisterView> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _surnameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _confirmEmailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crear cuenta'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'Nombre',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _surnameController,
                decoration: InputDecoration(
                  labelText: 'Apellidos',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                ),
              ),
              SizedBox(height: 16.0),
              TextField(
                controller: _confirmEmailController,
                decoration: InputDecoration(
                  labelText: 'Confirmar correo electrónico',
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
              TextField(
                controller: _confirmPasswordController,
                decoration: InputDecoration(
                  labelText: 'Confirmar contraseña',
                ),
                obscureText: true,
              ),
              SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  _createAccount();
                },
                child: Text('Crear cuenta'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createAccount() async {
    String name = _nameController.text.trim();
    String surname = _surnameController.text.trim();
    String email = _emailController.text.trim();
    String confirmEmail = _confirmEmailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();

    if (email != confirmEmail) {
      _showErrorDialog('Los correos electrónicos no coinciden');
      return;
    }

    if (password != confirmPassword) {
      _showErrorDialog('Las contraseñas no coinciden');
      return;
    }

    if (!Validator.validateEmail(email)) {
      _showErrorDialog('Correo electrónico inválido');
      return;
    }

    if (!Validator.validatePassword(password)) {
      _showErrorDialog('Contraseña inválida. Debe tener al menos una minúscula, una mayúscula, un número y al menos 10 caracteres');
      return;
    }

    bool success = await AuthManager.createAccount(email, password, name, surname);

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
      _showErrorDialog('Error al crear la cuenta. Por favor, inténtelo de nuevo.');
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
}
