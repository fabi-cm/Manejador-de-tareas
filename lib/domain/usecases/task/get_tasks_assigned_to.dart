import '../../entities/task_entity.dart';
import '../../repositories/task_repository.dart';

class GetTasksAssignedTo {
  final TaskRepository repository;

  GetTasksAssignedTo(this.repository);

  Stream<List<TaskEntity>> call(String workerId) {
    return repository.fetchWorkerTasks(workerId);
  }
}
