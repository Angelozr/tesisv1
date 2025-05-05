import 'package:flutter/material.dart';
import 'package:frontend/appbar.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CategoriaScreen extends StatefulWidget {
  const CategoriaScreen({super.key});

  @override
  _CategoriaScreenState createState() => _CategoriaScreenState();
}

class _CategoriaScreenState extends State<CategoriaScreen> {
  List<dynamic> _categorias = [];
  final TextEditingController _nombreController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _cargarCategorias();
  }

  Future<void> _cargarCategorias() async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/api/categorias'));

    if (response.statusCode == 200) {
      setState(() {
        _categorias = jsonDecode(response.body);
      });
    } else {
      print("Error al obtener categorías");
    }
  }

  Future<void> _agregarCategoria() async {
    final String nombre = _nombreController.text.trim();

    if (nombre.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Debe ingresar un nombre")),
      );
      return;
    }

    final response = await http.post(
      Uri.parse('${Config.baseUrl}/api/categorias'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": nombre}),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Categoría agregada correctamente")),
      );
      _cargarCategorias();
      Navigator.pop(context);
    } else {
      print("Error al agregar categoría: ${response.body}");
    }
  }

  Future<void> _modificarCategoria(int id, String nuevoNombre) async {
    final response = await http.put(
      Uri.parse('${Config.baseUrl}/api/categorias/$id'),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"nombre": nuevoNombre}),
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Categoría modificada correctamente")),
      );
      _cargarCategorias();
    } else {
      print("Error al modificar categoría: ${response.body}");
    }
  }

  Future<void> _eliminarCategoria(int id) async {
    final response =
        await http.delete(Uri.parse('${Config.baseUrl}/api/categorias/$id'));

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Categoría eliminada correctamente")),
      );
      _cargarCategorias();
    } else {
      print("Error al eliminar categoría: ${response.body}");
    }
  }

  void _mostrarDialogoAgregar() {
    _nombreController.clear();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Agregar Categoría"),
          content: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: "Nombre de la categoría",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: _agregarCategoria,
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

  void _mostrarDialogoModificar(int id, String nombreActual) {
    _nombreController.text = nombreActual;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Modificar Categoría"),
          content: TextField(
            controller: _nombreController,
            decoration: const InputDecoration(
              labelText: "Nuevo nombre",
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: () {
                _modificarCategoria(id, _nombreController.text.trim());
                Navigator.pop(context);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        title: "Gestión de Categorías",
      ),
      body: _categorias.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _categorias.length,
              itemBuilder: (context, index) {
                final categoria = _categorias[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white, // ← fondo blanco puro
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(
                      color: CustomTheme.primaryBlue, // ← borde azul principal
                      width: 1.5,
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        categoria['nombre'],
                        style: const TextStyle(
                            fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: CustomTheme.primaryBlue),
                            onPressed: () => _mostrarDialogoModificar(
                                categoria['id'], categoria['nombre']),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline,
                                color: CustomTheme.primaryBlue),
                            onPressed: () =>
                                _eliminarCategoria(categoria['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _mostrarDialogoAgregar,
        backgroundColor: CustomTheme.primaryBlue,
        child: const Icon(Icons.add, size: 28, color: Colors.white),
      ),
    );
  }
}
