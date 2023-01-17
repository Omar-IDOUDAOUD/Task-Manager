import 'package:flutter/material.dart';
import 'package:task_manager/data/model/task.dart';

class CategoryModel {
  int? id;
  String title;
  Color color;
  double? productivityPerCentage;
  int tasksNumber;

  CategoryModel({
    this.id,
    required this.color,
    required this.title,
    this.productivityPerCentage,
    this.tasksNumber = 0,
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      title: map['title'],
      color: Color(int.parse(map['color_code'])),
      productivityPerCentage: map['productivity_percentage'],
      tasksNumber: map['tasks_number'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id' : id, 
      'title': title,
      'color_code': color.value,
      'productivity_percentage': productivityPerCentage,
      'tasks_number': tasksNumber,
    };
  }
}
