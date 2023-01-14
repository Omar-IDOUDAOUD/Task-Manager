class TaskModel {
  int id;
  DateTime creationDate;
  String title;
  String? descreption;
  TaskPriorities? priority;
  DateTime? terminationDate;
  DateTime? completeionDate;
  bool completed;
  int categoryId;

  TaskModel({
    required this.id,
    required this.creationDate,
    required this.title,
    this.descreption,
    this.priority,
    this.terminationDate,
    this.completeionDate,
    this.completed = false,
    required this.categoryId,
  });

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      creationDate: map['creation_date'],
      title: map['title'],
      descreption: map['descreption'],
      priority: TaskPriorities.values.elementAt(map['priority'] as int), 
      terminationDate: map['termination_date'],
      completeionDate: map['completeion_date'],
      completed: map['completed'],
      categoryId: map['category_id'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creation_date': creationDate,
      'title': title,
      'descreption': descreption,
      'priority': priority?.index,
      'termination_date': terminationDate,
      'completeion_date': completeionDate,
      'completed': completed,
      'category_id': categoryId,
    };
  }

}

enum TaskPriorities { high, medium, low }
