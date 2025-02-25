import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
import '../blocs/auth_cubit.dart';
import '../blocs/worker_cubit.dart';
import '../widgets/task_item.dart';

class WorkerScreen extends StatelessWidget {
  const WorkerScreen({super.key});

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

    return BlocProvider(
      create: (context) => WorkerCubit(
        taskRepository: TaskRepositoryImpl(),
        userId: authState.user.uid,
      ),
      child: Scaffold(
        appBar: AppBar(
          title: Text("Mis Tareas - ${authState.username ?? 'Usuario'}"),
          actions: [
            IconButton(
              icon: const Icon(Icons.logout),
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
              return ListView.builder(
                itemCount: tasks.length,
                itemBuilder: (context, index) {
                  final task = tasks[index];
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