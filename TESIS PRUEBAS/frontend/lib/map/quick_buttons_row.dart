import 'package:flutter/material.dart';

class QuickButtonsRow extends StatelessWidget {
  const QuickButtonsRow({super.key});

  Widget _quickButton(IconData icon, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(color: Colors.grey.shade300),
          boxShadow: [
            const BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Icon(icon, color: Colors.grey[700], size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _quickButton(Icons.home_outlined, 'Establecer\ndirección'),
        const SizedBox(width: 8),
        _quickButton(Icons.restaurant, 'Restaurantes'),
        const SizedBox(width: 8),
        _quickButton(Icons.hotel, 'Hoteles'),
      ],
    );
  }
}
