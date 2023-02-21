import 'package:flutter/material.dart';

class CategoryModel {
  int? id;
  String? title;
  Color? color;
  double? productivityPerCentage;
  int? tasksNumber;
  List<String?>? threeLastTasksTitles;

  CategoryModel({
    this.id,
    this.color,
    this.title,
    this.productivityPerCentage,
    this.tasksNumber = 0,
    this.threeLastTasksTitles = const [null, null, null],
  });

  factory CategoryModel.fromMap(Map<String, dynamic> map) {
    return CategoryModel(
      id: map['id'],
      title: map['title'].toString(),
      color: Color(int.parse(map['color_code'])),
      productivityPerCentage: map['productivity_percentage'],
      tasksNumber: map['tasks_number'],
      threeLastTasksTitles: [
        map['last_first_task_title'],
        map['last_second_task_title'],
        map['last_third_task_title'],
      ],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'color_code': color!.value,
      'productivity_percentage': productivityPerCentage,
      'tasks_number': tasksNumber,
      'last_first_task_title': threeLastTasksTitles![0],
      'last_second_task_title': threeLastTasksTitles![1],
      'last_third_task_title': threeLastTasksTitles![2],
    };
  }
}
