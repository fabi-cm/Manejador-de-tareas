import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../presentation/blocs/auth_cubit.dart';
import '../presentation/pages/home_page.dart';
import 'register_screen.dart';
import '../auth_service.dart';
// import 'home_screen.dart';
import '../tasks/create_task_page.dart';

//import 'package:google_fonts/google_fonts.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  void login() {
    final authCubit = context.read<AuthCubit>();
    authCubit.login(emailController.text.trim(), passwordController.text.trim());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocListener<AuthCubit, AuthState>(
        listener: (context, state) {
          if (state is Authenticated) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => HomeScreen()),
            );
          } else if (state is AuthError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        child: SingleChildScrollView(
          child: Container(
            width: double.infinity,
            height: MediaQuery.of(context).size.height,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.blue],
                stops: [0.7, 0.3],
              ),
            ),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Image.asset('assets/logo.png', height: 180, width: 180),
                    const Text(
                        "DIESELSOFT",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.orange,
                          fontStyle: FontStyle.italic,
                        ),
                        textAlign: TextAlign.center),
                    const Text(
                      "MANEJO DE TAREAS",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.orange,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 50),
                    BlocBuilder<AuthCubit, AuthState>(
                      builder: (context, state) {
                        return Container(
                          padding: const EdgeInsets.all(16.0),
                          width: MediaQuery.of(context).size.width * 0.8,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: const [
                              BoxShadow(color: Colors.black26, blurRadius: 5, offset: Offset(0, 2)),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                controller: emailController,
                                decoration: const InputDecoration(
                                  labelText: "Correo Electrónico",
                                  prefixIcon: Icon(Icons.person_2_outlined),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextField(
                                controller: passwordController,
                                decoration: const InputDecoration(
                                  labelText: "Contraseña",
                                  prefixIcon: Icon(Icons.lock_outline),
                                ),
                                obscureText: true,
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: state is AuthLoading ? null : login,
                                style: ElevatedButton.styleFrom(
                                  foregroundColor: Colors.white,
                                  backgroundColor: Colors.blue,
                                  minimumSize: const Size(double.infinity, 50),
                                ),
                                child: state is AuthLoading
                                    ? const CircularProgressIndicator(color: Colors.white)
                                    : const Text(
                                  "Iniciar Sesión",
                                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.push(context, MaterialPageRoute(builder: (_) => const RegisterScreen()));
                                },
                                child: const Text("¿No tienes cuenta? Crear cuenta"),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
