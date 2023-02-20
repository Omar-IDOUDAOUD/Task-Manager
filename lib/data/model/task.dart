import 'package:flutter/material.dart';

class TaskModel {
  int? id;
  DateTime? creationDate;
  String? title;
  String? description;
  TaskPriorities? priority;
  DateTime? terminationDate;
  DateTime? completionDate;
  bool? completed;
  int? categoryId;
  bool? sendAlert; 
  /**those properties is initialed whene this model is being to send to view*/
  String? categoryTitle;
  Color? categoryColor;

  TaskModel({
    this.id,
    this.creationDate,
    this.title,
    this.description,
    this.priority,
    this.terminationDate,
    this.completionDate,
    this.completed = false,
    this.categoryId = 1,
    this.categoryColor,
    this.categoryTitle,
    this.sendAlert = true, 
  }) {
    final now = DateTime.now();
    creationDate ??= now;
  }
  

  factory TaskModel.fromMap(Map<String, dynamic> map) {
    return TaskModel(
      id: map['id'],
      creationDate: DateTime.parse(map['creation_date']),
      title: map['title'].toString(),
      description: map['description'].toString(),
      priority: map['priority'] != null
          ? TaskPriorities.values.elementAt(map['priority'])
          : null,
      terminationDate: map['termination_date'] != null
          ? DateTime.parse(map['termination_date'])
          : null,
      completionDate: map['completion_date'] != null
          ? DateTime.parse(map['completion_date'])
          : null,
      completed: map['completed'] == 1,
      categoryId: map['category_id'],
      categoryTitle: map['category_title'].toString(),
      categoryColor: map['category_color_code'] != null
          ? Color(int.parse(map['category_color_code']))
          : null,
      sendAlert: map['send_alert'] == 1, 
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'creation_date': creationDate!.toIso8601String(),
      'title': title,
      'description': description,
      'priority': priority?.index,
      'termination_date': terminationDate?.toIso8601String(),
      'completion_date': completionDate?.toIso8601String(),
      'completed': completed! ? 1 : 0,
      'category_id': categoryId,
      'category_title': categoryTitle,
      'category_color_code':
          categoryColor != null ? categoryColor!.value : null,
      'send_alert': sendAlert! ? 1 : 0, 
    };
  }
}

enum TaskPriorities { low, medium, high }
