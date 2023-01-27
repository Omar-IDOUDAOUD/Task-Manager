import 'dart:math';

import 'package:get/get.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/data/provider/categories_provider.dart';
import 'package:task_manager/data/provider/tasks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const TODAYS_TASKS_LIST_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";
const ALL_TASKS_WID_ID = "ALL_TASKS_WID_ID";
const CATEGORIES_WID_ID = "CATEGORIES_WID_ID";
const CATEGORYTASKS_WID_ID = "CATEGORYTASKS_WID_ID";

class TasksController extends GetxController {
  final TasksProvider _tasksProvider = TasksProvider();
  final CategoriesProvider _categoriesProvider = CategoriesProvider();
  List<TaskModel>? _todayTasks;
  List<TaskModel>? _allTasks;
  List<CategoryModel>? _categories;
  List<TaskModel>? _completedTasks;
  RxInt todayTasksNumber = 0.obs;
  RxInt allTasksNumber = 0.obs;
  late final SharedPreferences _preferences;

  @override
  void onInit() async {
    super.onInit();
    print("LOG: onInit called");
    _preferences = await SharedPreferences.getInstance();
    print('checkpoint ppp');
    allTasksNumber = _preferences.getInt('ALL_TASKS_NUMBER')!.obs;
    todayTasksNumber = _preferences.getInt('TODAYS_TASKS_NUMBER')!.obs;
  }

  @override
  void onClose() {
    super.onClose();
    print('LOG: onClose called');
    _preferences.setInt('ALL_TASKS_NUMBER', allTasksNumber.value);
    _preferences.setInt('TODAYS_TASKS_NUMBER', todayTasksNumber.value);
  }

  Future<List<TaskModel>> getTodaysTasks() async {
    await _tasksProvider.init();
    await _categoriesProvider.init();

    _allTasks = _todayTasks = _categories = null;

    if (_todayTasks == null) {
      _todayTasks = await _tasksProvider.readTasks();
      for (var i = 0; i < _todayTasks!.length; i++) {
        if (_todayTasks!.elementAt(i).categoryTitle != null) continue;
        final category = (await _categoriesProvider.readCategories(
                where: 'id = ?',
                whereArgs: [_todayTasks![i].categoryId],
                columns: ['title', 'color_code']))
            .first;
        _todayTasks![i]
          ..categoryTitle = category.title
          ..categoryColor = category.color;
        await _tasksProvider.updateTask(_todayTasks!.elementAt(i).id!,
            (oldData) => _todayTasks!.elementAt(i));
      }
    }
    todayTasksNumber.value = _todayTasks!.length;
    return _todayTasks!;
  }

  Future<List<TaskModel>> getAllTasks() async {
    _todayTasks = _categories = _allTasks = null;

    if (_allTasks == null) {
      _allTasks = await _tasksProvider.readTasks();
      for (var i = 0; i < _allTasks!.length; i++) {
        if (_allTasks!.elementAt(i).categoryTitle != null) continue;
        final category = (await _categoriesProvider.readCategories(
                where: 'id = ?',
                whereArgs: [_allTasks![i].categoryId],
                columns: ['title', 'color_code']))
            .first;
        _allTasks![i]
          ..categoryTitle = category.title
          ..categoryColor = category.color;
        await _tasksProvider.updateTask(
          _allTasks!.elementAt(i).id!,
          (oldData) => _allTasks!.elementAt(i),
        );
      }
    }
    allTasksNumber.value = _allTasks!.length;
    return _allTasks!;
  }

  Future<List<CategoryModel>> getCategories() async {
    if (_categories == null) {
      _categories = await _categoriesProvider.readCategories();
      for (var i = 0; i < _categories!.length; i++) {
        final titles = (await _tasksProvider.readTasks(
          where: 'category_id = ?',
          whereArgs: [_categories!.elementAt(i).id],
          groupBy: 'id',
          orderBy: 'id DESC',
          limit: 3,
        ))
            .map((e) => e.title)
            .toList();
        for (var i2 = 0; i2 < titles.length; i2++) {
          _categories![i].threeLastTasksTitles![i2] = titles.elementAt(i2);
          print('d');
        }
        final allTasksNumber = int.parse((await _tasksProvider.db!.rawQuery(
                'SELECT count(`id`) as c from `${_tasksProvider.tableName}` where category_id = ${_categories![i].id}'))
            .first['c']
            .toString());
        final completedTasksNumber = int.parse((await _tasksProvider.db!.rawQuery(
                'SELECT count(`id`) as c from `${_tasksProvider.tableName}` where category_id = ${_categories![i].id} and completed = 1'))
            .first['c']
            .toString());
        _categories![i].tasksNumber = allTasksNumber;
        _categories![i].productivityPerCentage = allTasksNumber != 0
            ? completedTasksNumber * 100 / allTasksNumber
            : 0;
        _categoriesProvider.updateCategory(_categories!.elementAt(i).id!,
            (oldData) => _categories!.elementAt(i));
      }
    }
    return _categories!;
  }

  Future<List<TaskModel>> getCategoryTasks(int categoryId) async {
    final List<TaskModel> categoryTasks = await _tasksProvider
        .readTasks(where: 'category_id = ?', whereArgs: [categoryId]);

    for (var i = 0; i < categoryTasks.length; i++) {
      if (categoryTasks.elementAt(i).categoryTitle != null) continue;
      final category = (await _categoriesProvider.readCategories(
              where: 'id = ?',
              whereArgs: [categoryTasks.elementAt(i).categoryId],
              columns: ['title', 'color_code']))
          .first;
      categoryTasks[i]
        ..categoryTitle = category.title
        ..categoryColor = category.color;
      _tasksProvider.updateTask(categoryTasks.elementAt(i).id!,
          (oldData) => categoryTasks.elementAt(i));
    }
    return categoryTasks;
  }

  Future<List<TaskModel>> getCompletedTasks() async {
    await _tasksProvider.init();
    _completedTasks = await _tasksProvider
        .readTasks(where: 'completed = ?', whereArgs: ['1']);
    return _completedTasks!;
  }
}
