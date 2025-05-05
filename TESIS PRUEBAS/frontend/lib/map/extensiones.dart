import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../config.dart'; // importa el archivo config.dart

class LugarList extends StatefulWidget {
  const LugarList({super.key});

  @override
  State<LugarList> createState() => _LugarListState();
}

class _LugarListState extends State<LugarList> {
  List<Map<String, dynamic>> lugares = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchLugares();
  }

  Future<void> fetchLugares() async {
    try {
      final response = await http.get(Uri.parse('${Config.baseUrl}/api/lugar'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        setState(() {
          lugares = data.map((item) => item as Map<String, dynamic>).toList();
          isLoading = false;
        });
      } else {
        print('Error al cargar los lugares');
        setState(() => isLoading = false);
      }
    } catch (e) {
      print('Error de red: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 110,
      child: isLoading
          ? const Center(child: CircularProgressIndicator())
          : lugares.isEmpty
              ? const Center(child: Text("No hay lugares"))
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: lugares.length,
                  itemBuilder: (context, index) {
                    final lugar = lugares[index];
                    return Padding(
                      padding: const EdgeInsets.only(right: 10),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Container(
                          width: 160,
                          padding: const EdgeInsets.all(10),
                          child: Center(
                            child: Text(
                              lugar['nombre'] ?? 'Sin nombre',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
