import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/model/task.dart';

const TODAYS_TASKS_LIST_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";
const ALL_TASKS_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";
const CATEGORIES_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";
const CATEGORYTASKS_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";

class TasksController extends GetxController {
  List<TaskModel>? _todayTasks;
  List<TaskModel>? _allTasks;

  Future<List<TaskModel>> getTodaysTasks() {
    return Future.delayed(200.milliseconds).then(
      (value) => [
        TaskModel(
          id: 2,
          creationDate: DateTime.now(),
          title: 'today task',
          descreption: 'a descreption',
          priority: TaskPriorities.low,
          categoryId: 2,
        ),
      ],
    );
  }

  Future<List<TaskModel>> getAllTasks() {
    return Future.delayed(200.milliseconds).then(
      (value) => [
        TaskModel(
          id: 2,
          creationDate: DateTime.now(),
          title: 'today task',
          descreption: 'a descreption',
          priority: TaskPriorities.low,
          categoryId: 2,
        ),
        TaskModel(
          id: 2,
          creationDate: DateTime.now(),
          title: 'today task',
          descreption: 'a descreption',
          priority: TaskPriorities.low,
          categoryId: 2,
        ),
      ],
    );
  }

  Future<List<CategoryModel>> getCategories() {
    return Future.delayed(200.milliseconds).then(
      (value) => [
        CategoryModel(id: 0, color: Colors.blue, title: 'Work'), 
        CategoryModel(id: 0, color: Colors.red, title: 'Study'), 
      ],
    );
  }

    Future<List<CategoryModel>> getCategoryTasks(int categoryId) {
    return Future.delayed(200.milliseconds).then(
      (value) => [
        CategoryModel(id: 0, color: Colors.blue, title: 'Work'), 
        CategoryModel(id: 0, color: Colors.red, title: 'Study'), 
      ],
    );
  }
}
