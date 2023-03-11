import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/data/model/task.dart';

class TaskCard extends StatefulWidget {
  const TaskCard(
      {Key? key,
      required this.data,
      required this.onChangeCompletetionState,
      this.showShadow = false})
      : super(key: key);
  // : super(key: key);
  final Function(bool isCompleted) onChangeCompletetionState;
  final bool showShadow;

  final TaskModel data;

  @override
  State<TaskCard> createState() => _TaskCardState();
}

class _TaskCardState extends State<TaskCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _animationController;
  bool _isChecked = false;

  // void startCheckAnimation(){

  // }
  @override
  void initState() {
    print('iiiiiiiiiiiiiiiiiiiiiiiiiiiiii');
    // TODO: implement initState
    _isChecked = widget.data.completed!;
    _animationController = AnimationController(
        debugLabel: 'constrr',
             
        vsync: this,
        duration: 200.milliseconds,
        lowerBound: 0.0,
        upperBound: 1.0)
      ..addListener(() {
        setState(() {});
      });
  }

  @override
  void dispose() {
    // TODO: implement dispose
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Colors.white,
        boxShadow: widget.showShadow
            ? [
                BoxShadow(
                    color: Colors.black.withOpacity(.03),
                    offset: const Offset(0, 20),
                    blurRadius: 50),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Stack(
                  fit: StackFit.loose,
                  children: [
                    Text(
                      widget.data.title!,
                      style: Get.theme.textTheme.headline5?.copyWith(
                        color: Get.theme.colorScheme.primary,
                      ),
                    ),
                    // if (_isChecked)
                    AnimatedBuilder(
                      animation: _animationController,
                      builder: (_, c) {
                        return SizeTransition(
                          axis: Axis.horizontal,
                          sizeFactor: _animationController,
                          child: c,
                        );
                      },
                      child: Text(
                        widget.data.title!,
                        style: TextStyle(
                          color: Colors.transparent,
                          decoration: TextDecoration.lineThrough,
                          decorationColor:
                              Get.theme.colorScheme.primary.withOpacity(.5),
                          decorationThickness: 2,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox.square(
                dimension: 20,
                child: Checkbox(
                  value: _isChecked,
                  onChanged: (v) {
                    print(v);
                    widget.onChangeCompletetionState(v!);
                    _isChecked = v;
                    _animationController.forward();
                  },
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
            widget.data.description!.isNotEmpty
                ? widget.data.description!
                // : "No Description",
                : widget.data.id.toString(),
            style: Get.theme.textTheme.headline2?.copyWith(
              color: widget.data.description!.isNotEmpty
                  ? Get.theme.colorScheme.secondary
                  : Get.theme.colorScheme.secondary.withOpacity(.5),
              decoration:
                  widget.data.completed! ? TextDecoration.lineThrough : null,
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
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getPriorityString,
                    style: Get.theme.textTheme.headline2?.copyWith(
                      color: _getPriorityColor,
                    ),
                  ),
                  if (widget.data.completionDate != null) ...[
                    Row(
                      children: [
                        Text(
                          widget.data.completionDate!.day == DateTime.now().day
                              ? 'Today'
                              : DateFormat.EEEE()
                                  .format(widget.data.completionDate!),
                          style: Get.theme.textTheme.headline5?.copyWith(
                            color: Get.theme.colorScheme.secondary,
                          ),
                        ),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          DateFormat.Hm().format(widget.data.completionDate!),
                          style: Get.theme.textTheme.headline5?.copyWith(
                            color: Get.theme.colorScheme.tertiary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ],
              ),
              const Spacer(),
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(5),
                  color: widget.data.categoryColor,
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
                  child: Row(
                    children: [
                      SvgPicture.asset(
                        'assets/icons/ic_fluent_archive_24_regular.svg',
                        height: 13,
                        color: Colors.white,
                      ),
                      const SizedBox(
                        width: 4,
                      ),
                      Text(widget.data.categoryTitle!,
                          style: TextStyle(
                            fontSize: 10,
                            height: 1,
                            color: Get.theme.scaffoldBackgroundColor,
                            // fontWeight: FontWeight.normal
                          ))
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
    switch (widget.data.priority) {
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
    switch (widget.data.priority) {
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
