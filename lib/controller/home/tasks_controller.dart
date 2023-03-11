import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/data/provider/categories_provider.dart';
import 'package:task_manager/data/provider/tasks_provider.dart';

const TODAYS_TASKS_WID_ID = "TODAYS_TASKS_LIST_WID_TAG";
const ALL_TASKS_WID_ID = "ALL_TASKS_WID_ID";
const CATEGORIES_WID_ID = "CATEGORIES_WID_ID";
const CATEGORYTASKS_WID_ID = "CATEGORYTASKS_WID_ID";
const COMPLETED_TASKS_WID_ID = "COMPLETED_TASKS_WID_ID";
const TASKS_TAB_PARTS_WID_ID = "TASKS_TAB_PARTS_WID_ID";

class TasksUpdateLog {
  final bool isAddNewTask;
  final int? index;
  final TaskModel? task;

  TasksUpdateLog({required this.isAddNewTask, this.index, this.task});
}

class TasksController extends GetxController {
  final todayTasksListKey = GlobalKey<AnimatedListState>();
  GlobalKey<AnimatedListState> allTasksListKey = GlobalKey();
  GlobalKey<AnimatedListState> categoryTasksListKey = GlobalKey();
  GlobalKey<AnimatedListState> completedTasksListKey = GlobalKey();
  ValueNotifier<TasksUpdateLog?> onUpdateTodayTasksNotifier =
      ValueNotifier(null);
  ValueNotifier<TasksUpdateLog?> onUpdateAllTasksNotifier = ValueNotifier(null);
  ValueNotifier<TasksUpdateLog?> onUpdateCategoryTasksTasksNotifier =
      ValueNotifier(null);
  ValueNotifier<TasksUpdateLog?> onUpdateCompletedTasksNotifier =
      ValueNotifier(null);
  final TasksProvider _tasksProvider = TasksProvider();
  final CategoriesProvider _categoriesProvider = CategoriesProvider();
  final List<TaskModel> _todayTasks = [];
  final List<TaskModel> _allTasks = [];
  final List<CategoryModel> _categories = [];
  final List<TaskModel> _completedTasks = [];
  RxInt todayTasksNumber = 0.obs;
  RxInt allTasksNumber = 0.obs;

  @override
  void onInit() async {
    super.onInit();
    onUpdateTodayTasksNotifier.addListener(() => _todayTasks.clear());
    onUpdateAllTasksNotifier.addListener(() => _allTasks.clear());
    onUpdateCompletedTasksNotifier.addListener(() => _completedTasks.clear());
    await _tasksProvider.init();
    await _categoriesProvider.init();
    _updateTodaysTasksLength();
    _updateAllTasksLength();
  }

  Future<List<TaskModel>> getTodaysTasks(int paginationOffset,
      {int paginationLimit = 10}) async {
    if (paginationOffset == 0 && _todayTasks.isNotEmpty) return _todayTasks;
    await _tasksProvider.init();
    await _categoriesProvider.init();

    final now = DateTime.now();
    final paginated_data = await _tasksProvider.readTasks(
      limit: paginationLimit,
      offset: paginationOffset,
      orderBy: 'id DESC',
      where: 'DATE(completion_date) == DATE(?) AND completed = ?',
      whereArgs: [
        now.toIso8601String(),
        0,
      ],
    );
    _todayTasks.addAllIf(_todayTasks.isEmpty, paginated_data);
    return paginated_data;
  }

  Future _updateTodaysTasksLength() async {
    final now = DateTime.now();
    final l = await _tasksProvider.db!.rawQuery(
        'SELECT count(`id`) as c from ${_tasksProvider.tableName} WHERE DATE(completion_date) == DATE(?) AND completed = 0',
        [now.toIso8601String()]);
    todayTasksNumber.value = int.parse(l.first['c'].toString());
  }

  Future<List<TaskModel>> getAllTasks(int paginationOffset,
      {int paginationLimit = 10}) async {
    if (paginationOffset == 0 && _allTasks.isNotEmpty) return _allTasks;

    final paginated_data = await _tasksProvider.readTasks(
      limit: paginationLimit,
      offset: paginationOffset,
      where: 'completed = ?',
      whereArgs: [0],
      orderBy: 'id DESC',
    );
    _allTasks.addAllIf(_allTasks.isEmpty, paginated_data);
    return paginated_data;
  }

  Future _updateAllTasksLength() async {
    final l = await _tasksProvider.db!.rawQuery(
        'SELECT count(`id`) as c from `${_tasksProvider.tableName}` WHERE  completed = 0');
    allTasksNumber.value = int.parse(l.first['c'].toString());
  }

  Future<List<CategoryModel>> getCategories(int paginationOffset,
      {int paginationLimit = 5}) async {
    if (paginationOffset == 0 && _categories.isNotEmpty) return _categories;

    final paginated_data = await _categoriesProvider.readCategories(
        limit: paginationLimit, offset: paginationOffset);
    for (var i = 0; i < paginated_data.length; i++) {
      final List<String> titles = (await _tasksProvider.db!.rawQuery(
              'SELECT `title` from `${_tasksProvider.tableName}` where category_id = ${paginated_data.elementAt(i).id} GROUP BY id ORDER BY id DESC LIMIT 3'))
          .map((e) => e['title'].toString())
          .toList();
      for (var i2 = 0; i2 < titles.length; i2++) {
        paginated_data[i].threeLastTasksTitles![i2] = titles.elementAt(i2);
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
    _categories.addAllIf(_categories.isEmpty, paginated_data);
    return paginated_data;
  }

  Future<List<TaskModel>> getCategoryTasks(int categoryId,
      {required int paginationOffset, int paginationLimit = 10}) async {
    final List<TaskModel> paginated_data = await _tasksProvider.readTasks(
      where: 'category_id = ?',
      whereArgs: [categoryId],
      limit: paginationLimit,
      offset: paginationOffset,
      orderBy: 'id DESC',
    );

    return paginated_data;
  }

  Future<void> checkTask(int taskId, int listIndex) async {
    print('tasj checked id: $taskId, index: $listIndex');
    final checkedTask = await _tasksProvider.readTasks(
        where: 'id = ?', whereArgs: [taskId]).then((value) => value.first);
    await _tasksProvider.deleteTask(taskId);

    _updateAllTasksLength();
    _updateTodaysTasksLength();
    if (checkedTask.completionDate != null &&
        checkedTask.completionDate!.day == DateTime.now().day) {
      onUpdateTodayTasksNotifier.value = TasksUpdateLog(
          isAddNewTask: false,
          index: listIndex,
          task: checkedTask..completed = true);
    } else {
      onUpdateAllTasksNotifier.value = TasksUpdateLog(
          isAddNewTask: false,
          index: listIndex,
          task: checkedTask..completed = true);
    }
    _todayTasks.clear();
    _allTasks.clear();
    _categories.clear();
  }

  Future<List<TaskModel>> getCompletedTasks(int paginationOffset,
      {int paginationLimit = 10}) async {
    if (paginationOffset == 0 && _completedTasks.isNotEmpty)
      return _completedTasks;
    await _tasksProvider.init();

    final paginated_data = await _tasksProvider.readTasks(
      where: 'completed = ?',
      whereArgs: ['1'],
      offset: paginationOffset,
      limit: paginationLimit,
      orderBy: 'id DESC',
    );
    _completedTasks.addAllIf(_completedTasks.isEmpty, paginated_data);
    return paginated_data;
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
    final newId = await _tasksProvider.createTask(data);
    final newTask =
        (await _tasksProvider.readTasks(where: 'id = ?', whereArgs: [newId]))
            .first;
    _updateAllTasksLength();
    _updateTodaysTasksLength();
    if (newTask.completionDate != null &&
        newTask.completionDate!.day == DateTime.now().day) {
      onUpdateTodayTasksNotifier.value =
          TasksUpdateLog(isAddNewTask: true, index: 0, task: newTask);
      onUpdateAllTasksNotifier.value =
          TasksUpdateLog(isAddNewTask: true, index: 0, task: newTask);
      _todayTasks.clear();
    } else {
      onUpdateAllTasksNotifier.value =
          TasksUpdateLog(isAddNewTask: true, index: 0, task: newTask);
    }
    _allTasks.clear();
    _categories.clear();
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
    _categories.clear();
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
