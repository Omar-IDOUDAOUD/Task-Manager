import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/constants/colors.dart';

class TasksTab extends StatefulWidget {
  const TasksTab({Key? key}) : super(key: key);

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab> {
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: EdgeInsets.all(25),
        child: Column(
          children: [TasksTabPartsNavigation()],
        ),
      ),
    );
  }
}

class TasksTabPartsNavigation extends StatefulWidget {
  const TasksTabPartsNavigation({Key? key}) : super(key: key);

  @override
  State<TasksTabPartsNavigation> createState() =>
      TasksTabPartsNavigationState();
}

class TasksTabPartsNavigationState extends State<TasksTabPartsNavigation> {
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Text(
          "Today's Tasks",
          style: Get.theme.textTheme.headline4?.copyWith(
            color: CstColors.a,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(
          width: 5,
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 5, vertical: 1),
          decoration: BoxDecoration(
            color: CstColors.a,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            '7',
            style: Get.theme.textTheme.headline1?.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        _divider(),
        Text(
          "All Tasks",
          style: Get.theme.textTheme.headline4?.copyWith(
            color: Get.theme.colorScheme.secondary,
          ),
        ),
        _divider(),
        Text(
          "Categories",
          style: Get.theme.textTheme.headline4?.copyWith(
            color: Get.theme.colorScheme.secondary,
          ),
        ),
      ],
    );
  }

  _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 1.5,
          height: 13,
          child: DecoratedBox(
              decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(1),
            color: Get.theme.colorScheme.secondary,
          )),
        ),
      );
}
