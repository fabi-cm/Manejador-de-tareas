import 'package:flutter/material.dart';
//import 'package:google_fonts/google_fonts.dart';
import '../auth_service.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  final TextEditingController usernameController = TextEditingController();

  final AuthService authService = AuthService();

  void register() async {
    String email = emailController.text.trim();
    String password = passwordController.text.trim();
    String confirmPassword = confirmPasswordController.text.trim();
    String username = usernameController.text.trim();

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Las contraseñas no coinciden")),
      );
      return;
    }

    var user = await authService.register(email, password, username);
    if (user != null) {
      print("Registro exitoso: ${user.email}");
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => LoginScreen()));
    } else {
      print("Error al registrarse");
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Inicio de sesión",
          style: TextStyle(fontSize: 20, color: Colors.black),
        ),
        backgroundColor: Colors.white,
      ),
      body: Container(  // Agregado Container para cambiar el color de fondo del body
        color: Colors.blue,  // Color del body
        child: SingleChildScrollView(  // Hacemos que el body sea desplazable
          child: Column(
            children: [
              // Contenedor superior con el título
              Container(
                height: screenHeight * 0.20, // 1/5 de la pantalla
                width: double.infinity,
                color: Colors.white, // Fondo blanco para el título
                alignment: Alignment.center,
                child: Text(
                  "Registro de Usuario",
                  style: TextStyle(
                    fontSize: 50,
                    fontWeight: FontWeight.bold,
                    fontStyle: FontStyle.italic,
                    color: Colors.orange,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Contenedor inferior con el formulario
              Container(
                width: MediaQuery.of(context).size.width * 0.9, // Define el ancho
                height: screenHeight * 0.69,
                color: Colors.blue, // Color de fondo
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextField(
                        controller: usernameController,
                        decoration: InputDecoration(
                            labelText: "Nombre Usuario",
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.lock_outline),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        ),                      ),
                      SizedBox(height: 30),

                      TextField(
                        controller: emailController,
                        decoration: InputDecoration(
                            labelText: "Correo Electronico",
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.lock_outline),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),

                            )
                        ),                      ),
                      SizedBox(height: 30),

                      TextField(
                        controller: passwordController,
                        decoration: InputDecoration(
                            labelText: "Contraseña",
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.lock_outline),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        ),                        obscureText: true,
                      ),
                      SizedBox(height: 30),

                      TextField(
                        controller: confirmPasswordController,
                        decoration: InputDecoration(
                            labelText: "Repetir Contraseña",
                            labelStyle: TextStyle(color: Colors.black),
                            prefixIcon: Icon(Icons.lock_outline),
                            fillColor: Colors.white,
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                            )
                        ),
                        obscureText: false,
                      ),
                      SizedBox(height: 50),

                      ElevatedButton(
                        onPressed: register,
                        style: ElevatedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.orange,
                          minimumSize: Size(double.infinity, 50), // Ancho 100% y altura 50

                        ),
                        child: Text(
                          "Crear Usuario",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
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
