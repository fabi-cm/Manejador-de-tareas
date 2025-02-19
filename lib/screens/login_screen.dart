import 'package:flutter/material.dart';
import 'register_screen.dart';
import '../auth_service.dart';
import 'home_screen.dart';
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
  final AuthService authService = AuthService();

  void login() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();

    var user = await authService.login(email, password);
    if (user != null) {
      print("Login exitoso: ${user.email}");
      Navigator.push(
          context,
          MaterialPageRoute(
             builder: (_) => HomeScreen(id: user.uid),
            //builder: (_) => CreateTaskPage(id: user.uid),
          ));
    } else {
      print("Error al iniciar sesión");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        // Envolviendo todo en un Scroll
        child: Container(
          clipBehavior: Clip.antiAlias,

          width: double.infinity,
          height: MediaQuery.of(context)
              .size
              .height, // Usamos MediaQuery para evitar problemas de scroll
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white, // Mitad superior blanca
                Colors.blue, // Mitad inferior azul
              ],
              stops: [0.7, 0.3],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/logo.png',
                    height: 180,
                    width: 180,
                  ),
                  Text(
                    "DIESELSOFS",
                    textAlign: TextAlign.center,
                  ),
                  Text(
                    "MANEJO DE TAREAS",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 50),
                  Container(
                    padding: EdgeInsets.all(16.0),
                    width: MediaQuery.of(context).size.width * 0.8,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            labelText: "Correo Electrónico",
                            prefixIcon: Icon(Icons.person_2_outlined),
                          ),
                        ),
                        SizedBox(height: 20),
                        TextField(
                          controller: passwordController,
                          decoration: InputDecoration(
                            labelText: "Contraseña",
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          obscureText: true,
                        ),
                        SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: login,
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.white,
                            backgroundColor: Colors.blue,
                            minimumSize: Size(
                                double.infinity, 50), // Ancho 100% y altura 50
                          ),
                          child: Text(
                            "Iniciar Sesión",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (_) => RegisterScreen()),
                            );
                          },
                          child: Text("¿No tienes cuenta? Crear cuenta"),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
