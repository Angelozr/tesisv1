import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onBackPressed;
  final Color? backgroundColor; // Agregado para personalizar el fondo

  const CustomAppBar({
    super.key,
    required this.title,
    this.onBackPressed,
    this.backgroundColor, // Recibir color opcional
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor:
          Colors.transparent, // Mantener el fondo completamente transparente
      elevation: 0, // Sin sombra
      shadowColor: Colors.transparent, // Asegurar que no haya sombras visibles
      leading: IconButton(
        icon: const Icon(
          Icons.arrow_back_ios_new,
          size: 20,
        ), // Flecha personalizada
        onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
      ),
      centerTitle: true,
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16, // Tamaño de texto ajustado
          fontWeight: FontWeight.bold,
          color: Colors.black, // Color del texto
        ),
      ),
      iconTheme: const IconThemeData(color: Colors.black), // Íconos en negro
      leadingWidth: 56, // Asegura espacio consistente para el ícono
      actions: [
        Container(
          width: 56, // Simula un espacio equivalente al `leading`
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
