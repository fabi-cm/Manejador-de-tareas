import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/usecases/task/add_task.dart';
import '../../domain/usecases/task/delete_task.dart';
import '../../domain/usecases/task/get_tasks_assigned_by.dart';
import '../../domain/usecases/task/update_task.dart';

class TaskState {
  final List<TaskEntity> tasks;
  final bool isLoading;
  final String? error;

  TaskState({this.tasks = const [], this.isLoading = false, this.error});
}

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

  Future<void> loadTasks(String userId) async {
    emit(TaskState(isLoading: true));
    try {
      final tasks = await getTasksAssignedBy(userId);
      emit(TaskState(tasks: tasks));
    } catch (e) {
      emit(TaskState(error: "Error al cargar las tareas"));
    }
  }

  Future<void> createTask(TaskEntity task) async {
    try {
      await addTask(task);
      loadTasks(task.assignedTo); // Recargar las tareas
    } catch (e) {
      emit(TaskState(error: "Error al agregar la tarea"));
    }
  }

  Future<void> modifyTask(TaskEntity task) async {
    try {
      await updateTask(task);
      loadTasks(task.assignedTo);
    } catch (e) {
      emit(TaskState(error: "Error al actualizar la tarea"));
    }
  }

  Future<void> removeTask(String taskId, String userId) async {
    try {
      await deleteTask(taskId);
      loadTasks(userId);
    } catch (e) {
      emit(TaskState(error: "Error al eliminar la tarea"));
    }
  }
}
