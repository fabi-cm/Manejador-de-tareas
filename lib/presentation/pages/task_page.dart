import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../blocs/task_cubit.dart';

class TaskPage extends StatelessWidget {
  final String userId; // El Encargado que asigna las tareas

  const TaskPage({super.key, required this.userId});

  @override
  Widget build(BuildContext context) {
    final taskCubit = context.read<TaskCubit>();

    return Scaffold(
      appBar: AppBar(title: Text("Tareas Asignadas")),
      body: BlocBuilder<TaskCubit, TaskState>(
        builder: (context, state) {
          if (state.isLoading) return Center(child: CircularProgressIndicator());
          if (state.error != null) return Center(child: Text(state.error!));

          return ListView.builder(
            itemCount: state.tasks.length,
            itemBuilder: (context, index) {
              final task = state.tasks[index];
              return ListTile(
                title: Text(task.title),
                subtitle: Text("Estado: ${task.status}"),
                trailing: IconButton(
                  icon: Icon(Icons.delete, color: Colors.red),
                  onPressed: () => taskCubit.removeTask(task.id),
                ),
              );
            },
          );
        },
      ),
    );
  }
}