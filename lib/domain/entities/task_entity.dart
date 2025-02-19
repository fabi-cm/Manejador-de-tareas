class TaskEntity {
  final String id;
  final String title;
  final String description;
  final String assignedTo;
  final String status;
  final int priority;
  final String createdBy;
  final DateTime timestamp;

  TaskEntity({
    required this.id,
    required this.title,
    required this.description,
    required this.assignedTo,
    required this.status,
    required this.priority,
    required this.createdBy,
    required this.timestamp,
  });
}