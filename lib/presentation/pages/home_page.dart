import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_bloc.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    return Scaffold(
      appBar: AppBar(
        title: Text("Inicio"),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => context.read<AuthCubit>().signOut(),
          ),
        ],
      ),
      body: Center(
        child: authState.user != null
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Bienvenido, ${authState.user!.name}",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Rol: ${authState.user!.role}",
                style: TextStyle(fontSize: 18, color: Colors.blue)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => context.read<AuthCubit>().signOut(),
              child: Text("Cerrar sesión"),
            )
          ],
        )
            : CircularProgressIndicator(),
      ),
    );
  }
}