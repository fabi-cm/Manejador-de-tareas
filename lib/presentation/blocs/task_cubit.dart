import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task/add_task.dart';
import '../../domain/usecases/task/delete_task.dart';
import '../../domain/usecases/task/get_tasks_assigned_by.dart';
import '../../domain/usecases/task/update_task.dart';

/// Estado del TaskCubit
class TaskState {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? error;

  TaskState({this.tasks = const [], this.isLoading = false, this.error});

  TaskState copyWith({
    List<TaskEntity>? tasks,
    bool? isLoading,
    String? error,
  }) {
    return TaskState(
      tasks: tasks ?? this.tasks,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

/// TaskCubit que maneja las tareas
class TaskCubit extends Cubit<TaskState> {
  final AddTask addTask;
  final UpdateTask updateTask;
  final DeleteTask deleteTask;
  final GetTasksAssignedBy getTasksAssignedBy;

  TaskCubit({
    required this.addTask,
    required this.updateTask,
    required this.deleteTask,
    required this.getTasksAssignedBy,
  }) : super(TaskState());

  /// Cargar tareas asignadas por un usuario
  Future<void> loadTasks(String userId) async {
    emit(state.copyWith(isLoading: true));
    try {
      final tasks = await getTasksAssignedBy(userId);
      emit(state.copyWith(tasks: tasks, isLoading: false));
    } catch (e) {
      emit(state.copyWith(isLoading: false, error: "Error al cargar las tareas"));
    }
  }

  /// Crear una nueva tarea
  Future<void> createTask(TaskEntity task) async {
    try {
      await addTask(task);
      emit(state.copyWith(tasks: [...state.tasks, task])); // Agregar la tarea localmente
    } catch (e) {
      emit(state.copyWith(error: "Error al agregar la tarea"));
    }
  }

  /// Modificar una tarea existente
  Future<void> modifyTask(TaskEntity task) async {
    try {
      await updateTask(task);
      final updatedTasks = state.tasks.map((t) => t.id == task.id ? task : t).toList();
      emit(state.copyWith(tasks: updatedTasks));
    } catch (e) {
      emit(state.copyWith(error: "Error al actualizar la tarea"));
    }
  }

  /// Eliminar una tarea
  Future<void> removeTask(String taskId) async {
    try {
      await deleteTask(taskId);
      final updatedTasks = state.tasks.where((task) => task.id != taskId).toList();
      emit(state.copyWith(tasks: updatedTasks));
    } catch (e) {
      emit(state.copyWith(error: "Error al eliminar la tarea"));
    }
  }
}