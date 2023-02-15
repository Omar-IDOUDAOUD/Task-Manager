import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/data/model/task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({Key? key, required this.data}) : super(key: key);

  final TaskModel data;

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
                  data.title!,
                  style: Get.theme.textTheme.headline5?.copyWith(
                    color: Get.theme.colorScheme.primary,
                    decoration:
                        data.completed! ? TextDecoration.lineThrough : null,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 20,
                child: Checkbox(
                  value: data.completed,
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
          data.description != null
              ? Text(
                  data.description!,
                  style: Get.theme.textTheme.headline2?.copyWith(
                    color: Get.theme.colorScheme.secondary,
                    decoration:
                        data.completed! ? TextDecoration.lineThrough : null,
                  ),
                )
              : const SizedBox.shrink(),
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
            _getPriorityString,
            style: Get.theme.textTheme.headline2?.copyWith(
              color: _getPriorityColor,
            ),
          ),
          Row(
            children: [
              // completetion date
              if (data.completionDate != null) ...[
                Text(
                  data.completionDate!.day == DateTime.now().day
                      ? 'Today'
                      : DateFormat.EEEE().format(data.completionDate!),
                  style: Get.theme.textTheme.headline5?.copyWith(
                    color: Get.theme.colorScheme.secondary,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Text(
                  DateFormat.Hm().format(data.completionDate!),
                  style: Get.theme.textTheme.headline5?.copyWith(
                    color: Get.theme.colorScheme.tertiary,
                  ),
                ),
                const Spacer(),
              ],
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: data.categoryColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5.5, vertical: 3),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_fluent_archive_24_filled.svg',
                        height: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 5,
                      ),
                      Text(
                        data.categoryTitle!,
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

  String get _getPriorityString {
    switch (data.priority) {
      case TaskPriorities.low:
        return 'Low task';
      case TaskPriorities.medium:
        return 'Medium task';
      case TaskPriorities.high:
        return 'High task';
      default:
        return 'Normal task';
    }
  }

  Color get _getPriorityColor {
    switch (data.priority) {
      case TaskPriorities.low:
        return CstColors.e;
      case TaskPriorities.medium:
        return CstColors.d;
      case TaskPriorities.high:
        return CstColors.c;
      default:
        return CstColors.d;
    }
  }
}
