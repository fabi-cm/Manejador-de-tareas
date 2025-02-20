import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/auth_cubit.dart';

class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  // Función para cambiar el estado de la tarea
  Future<void> _updateTaskStatus(String taskId, String currentStatus) async {
    String newStatus;
    switch (currentStatus) {
      case 'Pendiente':
        newStatus = 'En progreso';
        break;
      case 'En progreso':
        newStatus = 'Completado';
        break;
      default:
        newStatus = 'Pendiente';
    }

    try {
      await FirebaseFirestore.instance.collection('tasks').doc(taskId).update({'status': newStatus});
    } catch (e) {
      print('Error al actualizar el estado: $e');
    }
  }

  // Obtener el color basado en el estado
  Color _getStatusColor(String status) {
    switch (status) {
      case 'Pendiente':
        return Colors.red;
      case 'En progreso':
        return Colors.blue;
      case 'Completado':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;

    if (authState is! Authenticated || authState.role != "trabajador") {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "No tienes permisos para acceder a esta página.",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => context.read<AuthCubit>().logout(context),
                child: const Text("Cerrar sesión"),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text("Mis Tareas - ${authState.username ?? 'Usuario'}"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(context),
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('tasks')
            .where('assignedTo', isEqualTo: authState.user.uid) // Filtra por trabajador autenticado
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(child: Text("No tienes tareas asignadas"));
          }

          var tasks = snapshot.data!.docs;

          return ListView.builder(
            itemCount: tasks.length,
            itemBuilder: (context, index) {
              var task = tasks[index];
              String taskId = task.id;
              String title = task['title'];
              String description = task['description'];
              String status = task['status']; // Estado actual de la tarea

              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                elevation: 3,
                child: ListTile(
                  leading: const Icon(Icons.assignment, color: Colors.blue),
                  title: Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  subtitle: Text(description),
                  trailing: ElevatedButton(
                    onPressed: () => _updateTaskStatus(taskId, status),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _getStatusColor(status),
                      foregroundColor: Colors.white,
                    ),
                    child: Text(status),
                  ),
                  contentPadding: const EdgeInsets.all(16),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
