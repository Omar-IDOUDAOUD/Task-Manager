import 'package:get/get.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/data/provider/tasks_provider.dart';

class CompletedTasksController extends GetxController {
  final TasksProvider _tasksProvider = TasksProvider();

  List<TaskModel>? _completedTasks;

  @override
  Future<void> onInit() async {
    super.onInit();
    print('LOG: CompletedTasksController onInit called');
  }

  Future<List<TaskModel>> getCompletedTasks() async {
    await _tasksProvider.init();
        _completedTasks = await _tasksProvider
        .readTasks(where: 'completed = ?', whereArgs: ['1']);
    return _completedTasks!;
  }
}
