import 'package:flutter/material.dart';
import 'package:frontend/map/quick_buttons_row.dart';
import 'package:frontend/map/search_bar.dart';
import 'package:frontend/map/sliding_panel_content.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:sliding_up_panel/sliding_up_panel.dart';
import '../config.dart';

class CustomMapUI extends StatefulWidget {
  const CustomMapUI({super.key});

  @override
  _CustomMapUIState createState() => _CustomMapUIState();
}

class _CustomMapUIState extends State<CustomMapUI> {
  late GoogleMapController mapController;
  String searchText = '';
  double currentZoom = 15;
  bool mapGesturesEnabled = true;

  Set<Marker> _markers = {};

  final CameraPosition _initialPosition = CameraPosition(
    target: LatLng(-0.9527515654917748, -80.74558053820705),
    zoom: 15,
  );

  @override
  void initState() {
    super.initState();
    loadAllBloques();
  }

  Future<void> loadAllBloques() async {
    try {
      final response =
          await http.get(Uri.parse('${Config.baseUrl}/api/bloques'));
      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final markers = data.map((bloque) {
          final lat = double.parse(bloque['latitud'].toString());
          final lng = double.parse(bloque['longitud'].toString());
          final nombre = bloque['nombre'] ?? 'Bloque sin nombre';
          final id = bloque['id'].toString();

          return Marker(
            markerId: MarkerId('bloque_$id'),
            position: LatLng(lat, lng),
            infoWindow: InfoWindow(title: nombre),
          );
        }).toSet();

        setState(() {
          _markers = markers;
        });
      } else {
        print('Error al obtener bloques: ${response.statusCode}');
      }
    } catch (e) {
      print('Error al cargar bloques: $e');
    }
  }

  void moveToBloque(
      String nombre, double lat, double lng, String bloqueId) async {
    final position = LatLng(lat, lng);
    final markerId = MarkerId('bloque_$bloqueId');

    mapController.animateCamera(CameraUpdate.newLatLng(position));

    await Future.delayed(const Duration(milliseconds: 300));
    mapController.showMarkerInfoWindow(markerId);
  }

  void updateSearchText(String text) {
    setState(() {
      searchText = text;
    });
  }

  void zoomIn() {
    currentZoom += 1;
    mapController.animateCamera(CameraUpdate.zoomTo(currentZoom));
  }

  void zoomOut() {
    currentZoom -= 1;
    mapController.animateCamera(CameraUpdate.zoomTo(currentZoom));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            initialCameraPosition: _initialPosition,
            onMapCreated: (controller) {
              mapController = controller;
              mapController.getZoomLevel().then((value) {
                currentZoom = value;
              });
            },
            zoomControlsEnabled: false,
            scrollGesturesEnabled: mapGesturesEnabled,
            zoomGesturesEnabled: mapGesturesEnabled,
            rotateGesturesEnabled: mapGesturesEnabled,
            tiltGesturesEnabled: mapGesturesEnabled,
            markers: _markers,
          ),
          Positioned(
            top: MediaQuery.of(context).padding.top + 10,
            left: 15,
            right: 15,
            child: Column(
              children: [
                SearchBarWithAvatar(onSearchChanged: updateSearchText),
                const SizedBox(height: 10),
                const QuickButtonsRow(),
              ],
            ),
          ),
          SlidingUpPanel(
            minHeight: 120,
            maxHeight: MediaQuery.of(context).size.height *
                0.44, // altura fija máxima (~45%)
            defaultPanelState: PanelState.CLOSED,
            panelSnapping: true,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, -3),
              ),
            ],
            panel: SlidingPanelContent(
              searchText: searchText,
              onBloqueSelected: moveToBloque,
            ),
            onPanelSlide: (position) {
              bool shouldDisableGestures = position > 0.3;
              if (shouldDisableGestures != !mapGesturesEnabled) {
                setState(() {
                  mapGesturesEnabled = !shouldDisableGestures;
                });
              }
            },
          ),
          Positioned(
            bottom: MediaQuery.of(context).size.height * 0.44 +
                10, // alineado justo encima del panel máximo + pequeño margen
            right: 10,
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: 'zoom_in',
                  mini: true,
                  onPressed: zoomIn,
                  child: const Icon(Icons.add),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'zoom_out',
                  mini: true,
                  onPressed: zoomOut,
                  child: const Icon(Icons.remove),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
