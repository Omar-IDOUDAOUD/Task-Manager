import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/constants/colors.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({Key? key, this.isLive = true}) : super(key: key);
  final bool isLive;

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
                    decoration: isLive ? null : TextDecoration.lineThrough,
                  ),
                ),
              ),
              SizedBox.square(
                dimension: 20,
                child: Checkbox(
                  value: !isLive,
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
              decoration: isLive ? null : TextDecoration.lineThrough,
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
              const Spacer(),
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
