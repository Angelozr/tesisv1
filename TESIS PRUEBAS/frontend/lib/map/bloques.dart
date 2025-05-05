import 'package:flutter/material.dart';
import 'package:frontend/blocks/bloque_detail_page.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart';

class WidgetBloque extends StatefulWidget {
  final String searchText;
  final Function(String nombre, double lat, double lng, String bloqueId)
      onBloqueSelected;

  const WidgetBloque({
    super.key,
    required this.searchText,
    required this.onBloqueSelected,
  });

  @override
  State<WidgetBloque> createState() => _WidgetBloqueState();
}

class _WidgetBloqueState extends State<WidgetBloque> {
  List<dynamic> bloques = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchBloques();
  }

  Future<void> fetchBloques() async {
    try {
      final response =
          await http.get(Uri.parse('${Config.baseUrl}/api/bloques'));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        data.sort(
            (a, b) => a['nombre'].toString().compareTo(b['nombre'].toString()));
        setState(() {
          bloques = data;
          isLoading = false;
        });
      } else {
        print('Error al obtener bloques');
      }
    } catch (e) {
      print('Error de red: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final filteredBloques = bloques.where((bloque) {
      final nombre = (bloque['nombre'] ?? '').toString().toLowerCase();
      final search = widget.searchText.toLowerCase();
      return nombre.contains(search);
    }).toList();

    return isLoading
        ? const Center(child: CircularProgressIndicator())
        : Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 2),
              ...filteredBloques.map((bloque) => Card(
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: ListTile(
                        onTap: () {
                          widget.onBloqueSelected(
                            bloque['nombre'] ?? 'Bloque sin nombre',
                            double.parse(bloque['latitud'].toString()),
                            double.parse(bloque['longitud'].toString()),
                            bloque['id'].toString(),
                          );
                        },
                        leading: const Icon(Icons.location_city),
                        title: Text(
                          bloque['nombre'] ?? 'Bloque sin nombre',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          "Edificio: ${bloque['nombre_edificio'] ?? 'Desconocido'}",
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.favorite_border,
                                  color: Colors.grey),
                              onPressed: () {
                                // Aquí puedes poner lógica para favoritos en el futuro
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.data_array,
                                  color: Colors.grey),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => BloqueDetailPage(
                                      nombre: bloque['nombre'] ??
                                          'Bloque sin nombre',
                                      descripcion: bloque['descripcion'] ??
                                          'Sin descripción',
                                      nombreEdificio:
                                          bloque['nombre_edificio'] ??
                                              'Desconocido',
                                      laboratorios:
                                          bloque['laboratorios'] ?? [],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  )),
            ],
          );
  }
}
