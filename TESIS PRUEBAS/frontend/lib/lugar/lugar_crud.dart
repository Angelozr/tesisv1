import 'package:flutter/material.dart';
import 'package:frontend/appbar.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class Lugar {
  final int id;
  final String nombre;
  final String fechaCreacion;

  Lugar({required this.id, required this.nombre, required this.fechaCreacion});

  factory Lugar.fromJson(Map<String, dynamic> json) {
    return Lugar(
      id: json['id'],
      nombre: json['nombre'],
      fechaCreacion: json['fecha_creacion'],
    );
  }
}

class AgregarLugarScreen extends StatefulWidget {
  const AgregarLugarScreen({super.key});

  @override
  _AgregarLugarScreenState createState() => _AgregarLugarScreenState();
}

class _AgregarLugarScreenState extends State<AgregarLugarScreen> {
  final TextEditingController _nombreController = TextEditingController();
  List<Lugar> _lugares = [];
  String? _token;

  @override
  void initState() {
    super.initState();
    _verificarSesion();
  }

  Future<void> _verificarSesion() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');

    if (token == null) {
      Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
    } else {
      setState(() {
        _token = token;
      });
      _cargarLugares();
    }
  }

  Future<void> _cargarLugares() async {
    if (_token == null) return;

    final url = Uri.parse('${Config.baseUrl}/api/lugar');
    final response = await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = json.decode(response.body);
      setState(() {
        _lugares = data.map((lugar) => Lugar.fromJson(lugar)).toList();
      });
    } else {
      print("Error al cargar lugares: ${response.statusCode}");
    }
  }

  Future<void> _guardarLugar() async {
    if (_token == null) return;

    final url = Uri.parse('${Config.baseUrl}/api/lugar');
    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $_token",
      },
      body: jsonEncode({
        "nombre": _nombreController.text,
        "fecha_creacion": DateTime.now().toString().split(' ')[0],
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lugar agregado correctamente")),
      );
      _cargarLugares();
      _nombreController.clear();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al agregar lugar")),
      );
    }
  }

  Future<void> _modificarLugar(Lugar lugar) async {
    final TextEditingController modificarNombreController =
        TextEditingController(text: lugar.nombre);

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Modificar Lugar"),
          content: TextField(
            controller: modificarNombreController,
            decoration: const InputDecoration(
              labelText: "Nuevo nombre del lugar",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () async {
                if (_token == null) return;

                final url =
                    Uri.parse('${Config.baseUrl}/api/lugar/${lugar.id}');
                final response = await http.put(
                  url,
                  headers: {
                    "Content-Type": "application/json",
                    "Authorization": "Bearer $_token",
                  },
                  body: jsonEncode({
                    "nombre": modificarNombreController.text,
                    "fecha_creacion": lugar.fechaCreacion,
                  }),
                );

                if (response.statusCode == 200) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                        content: Text("Lugar modificado correctamente")),
                  );
                  _cargarLugares();
                  Navigator.of(context).pop();
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Error al modificar lugar")),
                  );
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: CustomTheme.primaryBlue,
              ),
              child:
                  const Text("Guardar", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _eliminarLugar(int id) async {
    if (_token == null) return;

    final url = Uri.parse('${Config.baseUrl}/api/lugar/$id');
    final response = await http.delete(
      url,
      headers: {
        "Authorization": "Bearer $_token",
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Lugar eliminado correctamente")),
      );
      _cargarLugares();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error al eliminar lugar")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Gestionar Lugares",
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _nombreController,
              decoration: InputDecoration(
                hintText: "Nombre del Lugar",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: const BorderSide(
                      color: CustomTheme.primaryBlue, width: 2),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
            ),
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _guardarLugar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text("Guardar Lugar",
                    style: TextStyle(fontSize: 16, color: Colors.white)),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _lugares.isEmpty
                  ? const Center(child: Text("No hay lugares registrados."))
                  : ListView.builder(
                      itemCount: _lugares.length,
                      itemBuilder: (context, index) {
                        final lugar = _lugares[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: ListTile(
                            title: Text(lugar.nombre),
                            subtitle: Text("Creado: ${lugar.fechaCreacion}"),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: CustomTheme.primaryBlue),
                                  onPressed: () => _modificarLugar(lugar),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete_outline,
                                      color: CustomTheme.primaryBlue),
                                  onPressed: () {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text(
                                              "Confirmar eliminación"),
                                          content: const Text(
                                              "¿Estás seguro de que quieres eliminar este lugar?"),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.of(context).pop(),
                                              child: const Text("Cancelar"),
                                            ),
                                            ElevatedButton(
                                              onPressed: () {
                                                _eliminarLugar(lugar.id);
                                                Navigator.of(context).pop();
                                              },
                                              style: ElevatedButton.styleFrom(
                                                backgroundColor:
                                                    CustomTheme.primaryBlue,
                                              ),
                                              child: const Text("Eliminar",
                                                  style: TextStyle(
                                                      color: Colors.white)),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
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
