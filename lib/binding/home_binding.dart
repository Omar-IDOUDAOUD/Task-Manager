import 'package:get/get.dart';
import 'package:task_manager/controller/home/profile_controller.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';

class HomeBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<TasksController>(TasksController());
    Get.lazyPut<ProfileController>(()=>ProfileController());
  }
}