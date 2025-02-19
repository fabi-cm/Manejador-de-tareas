import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:task_manager/presentation/blocs/task_cubit.dart';
import '../presentation/blocs/auth_cubit.dart';

class ManagerScreen extends StatelessWidget {
  const ManagerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.read<AuthCubit>().state;

    if (authState is! Authenticated || authState.role != "encargado") {
      return const Scaffold(
        body: Center(child: Text("No tienes permisos para acceder a esta página.")),
      );
    }

    final userId = authState.user.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Panel de Encargado"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().logout(),
          ),
        ],
      ),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, taskState) {
          if (taskState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (taskState.error != null) {
            return Center(child: Text(taskState.error!));
          }
          if (taskState.tasks.isEmpty) {
            return const Center(child: Text("No hay tareas asignadas."));
          }

          return ListView.builder(
            itemCount: taskState.tasks.length,
            itemBuilder: (context, index) {
              final task = taskState.tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text("Prioridad: ${task.priority}"),
                trailing: PopupMenuButton(
                  onSelected: (value) {
                    if (value == "edit") {
                      // Implementar edición
                    } else if (value == "delete") {
                      context.read<TaskCubit>().removeTask(task.id, userId);
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(value: "edit", child: Text("Editar")),
                    const PopupMenuItem(value: "delete", child: Text("Eliminar")),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Implementar la creación de nuevas tareas
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}