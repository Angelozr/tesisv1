import 'package:flutter/material.dart';

class BloqueDetailPage extends StatelessWidget {
  final String nombre;
  final String descripcion;
  final String nombreEdificio;
  final List<dynamic> laboratorios;

  final List<String> imagenes = []; // ← listo para conectar URLs después

  BloqueDetailPage({
    super.key,
    required this.nombre,
    required this.descripcion,
    required this.nombreEdificio,
    required this.laboratorios,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        title: Text(
          nombre,
          style:
              const TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        iconTheme: const IconThemeData(color: Colors.black),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          // ---------------------------
          // Nombre del Edificio + Carrusel
          // ---------------------------
          Text(
            nombreEdificio,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 150,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: imagenes.isEmpty ? 5 : imagenes.length,
              itemBuilder: (context, index) {
                if (imagenes.isEmpty) {
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 10),
                    decoration: BoxDecoration(
                      color: Colors.grey[300],
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Center(child: Text('Sin imagen')),
                  );
                } else {
                  // Cuando tengas URLs de imágenes, descomenta esto:
                  /*
                  return Container(
                    width: 200,
                    margin: const EdgeInsets.only(right: 10),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.network(
                        imagenes[index],
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                  */
                }
                return null;
              },
            ),
          ),
          const SizedBox(height: 20),

          // ---------------------------
          // Descripción del Bloque (mejorada)
          // ---------------------------
          const Text(
            'Descripción',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            descripcion.isNotEmpty
                ? descripcion
                : 'Sin descripción disponible.',
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
          const SizedBox(height: 20),

          // ---------------------------
          // Laboratorios (burbujas circulares desplazables)
          // ---------------------------
          const Text(
            'Laboratorios',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          laboratorios.isNotEmpty
              ? SizedBox(
                  height: 80,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: laboratorios.length,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 80,
                        margin: const EdgeInsets.only(right: 10),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.teal[200],
                        ),
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Text(
                              laboratorios[index].toString(),
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              : const Text(
                  'No hay laboratorios registrados.',
                  style: TextStyle(color: Colors.grey),
                ),
        ],
      ),
    );
  }
}
