import 'package:flutter/material.dart';
import 'package:frontend/appbar.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class BloquesScreen extends StatefulWidget {
  const BloquesScreen({super.key});

  @override
  _BloquesScreenState createState() => _BloquesScreenState();
}

class _BloquesScreenState extends State<BloquesScreen> {
  List bloques = [];
  List edificios = [];
  List<String> laboratorios = [];
  TextEditingController nombreController = TextEditingController();
  TextEditingController descripcionController = TextEditingController();
  TextEditingController latitudController = TextEditingController();
  TextEditingController longitudController = TextEditingController();
  TextEditingController laboratorioController = TextEditingController();
  int? edificioSeleccionado;

  @override
  void initState() {
    super.initState();
    obtenerBloques();
    obtenerEdificios();
  }

  Future<void> obtenerBloques() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/bloques'));
    if (response.statusCode == 200) {
      setState(() {
        bloques = json.decode(response.body);
      });
    }
  }

  Future<void> obtenerEdificios() async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/api/edificios'));
    if (response.statusCode == 200) {
      setState(() {
        edificios = json.decode(response.body);
      });
    }
  }

  Future<void> agregarBloque() async {
    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/bloques'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
        'latitud': latitudController.text,
        'longitud': longitudController.text,
        'edificios_id': edificioSeleccionado,
        'laboratorios': laboratorios,
      }),
    );
    if (response.statusCode == 201) {
      obtenerBloques();
      Navigator.pop(context);
    }
  }

  Future<void> modificarBloque(int id) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/api/bloques/$id'),
      headers: {'Content-Type': 'application/json'},
      body: json.encode({
        'nombre': nombreController.text,
        'descripcion': descripcionController.text,
        'latitud': latitudController.text,
        'longitud': longitudController.text,
        'edificios_id': edificioSeleccionado,
        'laboratorios': laboratorios,
      }),
    );
    if (response.statusCode == 200) {
      obtenerBloques();
      Navigator.pop(context);
    }
  }

  Future<void> eliminarBloque(int id) async {
    final response =
        await http.delete(Uri.parse('${Config.baseUrl}/api/bloques/$id'));
    if (response.statusCode == 200) {
      obtenerBloques();
    }
  }

  void mostrarFormulario(
      {int? id,
      String? nombre,
      String? descripcion,
      String? latitud,
      String? longitud,
      int? edificiosId,
      List<String>? labList}) {
    nombreController.text = nombre ?? '';
    descripcionController.text = descripcion ?? '';
    latitudController.text = latitud ?? '';
    longitudController.text = longitud ?? '';
    edificioSeleccionado = edificiosId;
    laboratorios = labList ?? [];

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateDialog) {
            return AlertDialog(
              title: Text(id == null ? 'Agregar Bloque' : 'Modificar Bloque'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: nombreController,
                      decoration: const InputDecoration(
                        labelText: 'Nombre',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: descripcionController,
                      decoration: const InputDecoration(
                        labelText: 'Descripción',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: latitudController,
                      decoration: const InputDecoration(
                        labelText: 'Latitud',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: longitudController,
                      decoration: const InputDecoration(
                        labelText: 'Longitud',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<int>(
                      value: edificioSeleccionado,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        labelText: 'Seleccionar Edificio',
                      ),
                      isExpanded: true,
                      onChanged: (value) {
                        setStateDialog(() {
                          edificioSeleccionado = value;
                        });
                      },
                      items: edificios.map<DropdownMenuItem<int>>((edificio) {
                        return DropdownMenuItem<int>(
                          value: edificio['id'],
                          child: Text(edificio['nombre']),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: laboratorioController,
                      decoration: InputDecoration(
                        labelText: 'Agregar Laboratorio',
                        border: const OutlineInputBorder(),
                        suffixIcon: IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            if (laboratorioController.text.isNotEmpty) {
                              setStateDialog(() {
                                laboratorios.add(laboratorioController.text);
                                laboratorioController.clear();
                              });
                            }
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 5,
                      children: laboratorios.map((lab) {
                        return Chip(
                          label: Text(lab),
                          onDeleted: () {
                            setStateDialog(() {
                              laboratorios.remove(lab);
                            });
                          },
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancelar')),
                ElevatedButton(
                  onPressed: () =>
                      id == null ? agregarBloque() : modificarBloque(id),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryBlue,
                  ),
                  child: const Text('Guardar',
                      style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Gestión de Bloques",
        backgroundColor: CustomTheme.primaryBlue,
      ),
      body: bloques.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: bloques.length,
              itemBuilder: (context, index) {
                final bloque = bloques[index];
                final edificio = edificios.firstWhere(
                  (e) => e['id'] == bloque['edificios_id'],
                  orElse: () => {'nombre': 'Desconocido'},
                );

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: CustomTheme.cardBackground,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.04),
                        blurRadius: 3,
                        offset: const Offset(0, 1),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              bloque['nombre'],
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              "Edificio: ${edificio['nombre']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Descripción: ${bloque['descripcion']}",
                              style: const TextStyle(fontSize: 13),
                            ),
                            Text(
                              "Laboratorios: ${(bloque['laboratorios'] as List).join(', ')}",
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: CustomTheme.primaryBlue, size: 20),
                            onPressed: () => mostrarFormulario(
                              id: bloque['id'],
                              nombre: bloque['nombre'],
                              descripcion: bloque['descripcion'],
                              latitud: bloque['latitud'].toString(),
                              longitud: bloque['longitud'].toString(),
                              edificiosId: bloque['edificios_id'],
                              labList:
                                  List<String>.from(bloque['laboratorios']),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete,
                                color: Colors.red, size: 20),
                            onPressed: () => eliminarBloque(bloque['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => mostrarFormulario(),
        backgroundColor: CustomTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
