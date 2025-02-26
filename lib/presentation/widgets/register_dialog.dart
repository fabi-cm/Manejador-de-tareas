import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';

void showRegisterDialog(BuildContext context) {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  showDialog(
    context: context,
    builder: (context) {
      return BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: AlertDialog(
          title: const Text(
            "Registro de Usuario",
            style: TextStyle(
              fontSize: 40,
              fontFamily: 'italiano',
              color: Colors.orange,
              fontWeight: FontWeight.bold,
              decoration: TextDecoration.underline,
              decorationColor: Colors.orange,
              decorationThickness: 2,
            ),            textAlign: TextAlign.center,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTextField(usernameController, "Nombre Usuario", Icons.person),
                const SizedBox(height: 10),
                _buildTextField(emailController, "Correo Electrónico", Icons.email),
                const SizedBox(height: 10),
                _buildTextField(passwordController, "Contraseña", Icons.lock, obscureText: true),
                const SizedBox(height: 10),
                _buildTextField(confirmPasswordController, "Repetir Contraseña", Icons.lock, obscureText: true),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancelar", style: TextStyle(color: Colors.red)),
            ),
            TextButton(
              onPressed: () {
                String email = emailController.text.trim();
                String password = passwordController.text.trim();
                String confirmPassword = confirmPasswordController.text.trim();
                String username = usernameController.text.trim();

                if (password != confirmPassword) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text("Las contraseñas no coinciden"),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                // ✅ Registrar usuario sin afectar la sesión del administrador
                context.read<AuthCubit>().registerUserAsAdmin(email, password, username);
              },
              child: const Text("Registrar", style: TextStyle(color: Colors.blue)),
            ),
          ],
        ),
      );
    },
  );
}

// 🔹 Método reutilizable para crear campos de texto
Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscureText = false}) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
    ),
    obscureText: obscureText,
  );
}
