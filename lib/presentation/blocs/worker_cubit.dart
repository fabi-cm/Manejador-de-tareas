import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String userId;

  WorkerCubit({required this.userId}) : super(WorkerLoading()) {
    _fetchTasksInRealTime();
  }

  // Escuchar cambios en las tareas asignadas al trabajador
  void _fetchTasksInRealTime() {
    try {
      _firestore
          .collection('tasks')
          .where('assignedTo', isEqualTo: userId)
          .snapshots()
          .listen((snapshot) {
        final tasks = snapshot.docs.map((doc) {
          final data = doc.data();
          return {
            'id': doc.id, // ID de la tarea
            'title': data['title'],
            'description': data['description'],
            'assignedTo': data['assignedTo'],
            'assignedBy': data['assignedBy'],
            'status': data['status'],
            'priority': data['priority'],
            'timestamp': data['timestamp'],
          };
        }).toList();

        emit(WorkerLoaded(tasks)); // Emitir el estado con las tareas cargadas
      });
    } catch (e) {
      emit(WorkerError("Error al cargar tareas: $e"));
    }
  }

  // Actualizar el estado de una tarea
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({
        'status': newStatus,
      });
    } catch (e) {
      emit(WorkerError("Error al actualizar el estado de la tarea: $e"));
    }
  }
}