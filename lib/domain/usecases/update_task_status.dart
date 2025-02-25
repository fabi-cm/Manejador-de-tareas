//import '../../data/repositories/task_repository_impl.dart';
import '../../domain/repositories/task_repository.dart';
class UpdateTaskStatus {
  //final TaskRepositoryImpl repository;
    final TaskRepository repository;
  UpdateTaskStatus(this.repository);

  Future<void> call(String taskId, String newStatus) async {
    return await repository.updateTaskStatus(taskId, newStatus);
  }
}