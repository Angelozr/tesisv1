import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ProfileScreen extends StatefulWidget {
  final String token; // Recibimos el token JWT al iniciar sesión

  const ProfileScreen({super.key, required this.token});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late String nombre = '';
  late String apellido = '';
  late String email = '';
  bool isLoading = true;
  String errorMessage = '';
  String photoURL = ''; // Para la URL de la foto de perfil

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  // Función para obtener los datos del usuario desde el backend
  Future<void> _fetchUserData() async {
    final response = await http.get(
      Uri.parse(
          '${Config.baseUrl}/api/profile'), // Cambia aquí para usar /api/profile
      headers: {
        'Authorization':
            'Bearer ${widget.token}', // Enviar el token JWT en el encabezado
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nombre = data['nombre'];
        apellido = data['apellido'];
        email = data['email'];
        photoURL = data['photoURL'] ??
            ''; // Asignar la URL de la foto si está disponible
        isLoading = false;
      });
    } else {
      setState(() {
        errorMessage = 'Error al cargar los datos del usuario';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage.isNotEmpty
              ? Center(child: Text(errorMessage))
              : Stack(
                  children: [
                    Container(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Colors.blueAccent,
                            Colors.lightBlue,
                          ],
                        ),
                      ),
                    ),
                    Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            _buildHeader(
                              context,
                              '$nombre $apellido', // Nombre completo
                              photoURL, // Foto de perfil
                            ),
                            Expanded(
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Column(
                                    children: [
                                      _buildProfileCard(
                                          'Nombres', '$nombre $apellido'),
                                      _buildProfileCard('Correo', email),
                                      // Agrega más campos si es necesario
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
    );
  }

  Widget _buildHeader(BuildContext context, String name, String photoURL) {
    return Container(
      height: 200,
      alignment: Alignment.bottomCenter,
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              // Puedes agregar funcionalidad aquí si deseas
            },
            child: CircleAvatar(
              radius: 50,
              backgroundColor: Colors.white,
              backgroundImage:
                  photoURL.isNotEmpty ? NetworkImage(photoURL) : null,
              child: photoURL.isEmpty
                  ? const Icon(
                      Icons.person,
                      size: 50,
                      color: Colors.grey,
                    )
                  : null,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                Shadow(
                  color: Colors.black54,
                  blurRadius: 10,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileCard(String title, String value) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(value),
        leading: Icon(
          _getIconForField(title),
          color: Colors.blueAccent,
        ),
      ),
    );
  }

  IconData _getIconForField(String title) {
    switch (title) {
      case 'Nombre':
        return Icons.person;
      case 'Correo':
        return Icons.email;
      default:
        return Icons.info;
    }
  }
}
