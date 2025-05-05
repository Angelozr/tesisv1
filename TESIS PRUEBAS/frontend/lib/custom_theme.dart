import 'package:flutter/material.dart';

class CustomTheme {
  // Colores principales
  static const Color primaryRed = Color(0xFFDB272B);
  static const Color primaryBlue = Color(0xFF164E8E);
  static const Color primaryGreen = Color(0xFF2D7931);
  static const Color primaryColor = primaryBlue;
  static const Color cardBackground =
      Color(0xFFF0F4F8); // un azul grisáceo muy suave

  // Colores adicionales
  static const Color lightBlue = Color(0xFFBBDEFB);
  static const Color darkBlue = Color(0xFF0D47A1);
  // Colores neutrales
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color textDark = Color(0xFF333333);
// Colores neutros
  static const Color neutralDark = Color(0xFF333333);
  static const Color neutralMedium = Color(0xFF666666);
  static const Color neutralLight = Color(0xFFEEEEEE);
// Colores de texto
  static const Color textColor = neutralDark;
  static const Color onPrimaryColor = Colors.white;
  static const Color onSecondaryColor = Colors.black;

  // Estilos de texto básicos
  static const TextStyle titleStyle = TextStyle(
    color: textDark,
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle bodyStyle = TextStyle(
    color: textDark,
    fontSize: 16,
  );

  // Tema claro (base)
  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: primaryColor),
        titleTextStyle: TextStyle(
          color: primaryColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
        ),
      ),
      textTheme: const TextTheme(
        titleLarge: titleStyle,
        bodyMedium: bodyStyle,
      ),
      iconTheme: const IconThemeData(color: primaryColor),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: primaryColor, width: 2),
        ),
        filled: true,
        fillColor: Colors.white,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      cardTheme: CardTheme(
        color: Colors.white,
        elevation: 2,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: primaryColor,
        onPrimary: Colors.white,
        onSurface: textDark,
      ),
    );
  }
}
