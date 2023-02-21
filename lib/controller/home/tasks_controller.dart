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
const TASKS_TAB_PARTS_WID_ID = "TASKS_TAB_PARTS_WID_ID";

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

  Future<List<TaskModel>> getTodaysTasks(int paginationOffset,
      {int paginationLimit = 10}) async {
    await _tasksProvider.init();
    await _categoriesProvider.init();

    final now = DateTime.now();
    final paginated_data = await _tasksProvider.readTasks(
      limit: paginationLimit,
      offset: paginationOffset,
      orderBy: 'id DESC',
      where: 'DATE(completion_date) == DATE(?)',
      whereArgs: [
        now.toIso8601String(),
      ],
    );
    return paginated_data;
  }

  Future _updateTodaysTasksLength() async {
    final now = DateTime.now();
    final l = await _tasksProvider.db!.rawQuery(
        'SELECT count(`id`) as c from ${_tasksProvider.tableName} WHERE DATE(completion_date) == DATE(?)',
        [now.toIso8601String()]);
    todayTasksNumber.value = int.parse(l.first['c'].toString());
  }

  Future<List<TaskModel>> getAllTasks(int paginationOffset,
      {int paginationLimit = 10}) async {
    final paginated_data = await _tasksProvider.readTasks(
      limit: paginationLimit,
      offset: paginationOffset,
      orderBy: 'id DESC',
    );
    return paginated_data;
  }

  Future _updateAllTasksLength() async {
    final l = await _tasksProvider.db!
        .rawQuery('SELECT count(`id`) as c from `${_tasksProvider.tableName}`');
    allTasksNumber.value = int.parse(l.first['c'].toString());
  }

  Future<List<CategoryModel>> getCategories(int paginationOffset,
      {int paginationLimit = 5}) async {
    final paginated_data = await _categoriesProvider.readCategories(
        limit: paginationLimit, offset: paginationOffset);
    for (var i = 0; i < paginated_data.length; i++) {
      final titles = (await _tasksProvider.readTasks(
        where: 'category_id = ?',
        whereArgs: [paginated_data.elementAt(i).id],
        groupBy: 'id',
        orderBy: 'id DESC',
        limit: paginationLimit,
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
    return paginated_data;
  }

  Future<List<TaskModel>> getCategoryTasks(
      int categoryId,{ required int paginationOffset,
      int paginationLimit = 10}) async {
    final List<TaskModel> paginated_data = await _tasksProvider.readTasks(
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: paginationLimit,
      offset: paginationOffset,
      orderBy: 'id DESC',
    ); 

    return paginated_data;
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

  Future<List<TaskModel>> getCompletedTasks(int paginationOffset,
      {int paginationLimit = 10}) async {
    await _tasksProvider.init();

    final paginated_data = await _tasksProvider.readTasks(
      where: 'completed = ?',
      whereArgs: ['1'],
      offset: paginationOffset,
      limit: paginationLimit,
      orderBy: 'id DESC',
    );
    return paginated_data;
  }

  Future<void> createTask(TaskModel data) async {
    //  await this.createCategory(CategoryModel(color: Colors.blue, title: "test cat", tasksNumber: 0, productivityPerCentage: 0.0, ));
    //  await this.createCategory(CategoryModel(color: Colors.green, title: "test cat", tasksNumber: 0, productivityPerCentage: 0.0, ));
    //  await this.createCategory(CategoryModel(color: Colors.orange, title: "test cat", tasksNumber: 0, productivityPerCentage: 0.0, ));
    //  await this.createCategory(CategoryModel(color: Colors.purple, title: "test cat", tasksNumber: 0, productivityPerCentage: 0.0, ));
    //  await this.createCategory(CategoryModel(color: Colors.brown, title: "test cat", tasksNumber: 0, productivityPerCentage: 0.0, ));
    final category = (await _categoriesProvider.readCategories(
      where: 'id = ?',
      whereArgs: [data.categoryId],
      columns: ['title', 'color_code'],
    ))
        .first;
    data
      ..categoryTitle = category.title
      ..categoryColor = category.color
      ..completed = true; 
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
