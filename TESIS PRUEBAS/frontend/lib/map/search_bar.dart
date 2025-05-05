import 'package:flutter/material.dart';

class SearchBarWithAvatar extends StatelessWidget {
  final ValueChanged<String> onSearchChanged;

  const SearchBarWithAvatar({super.key, required this.onSearchChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 6,
            offset: Offset(0, 2),
          )
        ],
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search, color: Colors.grey),
          ),
          Expanded(
            child: TextField(
              onChanged: onSearchChanged,
              decoration: const InputDecoration(
                hintText: 'Buscar aquí',
                border: InputBorder.none,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
