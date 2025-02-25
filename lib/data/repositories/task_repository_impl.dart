import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/task_entity.dart';
import '../../domain/repositories/task_repository.dart';

class TaskRepositoryImpl implements TaskRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  Future<void> addTask(TaskEntity task) async {
    await _firestore.collection('tasks').doc(task.id).set({
      'title': task.title,
      'description': task.description,
      'assignedTo': task.assignedTo,
      'status': task.status,
      'priority': task.priority,
      'createdBy': task.createdBy,
      'timestamp': task.timestamp.millisecondsSinceEpoch,
    });
  }

  @override
  Future<void> updateTask(TaskEntity task) async {
    await _firestore.collection('tasks').doc(task.id).update({
      'title': task.title,
      'description': task.description,
      'status': task.status,
      'priority': task.priority,
    });
  }

  @override
  Future<void> deleteTask(String taskId) async {
    await _firestore.collection('tasks').doc(taskId).delete();
  }

  @override
  Future<List<TaskEntity>> getTasksAssignedBy(String userId) async {
    final querySnapshot = await _firestore
        .collection('tasks')
        .where('createdBy', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
      final data = doc.data();
      return TaskEntity(
        id: doc.id,
        title: data['title'],
        description: data['description'],
        assignedTo: data['assignedTo'],
        status: data['status'],
        priority: data['priority'],
        createdBy: data['createdBy'],
        timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
      );
    }).toList();
  }

  @override
  Stream<List<TaskEntity>> fetchWorkerTasks(String workerId) {
    return _firestore
        .collection('tasks')
        .where('assigned_to', isEqualTo: workerId) // Filtrar tareas por trabajador asignado
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        return TaskEntity(
          id: doc.id,
          title: data['title'],
          description: data['description'],
          assignedTo: data['assigned_to'],
          status: data['status'],
          priority: data['priority'],
          createdBy: data['created_by'],
          timestamp: DateTime.fromMillisecondsSinceEpoch(data['timestamp']),
        );
      }).toList();
    });
  }

  // Obtener tareas asignadas a un trabajador en tiempo real
  Stream<QuerySnapshot> getTasksAssignedTo(String userId) {
    return _firestore
        .collection('tasks')
        .where('assignedTo', isEqualTo: userId)
        .orderBy('priority') // Ordenar por estado
        .snapshots();
  }

  // Actualizar el estado de una tarea
  Future<void> updateTaskStatus(String taskId, String newStatus) async {
    try {
      await _firestore.collection('tasks').doc(taskId).update({'status': newStatus});
    } catch (e) {
      throw Exception("Error al actualizar el estado de la tarea: $e");
    }
  }

}
