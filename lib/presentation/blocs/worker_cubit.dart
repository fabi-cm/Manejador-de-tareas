import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/repositories/task_repository.dart';

abstract class WorkerState {}

class WorkerLoading extends WorkerState {}

class WorkerLoaded extends WorkerState {
  final List<Map<String, dynamic>> tasks;
  WorkerLoaded(this.tasks);
}

class WorkerError extends WorkerState {
  final String message;
  WorkerError(this.message);
}

class WorkerCubit extends Cubit<WorkerState> {
  final TaskRepository taskRepository;
  final String userId;

  WorkerCubit({required this.taskRepository, required this.userId}) : super(WorkerLoading()) {
    _fetchTasksInRealTime();
  }

  // Escuchar cambios en las tareas asignadas al trabajador
  void _fetchTasksInRealTime() {
    try {
      taskRepository.getTasksAssignedTo(userId).listen((snapshot) {
        final tasks = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            'title': data['title'],
            'description': data['description'],
            'status': data['status'],
            'priority': data['priority'].toString() ?? '0',
          };
        }).toList();

        emit(WorkerLoaded(tasks));
      });
    } catch (e) {
      emit(WorkerError("Error al cargar tareas: $e"));
    }
  }

  // Actualizar el estado de una tarea
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await taskRepository.updateTaskStatus(taskId, newStatus);
      //_fetchTasksInRealTime();
    } catch (e) {
      emit(WorkerError("Error al actualizar el estado de la tarea: $e"));
    }
  }
}