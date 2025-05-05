import 'package:flutter/material.dart';
import 'package:frontend/config.dart';
import 'package:frontend/custom_theme.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EvaluacionScreen extends StatefulWidget {
  const EvaluacionScreen({super.key});

  @override
  _EvaluacionScreenState createState() => _EvaluacionScreenState();
}

class _EvaluacionScreenState extends State<EvaluacionScreen> {
  List<Map<String, dynamic>> lugares = [];
  List<Map<String, dynamic>> categorias = [];
  List<Map<String, dynamic>> edificios = [];
  List<Map<String, dynamic>> bloques = [];
  List<String> laboratorios = [];

  String? selectedLugar;
  String? selectedCategoria;
  String? selectedEdificio;
  String? selectedBloque;
  List<String> selectedLaboratorios = [];
  DateTime? fechaInicio;
  DateTime? fechaFin;
  List<TimeOfDay> horarios = [];
  TextEditingController nombreEvaluacionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchLugares();
  }

  Future<void> fetchLugares() async {
    var response = await http.get(Uri.parse('${Config.baseUrl}/api/lugar'));
    if (response.statusCode == 200) {
      setState(() {
        lugares = List<Map<String, dynamic>>.from(jsonDecode(response.body));
      });
    }
  }

  Future<void> fetchCategorias(String? lugarId) async {
    if (lugarId == null) return;
    var response = await http
        .get(Uri.parse('${Config.baseUrl}/api/categorias?lugar_id=$lugarId'));
    if (response.statusCode == 200) {
      setState(() {
        categorias = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        selectedCategoria = null;
        edificios = [];
      });
    }
  }

  Future<void> fetchEdificios(String? lugarId, String? categoriaId) async {
    if (categoriaId == null || lugarId == null) return;
    var response = await http.get(Uri.parse(
        '${Config.baseUrl}/api/edificios?lugar_id=$lugarId&categoria_id=$categoriaId'));
    if (response.statusCode == 200) {
      setState(() {
        edificios = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        selectedEdificio = null;
        bloques = [];
      });
    }
  }

  Future<void> fetchBloques(String? edificioId) async {
    if (edificioId == null) return;
    var response = await http.get(
        Uri.parse('${Config.baseUrl}/api/bloques?edificio_id=$edificioId'));
    if (response.statusCode == 200) {
      setState(() {
        bloques = List<Map<String, dynamic>>.from(jsonDecode(response.body));
        selectedBloque = null;
        laboratorios = [];
      });
    }
  }

  Future<void> fetchLaboratorios(String? bloqueId) async {
    if (bloqueId == null) return;
    var response = await http.get(
        Uri.parse('${Config.baseUrl}/api/laboratorios?bloque_id=$bloqueId'));
    if (response.statusCode == 200) {
      setState(() {
        laboratorios = List<String>.from(jsonDecode(response.body));
      });
    }
  }

  Future<void> guardarEvaluacion() async {
    if (selectedLugar == null ||
        selectedCategoria == null ||
        selectedEdificio == null ||
        selectedBloque == null ||
        selectedLaboratorios.isEmpty ||
        fechaInicio == null ||
        fechaFin == null ||
        nombreEvaluacionController.text.isEmpty ||
        horarios.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Todos los campos son obligatorios")),
      );
      return;
    }

    List<String> horariosFormato =
        horarios.map((h) => "${h.hour}:${h.minute}").toList();

    Map<String, dynamic> body = {
      "nombre": nombreEvaluacionController.text,
      "lugar_id": int.parse(selectedLugar!),
      "categoria_id": int.parse(selectedCategoria!),
      "edificio_id": int.parse(selectedEdificio!),
      "bloque_id": int.parse(selectedBloque!),
      "laboratorios": selectedLaboratorios,
      "fecha_inicio": fechaInicio!.toIso8601String(),
      "fecha_fin": fechaFin!.toIso8601String(),
      "horarios": horariosFormato
    };

    try {
      var response = await http.post(
        Uri.parse('${Config.baseUrl}/api/evaluaciones'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Evaluación guardada exitosamente")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error al guardar: ${response.body}")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Error de conexión con el servidor")),
      );
    }
  }

  void addHorario() async {
    TimeOfDay? selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (selectedTime != null) {
      setState(() {
        horarios.add(selectedTime);
      });
    }
  }

  void removeHorario(int index) {
    setState(() {
      horarios.removeAt(index);
    });
  }

  Future<T?> showSelector<T>(
      String title, List<T> items, String Function(T) getLabel) {
    return showModalBottomSheet<T>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: ListView(
            children: [
              ListTile(
                title: Text(title,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
              ),
              ...items.map((item) {
                return ListTile(
                  title: Text(getLabel(item)),
                  onTap: () => Navigator.pop(context, item),
                );
              }).toList(),
            ],
          ),
        );
      },
    );
  }

  Widget buildSelector({
    required String label,
    required String? valueLabel,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: CustomTheme.primaryBlue),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(valueLabel ?? label,
                style: TextStyle(
                    color: valueLabel != null ? Colors.black : Colors.grey)),
            const Icon(Icons.arrow_drop_down),
          ],
        ),
      ),
    );
  }

  Widget buildChipSelector() {
    return Wrap(
      spacing: 8,
      children: laboratorios.map((lab) {
        final isSelected = selectedLaboratorios.contains(lab);
        return FilterChip(
          label: Text(lab),
          selected: isSelected,
          selectedColor: CustomTheme.primaryBlue.withOpacity(0.2),
          onSelected: (selected) {
            setState(() {
              if (selected) {
                selectedLaboratorios.add(lab);
              } else {
                selectedLaboratorios.remove(lab);
              }
            });
          },
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Evaluación"),
        backgroundColor: CustomTheme.primaryBlue,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
              controller: nombreEvaluacionController,
              decoration: InputDecoration(
                labelText: "Nombre de la Evaluación",
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
            const SizedBox(height: 12),
            buildSelector(
              label: "Seleccionar Lugar",
              valueLabel: selectedLugar != null
                  ? lugares.firstWhere(
                      (l) => l['id'].toString() == selectedLugar)['nombre']
                  : null,
              onTap: () async {
                final selected = await showSelector(
                  "Seleccionar Lugar",
                  lugares.map((l) => l['id'].toString()).toList(),
                  (id) => lugares
                      .firstWhere((l) => l['id'].toString() == id)['nombre'],
                );
                if (selected != null) {
                  setState(() {
                    selectedLugar = selected;
                    fetchCategorias(selected);
                  });
                }
              },
            ),
            if (categorias.isNotEmpty)
              buildSelector(
                label: "Seleccionar Categoría",
                valueLabel: selectedCategoria != null
                    ? categorias.firstWhere((c) =>
                        c['id'].toString() == selectedCategoria)['nombre']
                    : null,
                onTap: () async {
                  final selected = await showSelector(
                    "Seleccionar Categoría",
                    categorias.map((c) => c['id'].toString()).toList(),
                    (id) => categorias
                        .firstWhere((c) => c['id'].toString() == id)['nombre'],
                  );
                  if (selected != null) {
                    setState(() {
                      selectedCategoria = selected;
                      fetchEdificios(selectedLugar, selected);
                    });
                  }
                },
              ),
            if (edificios.isNotEmpty)
              buildSelector(
                label: "Seleccionar Edificio",
                valueLabel: selectedEdificio != null
                    ? edificios.firstWhere(
                        (e) => e['id'].toString() == selectedEdificio)['nombre']
                    : null,
                onTap: () async {
                  final selected = await showSelector(
                    "Seleccionar Edificio",
                    edificios.map((e) => e['id'].toString()).toList(),
                    (id) => edificios
                        .firstWhere((e) => e['id'].toString() == id)['nombre'],
                  );
                  if (selected != null) {
                    setState(() {
                      selectedEdificio = selected;
                      fetchBloques(selected);
                    });
                  }
                },
              ),
            if (bloques.isNotEmpty)
              buildSelector(
                label: "Seleccionar Bloque",
                valueLabel: selectedBloque != null
                    ? bloques.firstWhere(
                        (b) => b['id'].toString() == selectedBloque)['nombre']
                    : null,
                onTap: () async {
                  final selected = await showSelector(
                    "Seleccionar Bloque",
                    bloques.map((b) => b['id'].toString()).toList(),
                    (id) => bloques
                        .firstWhere((b) => b['id'].toString() == id)['nombre'],
                  );
                  if (selected != null) {
                    setState(() {
                      selectedBloque = selected;
                      fetchLaboratorios(selected);
                    });
                  }
                },
              ),
            if (laboratorios.isNotEmpty) buildChipSelector(),
            const SizedBox(height: 12),
            buildDateField("Fecha de Inicio", fechaInicio, (picked) {
              setState(() {
                fechaInicio = picked;
              });
            }),
            const SizedBox(height: 12),
            buildDateField("Fecha de Fin", fechaFin, (picked) {
              setState(() {
                fechaFin = picked;
              });
            }),
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                for (int i = 0; i < horarios.length; i++)
                  Card(
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    child: ListTile(
                      title: Text(
                          'Horario ${i + 1}: ${horarios[i].format(context)}'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => removeHorario(i),
                      ),
                    ),
                  ),
                ElevatedButton.icon(
                  onPressed: addHorario,
                  icon: const Icon(Icons.add),
                  label: const Text("Agregar Horario"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: CustomTheme.primaryBlue,
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: guardarEvaluacion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: CustomTheme.primaryBlue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Guardar Evaluación",
                  style: TextStyle(fontSize: 16, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDateField(
      String label, DateTime? date, Function(DateTime) onPick) {
    return GestureDetector(
      onTap: () async {
        DateTime? picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime(2101),
        );
        if (picked != null) {
          onPick(picked);
        }
      },
      child: AbsorbPointer(
        child: TextFormField(
          controller: TextEditingController(
              text: date?.toLocal().toString().split(' ')[0]),
          decoration: InputDecoration(
            labelText: label,
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          ),
        ),
      ),
    );
  }
}
