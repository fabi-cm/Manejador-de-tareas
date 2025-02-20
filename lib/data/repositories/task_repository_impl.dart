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
      'assigned_to': task.assignedTo,
      'status': task.status,
      'priority': task.priority,
      'created_by': task.createdBy,
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
        .where('created_by', isEqualTo: userId)
        .get();

    return querySnapshot.docs.map((doc) {
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

}
