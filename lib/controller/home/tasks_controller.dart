import 'dart:math';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/data/provider/categories_provider.dart';
import 'package:task_manager/data/provider/tasks_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

const TODAYS_TASKS_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";
const ALL_TASKS_WID_ID = "ALL_TASKS_WID_ID";
const CATEGORIES_WID_ID = "CATEGORIES_WID_ID";
const CATEGORYTASKS_WID_ID = "CATEGORYTASKS_WID_ID";
const COMPLETED_TASKS_WID_ID = "COMPLETED_TASKS_WID_ID";

class TasksController extends GetxController {
  final TasksProvider _tasksProvider = TasksProvider();
  final CategoriesProvider _categoriesProvider = CategoriesProvider();
  List<TaskModel> _todayTasks = [];
  List<TaskModel> _allTasks = [];
  List<CategoryModel> _categories = [];
  List<TaskModel> _completedTasks = [];
  int _completedTabPaginationOffset = 0;
  int _tasksTabTodayTasksPaginationOffset = 0;
  int _tasksTabAllTasksPaginationOffset = 0;
  int _tasksTabCategoriesPaginationOffset = 0;
  final ScrollController completedTasksTabScrollConntroller =
      ScrollController();
  final ScrollController tasksTabToaysTasksScrollController =
      ScrollController();
  final ScrollController tasksTabAllTasksScrollController = ScrollController();
  final ScrollController tasksTabCategoriesScrollController =
      ScrollController();
  RxInt todayTasksNumber = 0.obs;
  RxInt allTasksNumber = 0.obs;
  late final SharedPreferences _preferences;
  bool? canLoadMoreDataInTodaysTasksPart;
  bool? canLoadMoreDataInAllTasksPart;
  bool? canLoadMoreDataInCategoriesPart;

  @override
  void onInit() async {
    super.onInit();
    print("LOG: onInit called");
    completedTasksTabScrollConntroller
      ..addListener(
        () {
          if ((completedTasksTabScrollConntroller.position.maxScrollExtent -
                  completedTasksTabScrollConntroller.offset) <
              20) {
            update([COMPLETED_TASKS_WID_ID]);
          }
        },
      );
    tasksTabToaysTasksScrollController.addListener(() {
      if ((tasksTabToaysTasksScrollController.position.maxScrollExtent -
              tasksTabToaysTasksScrollController.offset) <
          20) {
        update([TODAYS_TASKS_WID_ID]);
      }
    });
    tasksTabAllTasksScrollController.addListener(() {
      if ((tasksTabAllTasksScrollController.position.maxScrollExtent -
              tasksTabAllTasksScrollController.offset) <
          20) {
        update([ALL_TASKS_WID_ID]);
      }
    });
    tasksTabCategoriesScrollController.addListener(() {
      if ((tasksTabCategoriesScrollController.position.maxScrollExtent -
              tasksTabCategoriesScrollController.offset) <
          20) {
        update([CATEGORIES_WID_ID]);
      }
    });
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

  Future<List<TaskModel>> getTodaysTasks(bool loadMoreData) async {
    await _tasksProvider.init();
    await _categoriesProvider.init();

    // await Future.delayed(4.seconds);

    if (!loadMoreData) return _todayTasks;
    final paginated_data = await _tasksProvider.readTasks(
        limit: 10, offset: _tasksTabTodayTasksPaginationOffset);
    _tasksTabTodayTasksPaginationOffset += 10;
    _todayTasks.addAll(paginated_data);
    todayTasksNumber.value = _todayTasks.length;
    return _todayTasks;
  }

  Future<List<TaskModel>> getAllTasks(bool loadMoreData) async {
    if (!loadMoreData) return _allTasks;
    final paginated_data = await _tasksProvider.readTasks(
        limit: 10, offset: _tasksTabAllTasksPaginationOffset);
    _tasksTabAllTasksPaginationOffset += 10;
    _allTasks.addAll(paginated_data);
    allTasksNumber.value = _allTasks.length;
    return _allTasks;
  }

  Future<List<CategoryModel>> getCategories(bool loadMoreData) async {
    if (!loadMoreData) return _categories;
    final paginated_data = await _categoriesProvider.readCategories(
        limit: 10, offset: _tasksTabCategoriesPaginationOffset);
    for (var i = 0; i < paginated_data.length; i++) {
      final titles = (await _tasksProvider.readTasks(
        where: 'category_id = ?',
        whereArgs: [paginated_data.elementAt(i).id],
        groupBy: 'id',
        orderBy: 'id DESC',
        limit: 3,
      ))
          .map((e) => e.title)
          .toList();
      for (var i2 = 0; i2 < titles.length; i2++) {
        paginated_data[i].threeLastTasksTitles![i2] = titles.elementAt(i2);
        print('d');
      }
      final allTasksNumber = int.parse((await _tasksProvider.db!.rawQuery(
              'SELECT count(`id`) as c from `${_tasksProvider.tableName}` where category_id = ${paginated_data[i].id}'))
          .first['c']
          .toString());
      final completedTasksNumber = int.parse((await _tasksProvider.db!.rawQuery(
              'SELECT count(`id`) as c from `${_tasksProvider.tableName}` where category_id = ${paginated_data[i].id} and completed = 1'))
          .first['c']
          .toString());
      paginated_data[i].tasksNumber = allTasksNumber;
      paginated_data[i].productivityPerCentage =
          allTasksNumber != 0 ? completedTasksNumber * 100 / allTasksNumber : 0;
      // _categoriesProvider.updateCategory(paginated_data.elementAt(i).id!,
      //     (oldData) => paginated_data.elementAt(i));
    }
    _tasksTabCategoriesPaginationOffset += 10;
    _categories.addAll(paginated_data);
    return _categories;
  }

  Future<List<TaskModel>> getCategoryTasks(int categoryId) async {
    final List<TaskModel> categoryTasks = await _tasksProvider
        .readTasks(where: 'category_id = ?', whereArgs: [categoryId]);

    return categoryTasks;
  }

  Future<List<TaskModel>> getCompletedTasks(bool loadMoreData) async {
    await _tasksProvider.init();

    if (!loadMoreData) return _completedTasks;
    final paginated_data = await _tasksProvider.readTasks(
        where: 'completed = ?',
        whereArgs: ['1'],
        limit: 10,
        offset: _completedTabPaginationOffset);
    _completedTabPaginationOffset += 10;
    _completedTasks.addAll(paginated_data);
    return _completedTasks;
  }

  Future<void> createTask(TaskModel data) async {
    final category = (await _categoriesProvider.readCategories(
            where: 'id = ?',
            whereArgs: [data.categoryId],
            columns: ['title', 'color_code']))
        .first;
    data
      ..categoryTitle = category.title
      ..categoryColor = category.color;
    _tasksProvider.createTask(data);
  }
}
