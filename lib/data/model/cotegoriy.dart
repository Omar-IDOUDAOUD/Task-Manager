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
}
