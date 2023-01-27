import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TasksController>(
      id: COMPLETED_TASKS_WID_ID,
      builder: (controller) {
        return FutureBuilder(
          future: controller.getCompletedTasks(),
          builder: (ctx, AsyncSnapshot<List<TaskModel>> screenShot) {
            if (!screenShot.hasData) return CupertinoActivityIndicator();
            return ListView.separated(
              controller: controller.completedTasksScrollConntroller,
              padding: const EdgeInsets.all(25),
              itemBuilder: (ctx, index) {
                if (!screenShot.hasData) return CupertinoActivityIndicator();
                return TaskCard(data: screenShot.data!.elementAt(index));
              },
              separatorBuilder: (ctx, index) => const SizedBox(
                height: 15,
              ),
              itemCount: screenShot.data!.length ,
            );
          },
        );
      },
    );
  }
}
