import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/constants/colors.dart';

/// MAIN ABSTRACT
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
          children: const [
            _TasksTabPartsNavigation(),
            SizedBox(
              height: 13,
            ),
            _Title(),
          ],
        ),
      ),
    );
  }
}

/// WIDGETS

class _Title extends StatelessWidget {
  const _Title({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Today\'s Task',
              style: Get.theme.textTheme.headline6,
            ),
            Text(
              'Wednesday, May 20',
              style: Get.theme.textTheme.headline3,
            ),
          ],
        ),
        _AddTaskButton()
      ],
    );
  }
}

class _AddTaskButton extends StatefulWidget {
  const _AddTaskButton({Key? key}) : super(key: key);

  @override
  State<_AddTaskButton> createState() => __AddTaskButtonState();
}

class __AddTaskButtonState extends State<_AddTaskButton> {
  bool _isFocus = false;
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (dts) {
        setState(() {
          _isFocus = true;
        });
      },
      onTapUp: (dts) {
        setState(() {
          _isFocus = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isFocus = false;
        });
      },
      child: AnimatedContainer(
        duration: 95.milliseconds,
        curve: Curves.linearToEaseOut,
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: CstColors.a.withOpacity(.1),
        ),
        foregroundDecoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          color: _isFocus ? CstColors.a.withOpacity(.1) : null,
        ),
        child: Row(
          children: [
            Icon(
              Icons.add_rounded,
              color: CstColors.a,
              size: 18,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "New Task",
              style: Get.theme.textTheme.headline4
                  ?.copyWith(color: CstColors.a, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }
}

class _TasksTabPartsNavigation extends StatefulWidget {
  const _TasksTabPartsNavigation({Key? key}) : super(key: key);

  @override
  State<_TasksTabPartsNavigation> createState() =>
      TasksTabPartsNavigationState();
}

class TasksTabPartsNavigationState extends State<_TasksTabPartsNavigation> {
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
