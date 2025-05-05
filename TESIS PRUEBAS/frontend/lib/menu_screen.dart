import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/routes.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MenuScreen extends StatefulWidget {
  final String token;

  const MenuScreen({super.key, required this.token});

  @override
  _MenuScreenState createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> {
  String nombre = ''; // Para almacenar el nombre del usuario
  List<Map<String, dynamic>> acciones = [
    {
      'nombre': 'Agregar Lugar',
      'icono': Icons.add_location,
      'pantalla': '/agregarLugar'
    },
    {
      'nombre': 'Agregar Categoría',
      'icono': Icons.category,
      'pantalla': '/categoria'
    },
    {
      'nombre': 'Agregar Edificio',
      'icono': Icons.apartment,
      'pantalla': '/edificio'
    },
    {'nombre': 'Agregar Bloques', 'icono': Icons.block, 'pantalla': '/bloques'},
    {
      'nombre': 'Agregar Evaluacion',
      'icono': Icons.book,
      'pantalla': '/evaluacion'
    },
    {'nombre': 'Mapa', 'icono': Icons.map, 'pantalla': '/map'},
    {'nombre': 'Admision', 'icono': Icons.book, 'pantalla': '/listEvaluacion'},
    {
      'nombre': 'Cerrar Sesión', // Nueva opción para cerrar sesión
      'icono': Icons.exit_to_app, // Icono para la opción de cerrar sesión
      'pantalla':
          '/login' // Aunque no es una pantalla, la vamos a manejar con una acción personalizada
    },
  ];

  @override
  void initState() {
    super.initState();
    _obtenerNombreUsuario(); // Llamar al método para obtener el nombre
  }

  // Método para obtener el nombre del usuario usando el token
  Future<void> _obtenerNombreUsuario() async {
    final response = await http.get(
      Uri.parse('${Config.baseUrl}/api/usuario'),
      headers: {
        'Authorization': widget.token
      }, // Enviamos el token en el encabezado
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      setState(() {
        nombre = data['nombre']; // Asignamos el nombre a la variable
      });
    } else {
      throw Exception('Error al obtener el nombre del usuario');
    }
  }

  // Método para cerrar sesión
  Future<void> _cerrarSesion() async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/logout'),
      headers: {'Authorization': widget.token},
    );

    if (response.statusCode == 200) {
      // Si la respuesta es exitosa, eliminamos el token y redirigimos a la pantalla de login
      Navigator.pushReplacementNamed(context, '/login');
    } else {
      // Si hay algún error al cerrar sesión, mostramos un mensaje
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión')),
      );
    }
  }

  void _navegarSegunAccion(Map<String, dynamic> accion) {
    String pantalla = accion['pantalla'];

    if (pantalla == '/login') {
      _cerrarSesion(); // Si es la opción de cerrar sesión, llamamos al método _cerrarSesion
    } else {
      if (rutasPantallas.containsKey(pantalla)) {
        Navigator.pushNamed(context, pantalla);
      } else {
        print("Pantalla no encontrada");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 20),
            Text(
              "¡Hola, $nombre!", // También mostramos el nombre aquí
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Text(
              "Acciones rápidas:",
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            SizedBox(
              height: 100, // Espacio adecuado para los iconos y texto
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: acciones.length,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: 10.0), // Reduce separación
                    child: GestureDetector(
                      onTap: () => _navegarSegunAccion(acciones[index]),
                      child: Column(
                        mainAxisSize: MainAxisSize.min, // Ajusta al contenido
                        children: [
                          Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.blue.shade100,
                            ),
                            child: Icon(acciones[index]['icono'],
                                size: 30, color: Colors.cyan),
                          ),
                          SizedBox(height: 5),
                          SizedBox(
                            width: 70, // Mantiene el texto compacto
                            child: Text(
                              acciones[index]['nombre'],
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 12),
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
