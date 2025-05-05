import 'package:flutter/material.dart';

class LoginUI extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() loginUser;
  final VoidCallback showWifiDialog;

  const LoginUI({
    super.key,
    required this.formKey,
    required this.emailController,
    required this.passwordController,
    required this.loginUser,
    required this.showWifiDialog,
  });

  @override
  _LoginUIState createState() => _LoginUIState();
}

class _LoginUIState extends State<LoginUI> {
  bool _obscureText = true; // Controla si la contraseña está oculta

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Logo arriba ajustado para no expandirse demasiado
              Stack(
                children: [
                  // Logo ajustado en el centro
                  FractionallySizedBox(
                    widthFactor: 0.6, // Ajusta el ancho del logo
                    child: Image.asset(
                      'assets/images/logo.png',
                      height: size.height * 0.2, // Controlamos la altura
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    top: 0, // Alineamos el WiFi con el logo
                    right: 0,
                    child: IconButton(
                      icon:
                          const Icon(Icons.wifi, size: 30, color: Colors.blue),
                      onPressed: widget
                          .showWifiDialog, // Llamamos a la función al hacer clic
                    ),
                  ),
                ],
              ),
              const SizedBox(
                  height: 8), // Espacio reducido entre logo y formulario

              // Recuadro login más pequeño y estilizado
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400, // Ancho máximo para pantallas grandes
                ),
                child: Container(
                  width: size.width *
                      0.75, // Ancho ajustable según el tamaño de la pantalla
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 12,
                        offset: Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Form(
                    key: widget.formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Bienvenido",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: widget.emailController,
                          decoration: InputDecoration(
                            labelText: "Correo",
                            prefixIcon: Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) return "Ingrese su correo";
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Correo inválido";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 12),
                        TextFormField(
                          controller: widget.passwordController,
                          obscureText: _obscureText,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureText
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.blue,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureText =
                                      !_obscureText; // Cambiar la visibilidad
                                });
                              },
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (value) =>
                              value!.length < 6 ? "Mínimo 6 caracteres" : null,
                        ),
                        const SizedBox(height: 20),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: widget.loginUser,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 3,
                            ),
                            child: const Text(
                              "Iniciar Sesión",
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(
                    context,
                    '/menu',
                    arguments: {
                      'nombre': 'Invitado',
                      'token': null,
                    },
                  );
                },
                child: Text(
                  "Entrar como invitado",
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 16,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
