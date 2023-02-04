import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

class CompletedTab extends StatelessWidget {
  CompletedTab({Key? key}) : super(key: key) {}

  @override
  Widget build(BuildContext context) {
    if (_canLoadMoreData != null) _canLoadMoreData = false;
    return GetBuilder<TasksController>(
      id: COMPLETED_TASKS_WID_ID,
      builder: (controller) {
        return FutureBuilder<List<TaskModel>>(
          future: controller.getCompletedTasks(_getCanLoadMoreData),
          builder: (ctx, screenShot) {
            return ListView(
              controller: controller.completedTasksTabScrollConntroller,
              padding: const EdgeInsets.all(25),
              children: [
                if (screenShot.hasData)
                  ...List.generate(
                    screenShot.data!.length,
                    (index) => TaskCard(
                      data: screenShot.data!.elementAt(index),
                    ),
                  ),
                if (screenShot.connectionState == ConnectionState.waiting)
                  const Padding(
                    padding: EdgeInsets.all(10),
                    child: CupertinoActivityIndicator(),
                  ),
              ],
            );
          },
        );
      },
    );
  }

  bool? _canLoadMoreData;
  bool get _getCanLoadMoreData {
    var copy = _canLoadMoreData;
    _canLoadMoreData = true;
    return copy ?? true;
  }
}
