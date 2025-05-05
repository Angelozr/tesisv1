import 'package:flutter/material.dart';

class RegisterUI extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final TextEditingController nombreController;
  final TextEditingController apellidoController;
  final TextEditingController emailController;
  final TextEditingController passwordController;
  final Future<void> Function() registerUser;

  const RegisterUI({
    super.key,
    required this.formKey,
    required this.nombreController,
    required this.apellidoController,
    required this.emailController,
    required this.passwordController,
    required this.registerUser,
  });

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
              // Logo ajustado
              FractionallySizedBox(
                widthFactor: 0.6,
                child: Image.asset(
                  'assets/images/logo.png',
                  height: size.height * 0.2,
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 8),

              // Recuadro para el formulario de registro
              ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: 400,
                ),
                child: Container(
                  width: size.width * 0.75,
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
                    key: formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Text(
                            "Registrarse",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Campo Nombre
                        TextFormField(
                          controller: nombreController,
                          decoration: InputDecoration(labelText: "Nombre"),
                          validator: (value) =>
                              value!.isEmpty ? "Ingrese su nombre" : null,
                        ),
                        const SizedBox(height: 10),
                        // Campo Apellido
                        TextFormField(
                          controller: apellidoController,
                          decoration: InputDecoration(labelText: "Apellido"),
                          validator: (value) =>
                              value!.isEmpty ? "Ingrese su apellido" : null,
                        ),
                        const SizedBox(height: 10),
                        // Campo Correo Electrónico
                        TextFormField(
                          controller: emailController,
                          decoration:
                              InputDecoration(labelText: "Correo Electrónico"),
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Ingrese un correo electrónico";
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+')
                                .hasMatch(value)) {
                              return "Correo inválido";
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 10),
                        // Campo Contraseña
                        TextFormField(
                          controller: passwordController,
                          decoration: InputDecoration(labelText: "Contraseña"),
                          obscureText: true,
                          validator: (value) =>
                              value!.length < 6 ? "Mínimo 6 caracteres" : null,
                        ),
                        const SizedBox(height: 20),
                        // Botón de registro
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: registerUser,
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
                              "Registrarse",
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
            ],
          ),
        ),
      ),
    );
  }
}
