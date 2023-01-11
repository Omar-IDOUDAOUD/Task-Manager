class TaskModel {
  final int id;
  final DateTime creationDate;
  final String title;
  final String? descreption;
  final TaskPriorities? priority;
  final DateTime? terminationDate;
  final int categoryId;

  TaskModel({
    required this.id,
    required this.creationDate,
    required this.title,
    this.descreption,
    this.priority,
    this.terminationDate,
    required this.categoryId,
  });
}

enum TaskPriorities { high, medium, low }
