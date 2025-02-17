import 'package:flutter/material.dart';
import '../auth_service.dart';

class HomeScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Inicio"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () {
              authService.logout();
              Navigator.pop(context);
            },
          )
        ],
      ),
      body: Center(child: Text("Bienvenido a la app")),
    );
  }
}
