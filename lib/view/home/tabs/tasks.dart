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
            SizedBox(
              height: 20,
            ),
            _TaskCard(),
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
        const _AddTaskButton()
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
        const SizedBox(
          width: 5,
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
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

class _TaskCard extends StatelessWidget {
  const _TaskCard({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(.03),
              offset: const Offset(0, 20),
              blurRadius: 50),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  'Project Work Flow',
                  style: Get.theme.textTheme.headline5?.copyWith(
                    color: Get.theme.colorScheme.primary,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 20,
                child: Checkbox(
                  value: false,
                  onChanged: (v) => true,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  side:
                      BorderSide(color: CstColors.b.withOpacity(.3), width: 2),
                  activeColor: CstColors.b,
                ),
              )
            ],
          ),
          Text(
            'Increase platform building work flow speed',
            style: Get.theme.textTheme.headline2?.copyWith(
              color: Get.theme.colorScheme.secondary,
            ),
          ),
          const SizedBox(
            height: 10,
          ),
          SizedBox(
            width: double.infinity,
            height: 1,
            child: ColoredBox(
                color: Get.theme.colorScheme.tertiary.withOpacity(.5)),
          ),
          const SizedBox(
            height: 10,
          ),
          Text(
            'Important Task',
            style: Get.theme.textTheme.headline2?.copyWith(
              color: CstColors.c,
            ),
          ),
          Row(
            children: [
              Text(
                'Today',
                style: Get.theme.textTheme.headline5?.copyWith(
                  color: Get.theme.colorScheme.secondary,
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Text(
                '15:30',
                style: Get.theme.textTheme.headline5?.copyWith(
                  color: Get.theme.colorScheme.tertiary,
                ),
              ),
              const Spacer(
                  ),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: CstColors.b,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
                  child: Row(
                    children: [
                      Icon(
                        Icons.archive_outlined,
                        color: Get.theme.scaffoldBackgroundColor,
                        size: 14,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Work',
                        style: Get.theme.textTheme.headline2?.copyWith(
                            color: Get.theme.scaffoldBackgroundColor),
                      )
                    ],
                  ),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }
}
