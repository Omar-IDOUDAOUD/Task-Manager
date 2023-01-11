import 'package:task_manager/data/model/task.dart';

class CompletedTaskModel {
  final int id;
  final DateTime creationDate;
  final String title;
  final String? descreption;
  final TaskPriorities? priority;
  final DateTime? terminationDate;
  final DateTime completeionDate;
  final int categoryId;

  CompletedTaskModel({
    required this.id,
    required this.creationDate,
    required this.title,
    this.descreption,
    this.priority,
    this.terminationDate,
    required this.completeionDate,
    required this.categoryId,
  });
}
