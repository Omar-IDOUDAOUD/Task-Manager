
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
  final List<TaskModel> _todayTasks = [];
  final List<TaskModel> _allTasks = [];
  final List<CategoryModel> _categories = [];
  final List<TaskModel> _completedTasks = [];
  final List<TaskModel> _categoryTasks = [];
  int _completedTabPaginationOffset = 0;
  int _tasksTabTodayTasksPaginationOffset = 0;
  int _tasksTabAllTasksPaginationOffset = 0;
  int _tasksTabCategoriesPaginationOffset = 0;
  int _categoryTasksPagintionOffset = 0;
  final ScrollController completedTasksTabScrollConntroller =
      ScrollController();
  final ScrollController tasksTabToaysTasksScrollController =
      ScrollController();
  final ScrollController tasksTabAllTasksScrollController = ScrollController();
  final ScrollController tasksTabCategoriesScrollController =
      ScrollController();
  final ScrollController categoryTasksScrollController = ScrollController();
  RxInt todayTasksNumber = 0.obs;
  RxInt allTasksNumber = 0.obs;
  late final SharedPreferences _preferences;
  bool? canLoadMoreDataInTodaysTasksPart;
  bool? canLoadMoreDataInAllTasksPart;
  bool? canLoadMoreDataInCategoriesPart;
  bool? canLoadMoreDataInCategoryTasks;

  @override
  void onInit() async {
    super.onInit();
    completedTasksTabScrollConntroller.addListener(
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
    categoryTasksScrollController.addListener(() {
      if ((categoryTasksScrollController.position.maxScrollExtent -
              categoryTasksScrollController.offset) <
          20) {
        update([CATEGORYTASKS_WID_ID]);
      }
    });
    await _tasksProvider.init();
    await _categoriesProvider.init();
    _updateTodaysTasksLength();
    _updateAllTasksLength();
  }

  Future<List<TaskModel>> getTodaysTasks(bool loadMoreData) async {
    await _tasksProvider.init();
    await _categoriesProvider.init();

    if (!loadMoreData) return _todayTasks;
    final paginated_data = await _tasksProvider.readTasks(
      limit: 10,
      offset: _tasksTabTodayTasksPaginationOffset,
      orderBy: 'id DESC',
    );
    _tasksTabTodayTasksPaginationOffset += 10;
    _todayTasks.addAll(paginated_data);
    return _todayTasks;
  }

  Future _updateTodaysTasksLength() async {
    final l = await _tasksProvider.db!
        .rawQuery('SELECT count(`id`) as c from `${_tasksProvider.tableName}`');
    todayTasksNumber.value = int.parse(l.first['c'].toString());
  }

  Future<List<TaskModel>> getAllTasks(bool loadMoreData) async {
    if (!loadMoreData) return _allTasks;
    final paginated_data = await _tasksProvider.readTasks(
      limit: 10,
      offset: _tasksTabAllTasksPaginationOffset,
      orderBy: 'id DESC',
    );
    _tasksTabAllTasksPaginationOffset += 10;
    _allTasks.addAll(paginated_data);
    return _allTasks;
  }

  Future _updateAllTasksLength() async {
    final l = await _tasksProvider.db!
        .rawQuery('SELECT count(`id`) as c from `${_tasksProvider.tableName}`');
    allTasksNumber.value = int.parse(l.first['c'].toString());
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
    }
    _tasksTabCategoriesPaginationOffset += 10;
    _categories.addAll(paginated_data);
    return _categories;
  }

  Future<List<TaskModel>> getCategoryTasks(
      int categoryId, bool loadMoreData) async {
    print('controller called');
    if (!loadMoreData) return _categoryTasks;
    final List<TaskModel> paginated_data = await _tasksProvider.readTasks(
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: 10,
      offset: _categoryTasksPagintionOffset,
      orderBy: 'id DESC',
    );
    _categoryTasksPagintionOffset += 10;
    _categoryTasks.addAll(paginated_data);

    return _categoryTasks;
  }

  void deleteLastSavedCategoryTasks() {
    _categoryTasksPagintionOffset = 0;
    canLoadMoreDataInCategoryTasks = null;
    _categoryTasks.clear();
  }

  void deleteLastSavedTodayTasks() {
    _tasksTabTodayTasksPaginationOffset = 0;
    canLoadMoreDataInTodaysTasksPart = null;
    _todayTasks.clear();
  }

  void deleteLastSavedAllTasks() {
    _tasksTabAllTasksPaginationOffset = 0;
    canLoadMoreDataInAllTasksPart = null;
    _allTasks.clear();
  }

  Future<List<TaskModel>> getCompletedTasks(bool loadMoreData) async {
    await _tasksProvider.init();

    if (!loadMoreData) return _completedTasks;
    final paginated_data = await _tasksProvider.readTasks(
      where: 'completed = ?',
      whereArgs: ['1'],
      limit: 10,
      offset: _completedTabPaginationOffset,
      orderBy: 'id DESC',
    );
    _completedTabPaginationOffset += 10;
    _completedTasks.addAll(paginated_data);
    return _completedTasks;
  }

  Future<void> createTask(TaskModel data) async {
    final category = (await _categoriesProvider.readCategories(
      where: 'id = ?',
      whereArgs: [data.categoryId],
      columns: ['title', 'color_code'],
    ))
        .first;
    data
      ..categoryTitle = category.title
      ..categoryColor = category.color;
    await _tasksProvider.createTask(data);
    _updateAllTasksLength();
    _updateTodaysTasksLength();
    deleteLastSavedTodayTasks();
    deleteLastSavedAllTasks();
    update([TODAYS_TASKS_WID_ID, ALL_TASKS_WID_ID]);
  }

  Future<List<CategoryIdAndIndex>> getCategoriesTitles() async {
    final categories = (await _categoriesProvider.readCategories(
        columns: ['id', 'title', 'color_code'], orderBy: 'id ASC'));
    int count = -1;
    final List<CategoryIdAndIndex> categoriesIdsAndIndexes = categories.map(
      (e) {
        count++;
        return CategoryIdAndIndex(
          categoryIndex: count,
          categoryTitle: e.title!,
          categoryId: e.id!,
          categoryColor: e.color!,
        );
      },
    ).toList();
    return categoriesIdsAndIndexes;
  }

  Future<int> createCategory(CategoryModel data) async {
    return await _categoriesProvider.createCategory(data);
  }
}

class CategoryIdAndIndex {
  final String categoryTitle;
  final int categoryIndex;
  final int categoryId;
  final Color categoryColor;

  CategoryIdAndIndex({
    required this.categoryTitle,
    required this.categoryIndex,
    required this.categoryId,
    required this.categoryColor,
  });
}
