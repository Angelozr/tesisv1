import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Detectamos si el dispositivo es web (pantalla más ancha) o móvil
            bool isWeb = constraints.maxWidth > 600;

            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Logo de la universidad
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 40.0),
                  child: Image.asset(
                    'assets/images/logo.png', // Ruta del logo
                    height: isWeb ? 180 : 120, // Logo más grande en web
                    fit: BoxFit.contain,
                  ),
                ),

                // Fila de botones (uno al lado del otro)
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Botón de Iniciar Sesión
                    SizedBox(
                      width: isWeb ? 200 : 140, // Botones más grandes en web
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue), // Borde azul
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Iniciar Sesión",
                          style: TextStyle(
                            fontSize:
                                isWeb ? 18 : 16, // Texto más grande en web
                            color: Colors.blue, // Color del texto y borde
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: 20), // Espacio entre los botones
                    // Botón de Registrarse
                    SizedBox(
                      width: isWeb ? 200 : 140, // Botones más grandes en web
                      child: OutlinedButton(
                        onPressed: () {
                          Navigator.pushNamed(context, '/register');
                        },
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.blue), // Borde azul
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Text(
                          "Registrarse",
                          style: TextStyle(
                            fontSize:
                                isWeb ? 18 : 16, // Texto más grande en web
                            color: Colors.blue, // Color del texto y borde
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}
