import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/worker_cubit.dart';
import '../widgets/task_item.dart';

class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authState = context.watch<AuthCubit>().state;
    String? username;
    if (authState is Authenticated) {
      username = authState.username;
    }

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

    return BlocProvider(
      create: (context) => WorkerCubit(
        taskRepository: TaskRepositoryImpl(),
        userId: authState.user.uid,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Row(
            children: [
              Icon(Icons.person),
              SizedBox(width: 10),
              Text(
                '$username',
                style: TextStyle(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout_rounded),
              onPressed: () => context.read<AuthCubit>().logout(context),
            ),
          ],
        ),
        body: BlocBuilder<WorkerCubit, WorkerState>(
          builder: (context, state) {
            if (state is WorkerLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is WorkerLoaded) {
              final tasks = state.tasks;

              // Separar tareas completadas de tareas activas
              final activeTasks = tasks.where((task) => task['status'] != 'completado').toList();
              final completedTasks = tasks.where((task) => task['status'] == 'completado').toList();

              return Column(
                children: [
                  Text(
                    "Mis Tareas",
                    style: TextStyle(
                      fontSize: 40,
                      fontFamily: 'italiano',
                      color: Colors.orange,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      decorationColor: Colors.orange,
                      decorationThickness: 2,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                        decoration: TextDecoration.underline,
                        decorationColor: Colors.black,
                        decorationThickness: 2,
                        fontWeight: FontWeight.bold,
                        fontStyle: FontStyle.italic,
                      ),
                      children: [
                        TextSpan(text: 'Completado '),
                        WidgetSpan(
                          child: Icon(Icons.check_circle, color: Colors.green, size: 16),
                        ),
                        TextSpan(text: ' En proceso '),
                        WidgetSpan(
                          child: Icon(Icons.work, color: Colors.blue, size: 16),
                        ),
                        TextSpan(text: ' Pendiente '),
                        WidgetSpan(
                          child: Icon(Icons.hourglass_full, color: Colors.red, size: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  Expanded(
                    child: ListView.builder(
                      itemCount: activeTasks.length,
                      itemBuilder: (context, index) {
                        final task = activeTasks[index];
                        return TaskItem(
                          taskId: task['id'],
                          title: task['title'],
                          description: task['description'],
                          status: task['status'],
                          priority: task['priority'].toString(),
                          onUpdateStatus: (taskId, newStatus) {
                            context.read<WorkerCubit>().updateTaskStatus(taskId, newStatus);
                          },
                        );
                      },
                    ),
                  ),
                  if (completedTasks.isNotEmpty)
                    ExpansionTile(
                      collapsedIconColor: Colors.green,
                      collapsedTextColor: Colors.green,
                      title: Text(
                        "Tareas Completadas (${completedTasks.length})",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, fontStyle: FontStyle.italic),
                      ),
                      children: [
                        SizedBox(
                          height: 300, // Ajusta la altura según lo necesites
                          child: ListView.builder(
                            itemCount: completedTasks.length,
                            itemBuilder: (context, index) {
                              final task = completedTasks[index];
                              return TaskItem(
                                taskId: task['id'],
                                title: task['title'],
                                description: task['description'],
                                status: task['status'],
                                priority: task['priority'].toString(),
                                onUpdateStatus: (taskId, newStatus) {
                                  context.read<WorkerCubit>().updateTaskStatus(taskId, newStatus);
                                },
                              );
                            },
                          ),
                        )

                      ],
                    ),
                ],
              );
            } else if (state is WorkerError) {
              return Center(child: Text(state.message));
            } else {
              return const Center(child: Text("Estado desconocido"));
            }
          },
        ),
      ),
    );
  }
}