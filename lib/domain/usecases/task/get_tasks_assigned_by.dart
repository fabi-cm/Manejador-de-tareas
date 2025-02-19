import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

class GetTasksAssignedBy {
  final TaskRepository repository;
  GetTasksAssignedBy(this.repository);

  Future<List<TaskEntity>> call(String userId) async {
    return repository.getTasksAssignedBy(userId);
  }
}