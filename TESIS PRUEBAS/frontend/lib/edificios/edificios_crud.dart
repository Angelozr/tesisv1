import 'package:flutter/material.dart';
import 'package:frontend/appbar.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EdificioScreen extends StatefulWidget {
  const EdificioScreen({super.key});

  @override
  _EdificioScreenState createState() => _EdificioScreenState();
}

class _EdificioScreenState extends State<EdificioScreen> {
  List<dynamic> _edificios = [];
  List<dynamic> _lugares = [];
  List<dynamic> _categorias = [];
  final TextEditingController _nombreController = TextEditingController();
  int? _lugarSeleccionado;
  int? _categoriaSeleccionada;
  int? _edificioIdSeleccionado;

  @override
  void initState() {
    super.initState();
    _cargarEdificios();
    _cargarLugares();
    _cargarCategorias();
  }

  Future<void> _cargarEdificios() async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/api/edificios'));
    if (response.statusCode == 200) {
      setState(() {
        _edificios = jsonDecode(response.body);
      });
    }
  }

  Future<void> _cargarLugares() async {
    final response = await http.get(Uri.parse('${Config.baseUrl}/api/lugar'));
    if (response.statusCode == 200) {
      setState(() {
        _lugares = jsonDecode(response.body);
      });
    }
  }

  Future<void> _cargarCategorias() async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/api/categorias'));
    if (response.statusCode == 200) {
      setState(() {
        _categorias = jsonDecode(response.body);
      });
    }
  }

  Future<void> _guardarEdificio() async {
    final nombre = _nombreController.text.trim();
    if (nombre.isEmpty ||
        _lugarSeleccionado == null ||
        _categoriaSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Complete todos los campos")));
      return;
    }

    final body = jsonEncode({
      "nombre": nombre,
      "lugar_id": _lugarSeleccionado,
      "categoria_id": _categoriaSeleccionada
    });
    final url = _edificioIdSeleccionado == null
        ? '${Config.baseUrl}/api/edificios'
        : '${Config.baseUrl}/api/edificios/$_edificioIdSeleccionado';

    final response = await (_edificioIdSeleccionado == null
        ? http.post(Uri.parse(url),
            headers: {"Content-Type": "application/json"}, body: body)
        : http.put(Uri.parse(url),
            headers: {"Content-Type": "application/json"}, body: body));

    if (response.statusCode == 201 || response.statusCode == 200) {
      _cargarEdificios();
      Navigator.pop(context);
    }
  }

  Future<void> _eliminarEdificio(int id) async {
    await http.delete(Uri.parse('${Config.baseUrl}/api/edificios/$id'));
    _cargarEdificios();
  }

  void _mostrarDialogoEdicion({Map<String, dynamic>? edificio}) {
    if (edificio != null) {
      _edificioIdSeleccionado = edificio['id'];
      _nombreController.text = edificio['nombre'];
      _lugarSeleccionado = edificio['lugar_id'];
      _categoriaSeleccionada = edificio['categoria_id'];
    } else {
      _edificioIdSeleccionado = null;
      _nombreController.clear();
      _lugarSeleccionado = null;
      _categoriaSeleccionada = null;
    }

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(_edificioIdSeleccionado == null
              ? "Agregar Edificio"
              : "Modificar Edificio"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: _nombreController,
                  decoration: const InputDecoration(
                    labelText: "Nombre",
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _lugarSeleccionado,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Seleccionar Lugar",
                  ),
                  onChanged: (int? newValue) =>
                      setState(() => _lugarSeleccionado = newValue),
                  items: _lugares.map<DropdownMenuItem<int>>((lugar) {
                    return DropdownMenuItem<int>(
                      value: lugar['id'],
                      child: Text(lugar['nombre']),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 10),
                DropdownButtonFormField<int>(
                  value: _categoriaSeleccionada,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Seleccionar Categoría",
                  ),
                  onChanged: (int? newValue) =>
                      setState(() => _categoriaSeleccionada = newValue),
                  items: _categorias.map<DropdownMenuItem<int>>((categoria) {
                    return DropdownMenuItem<int>(
                      value: categoria['id'],
                      child: Text(categoria['nombre']),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar"),
            ),
            ElevatedButton(
              onPressed: _guardarEdificio,
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
        title: "Gestión de Edificios",
        backgroundColor: CustomTheme.primaryBlue,
      ),
      body: _edificios.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
              padding: const EdgeInsets.all(10),
              itemCount: _edificios.length,
              itemBuilder: (context, index) {
                final edificio = _edificios[index];
                final lugarNombre = _lugares.firstWhere(
                    (lugar) => lugar['id'] == edificio['lugar_id'],
                    orElse: () => {'nombre': 'Desconocido'})['nombre'];
                final categoriaNombre = _categorias.firstWhere(
                    (cat) => cat['id'] == edificio['categoria_id'],
                    orElse: () => {'nombre': 'Desconocida'})['nombre'];

                return Container(
                  margin: const EdgeInsets.only(bottom: 10),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: CustomTheme.cardBackground, // ← color difuminado
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              edificio['nombre'],
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 2),
                            Text("Lugar: $lugarNombre"),
                            Text("Categoría: $categoriaNombre"),
                          ],
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit,
                                color: CustomTheme.primaryBlue),
                            onPressed: () =>
                                _mostrarDialogoEdicion(edificio: edificio),
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () => _eliminarEdificio(edificio['id']),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _mostrarDialogoEdicion(),
        backgroundColor: CustomTheme.primaryBlue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
