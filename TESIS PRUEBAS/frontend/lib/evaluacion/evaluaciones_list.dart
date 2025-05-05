import 'package:flutter/material.dart';
import 'package:frontend/appbar.dart';
import 'package:frontend/blocks/bloque_detail_page.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EvaluacionesListScreen extends StatefulWidget {
  const EvaluacionesListScreen({super.key});

  @override
  _EvaluacionesListScreenState createState() => _EvaluacionesListScreenState();
}

class _EvaluacionesListScreenState extends State<EvaluacionesListScreen> {
  List<dynamic> evaluaciones = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchEvaluaciones();
  }

  Future<void> fetchEvaluaciones() async {
    final response =
        await http.get(Uri.parse('${Config.baseUrl}/api/evaluaciones'));
    if (response.statusCode == 200) {
      setState(() {
        evaluaciones = jsonDecode(response.body);
      });
    } else {
      print("Error al obtener evaluaciones");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(title: 'Evaluaciones de Nivelación'),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: "Buscar...",
                prefixIcon: Icon(Icons.search, color: CustomTheme.primaryBlue),
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: BorderSide(color: CustomTheme.primaryBlue),
                ),
              ),
              onChanged: (value) {
                setState(() {});
              },
            ),
            const SizedBox(height: 12),
            Expanded(
              child: ListView.builder(
                itemCount: evaluaciones.length,
                itemBuilder: (context, index) {
                  final ev = evaluaciones[index];
                  if (searchController.text.isNotEmpty &&
                      !ev['nombre']
                          .toLowerCase()
                          .contains(searchController.text.toLowerCase())) {
                    return Container();
                  }

                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: CustomTheme.cardBackground,
                      borderRadius: BorderRadius.circular(16),
                      //border: Border.all(
                      // ← AÑADIDO EL BORDE AZUL
                      // color: CustomTheme.primaryBlue,
                      //width: 1.5,
                      // ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top row: name + location
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              ev['nombre'].toString().toUpperCase(),
                              style: const TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(ev['lugar_nombre'] ?? '',
                                    style: const TextStyle(
                                        fontSize: 12,
                                        fontStyle: FontStyle.italic)),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Edificio only
                        Chip(
                          avatar: const Icon(Icons.apartment, size: 16),
                          label: Text("Edificio: ${ev['edificio_nombre']}",
                              style: const TextStyle(fontSize: 12)),
                        ),
                        const SizedBox(height: 8),
                        // Rest of chips in one line
                        Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Chip(
                              avatar:
                                  const Icon(Icons.layers_outlined, size: 16),
                              label: Text("Bloque: ${ev['bloque_nombre']}",
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Chip(
                              avatar:
                                  const Icon(Icons.science_outlined, size: 16),
                              label: Text(
                                  "Laboratorio: ${ev['laboratorios'].join(', ')}",
                                  style: const TextStyle(fontSize: 12)),
                            ),
                            Chip(
                              avatar: const Icon(Icons.access_time, size: 16),
                              label: Text(
                                  "Horarios: ${ev['horarios'].join(', ')}",
                                  style: const TextStyle(fontSize: 12)),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        // Dates + button aligned in one row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.calendar_today,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text(
                                    "Inicio: ${ev['fecha_inicio'].substring(0, 10)}",
                                    style: const TextStyle(fontSize: 12)),
                                const SizedBox(width: 12),
                                const Icon(Icons.flag,
                                    size: 16, color: Colors.grey),
                                const SizedBox(width: 4),
                                Text("Fin: ${ev['fecha_fin'].substring(0, 10)}",
                                    style: const TextStyle(fontSize: 12)),
                              ],
                            ),
                            ElevatedButton.icon(
                              onPressed: () async {
                                final bloqueId = ev['bloque_id'];
                                try {
                                  final response = await http.get(Uri.parse(
                                      '${Config.baseUrl}/api/bloques/$bloqueId'));
                                  if (response.statusCode == 200) {
                                    final bloqueData =
                                        jsonDecode(response.body);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => BloqueDetailPage(
                                          nombre: bloqueData['nombre'] ??
                                              'Bloque sin nombre',
                                          descripcion:
                                              bloqueData['descripcion'] ??
                                                  'Sin descripción',
                                          nombreEdificio:
                                              bloqueData['nombre_edificio'] ??
                                                  'Desconocido',
                                          laboratorios:
                                              bloqueData['laboratorios'] ?? [],
                                        ),
                                      ),
                                    );
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Error al obtener detalles del bloque')),
                                    );
                                  }
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error de red: $e')),
                                  );
                                }
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: CustomTheme.primaryBlue,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 10),
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                              ),
                              icon: const Icon(Icons.info_outline,
                                  color: Colors.white, size: 18),
                              label: const Text('Ver Detalles',
                                  style: TextStyle(
                                      color: Colors.white, fontSize: 12)),
                            ),
                          ],
                        ),
                      ],
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
