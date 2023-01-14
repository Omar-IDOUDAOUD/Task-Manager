import 'package:flutter/material.dart';
import 'package:task_manager/data/model/task.dart';

class CategoryModel {
  final int id;
  final String title;
  final Color color;
  double? productivityPerCentag;
  int tasksNumber ; 

  CategoryModel({
    required this.id,
    required this.color,
    required this.title,
    this.productivityPerCentag,
    this.tasksNumber = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      title: map['title'],
      color: Color(map['color']),
      productivityPerCentag: map['productivity_percentage'],
      tasksNumber: map['tasks_number'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color': color.value,
      'productivity_percentage': productivityPerCentag,
      'tasks_number': tasksNumber,
    };
  }


}
