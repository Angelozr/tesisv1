import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:frontend/config.dart';
import 'register_ui.dart'; // Importamos la UI

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidoController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  Future<void> _registerUser() async {
    if (!_formKey.currentState!.validate()) return;

    String nombre = _nombreController.text;
    String apellido = _apellidoController.text;
    String email = _emailController.text;
    String password = _passwordController.text;

    var url = Uri.parse('${Config.baseUrl}/register');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "nombre": nombre,
        "apellido": apellido,
        "email": email,
        "password": password,
      }),
    );

    if (response.statusCode == 201) {
      var data = jsonDecode(response.body);
      String token = data['token'];

      final prefs = await SharedPreferences.getInstance();
      prefs.setString('token', token);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Usuario registrado con éxito")),
      );
      Navigator.pop(context);
    } else {
      var errorMsg = jsonDecode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMsg")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return RegisterUI(
      formKey: _formKey,
      nombreController: _nombreController,
      apellidoController: _apellidoController,
      emailController: _emailController,
      passwordController: _passwordController,
      registerUser: _registerUser,
    );
  }
}
