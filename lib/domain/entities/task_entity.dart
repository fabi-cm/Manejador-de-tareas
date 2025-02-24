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

  TaskEntity copyWith({
    String? id,
    String? title,
    String? description,
    String? assignedTo,
    String? status,
    int? priority,
    String? createdBy,
    DateTime? timestamp,
  }) {
    return TaskEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      assignedTo: assignedTo ?? this.assignedTo,
      status: status ?? this.status,
      priority: priority ?? this.priority,
      createdBy: createdBy ?? this.createdBy,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}