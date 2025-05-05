import 'package:flutter/material.dart';
import 'package:frontend/map/bloques.dart';

class SlidingPanelContent extends StatelessWidget {
  final String searchText;
  final Function(String nombre, double lat, double lng, String bloqueId)
      onBloqueSelected;

  const SlidingPanelContent({
    super.key,
    required this.searchText,
    required this.onBloqueSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 10),
        const Center(
          child: SizedBox(
            width: 40,
            height: 4,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Colors.grey,
                borderRadius: BorderRadius.all(Radius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "Listado de Edificios",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            physics: const BouncingScrollPhysics(),
            children: [
              WidgetBloque(
                searchText: searchText,
                onBloqueSelected: onBloqueSelected,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
