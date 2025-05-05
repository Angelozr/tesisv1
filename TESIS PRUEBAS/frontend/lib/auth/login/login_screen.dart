import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para usar el portapapeles
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'login_ui.dart'; // Importamos la UI

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Datos de WiFi (puedes obtenerlos dinámicamente si lo necesitas)
  final String wifiName = "Wifi_ULEAM_2024";
  final String wifiPassword = "U1E4M_2024";

  Future<void> _loginUser() async {
    if (!_formKey.currentState!.validate()) return;

    String email = _emailController.text;
    String password = _passwordController.text;

    var url = Uri.parse('${Config.baseUrl}/login');
    var response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"email": email, "password": password}),
    );

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String jwtToken = data['token'];
      String nombre = data['usuario']['nombre'];

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString('nombre', nombre);
      await prefs.setString('token', jwtToken);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Login exitoso")),
      );

      Navigator.pushNamed(
        context,
        '/menu',
        arguments: {
          'nombre': nombre,
          'token': jwtToken,
        },
      );
    } else {
      var errorMsg = jsonDecode(response.body)['error'];
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $errorMsg")),
      );
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showWifiDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: 500, // Limita el tamaño máximo del diálogo
              maxHeight: 400, // Limita la altura del diálogo
            ),
            child: Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Icono de WiFi
                  const Icon(Icons.wifi, size: 50, color: Colors.blue),
                  const SizedBox(height: 15),
                  const Text(
                    "Detalles de WiFi",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Divider(),
                  const SizedBox(height: 10),

                  // Nombre de la red
                  _buildWifiInfo("Red WiFi", wifiName),
                  const SizedBox(height: 10),

                  // Contraseña con botón de copiar
                  _buildWifiInfo("Contraseña", wifiPassword, canCopy: true),
                  const SizedBox(height: 20),

                  // Botón de cerrar
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text("Cerrar",
                          style: TextStyle(color: Colors.white)),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWifiInfo(String label, String value, {bool canCopy = false}) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          Row(
            children: [
              Text(value, style: const TextStyle(fontWeight: FontWeight.w500)),
              if (canCopy)
                IconButton(
                  icon: const Icon(Icons.copy, size: 18, color: Colors.blue),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Contraseña copiada")),
                    );
                  },
                ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return LoginUI(
      formKey: _formKey,
      emailController: _emailController,
      passwordController: _passwordController,
      loginUser: _loginUser,
      showWifiDialog: _showWifiDialog,
    );
  }
}
