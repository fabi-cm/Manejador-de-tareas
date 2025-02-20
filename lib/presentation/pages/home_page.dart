import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
//import '../../screens/admin_screen.dart';
import 'admin_screen.dart';
import '../../screens/manager_screen.dart';
//import '../../screens/worker_screen.dart';
import 'worker_screen.dart';
import '../blocs/auth_cubit.dart'; // Asegúrate de tener un AuthCubit

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: BlocBuilder<AuthCubit, AuthState>(
        builder: (context, state) {
          if (state is Authenticated) {
            if (state.role == "administrador") {
              return AdminScreen();  // Redirige a la pantalla de Administrador
            } else if (state.role == "encargado") {
              return ManagerScreen();  // Redirige a la pantalla de Encargado
            } else {
              return WorkerScreen();  // Redirige a la pantalla de Trabajador
            }
          } else if (state is AuthLoading) {
            return const Center(child: CircularProgressIndicator());
          } else {
            return const Center(child: Text("Error al cargar datos."));
          }
        },
      ),
    );
  }
}
