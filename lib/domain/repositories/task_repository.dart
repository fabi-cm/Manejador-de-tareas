import 'package:cloud_firestore/cloud_firestore.dart';

import '../entities/task_entity.dart';

abstract class TaskRepository {
  Future<void> addTask(TaskEntity task);
  Future<void> updateTask(TaskEntity task);
  Future<void> deleteTask(String taskId);
  Future<List<TaskEntity>> getTasksAssignedBy(String userId);
  Stream<List<TaskEntity>> fetchWorkerTasks(String workerId);
  Stream<QuerySnapshot> getTasksAssignedTo(String userId);
  Future<void> updateTaskStatus(String taskId, String newStatus);
}