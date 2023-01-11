import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/view/home/widgets/custom_textfield.dart';

class NewTaskBottomSheetWidget extends StatelessWidget {
  const NewTaskBottomSheetWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    const String prefixTitlesSpace = '    ';
    return DecoratedBox(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(.2), blurRadius: 150),
        ],
        color: Colors.white,
        borderRadius:const  BorderRadius.vertical(top: Radius.circular(60)),
      ),
      child: Padding(
        padding:const  EdgeInsets.only(top: 7, right: 25, left: 30, bottom: 30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: SizedBox(
                height: 4.5,
                width: Get.size.width / 3,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(5),
                    color: Get.theme.colorScheme.surface,
                  ),
                ),
              ),
            ),
          const   SizedBox(height: 15),
            Center(
              child: Text(
                "Create Task",
                style: Get.theme.textTheme.headline5!.copyWith(
                  color: Get.theme.colorScheme.primary,
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
           const  SizedBox(height: 15),
            Text(
              prefixTitlesSpace + 'Task Title',
              style: Get.theme.textTheme.headline4!.copyWith(
                color: Get.theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
           const  SizedBox(height: 3),
           const  CustomTextField(
              textHint: 'e.g: Create work structure',
              //  expands: true,
            ),
            const SizedBox(
              height: 20,
            ),
            Row(
              children: [
                Text(
                  prefixTitlesSpace + 'Task descreption',
                  style: Get.theme.textTheme.headline4!.copyWith(
                    color: Get.theme.colorScheme.secondary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
               const  Spacer(),
                Text(
                  '0/315' + prefixTitlesSpace,
                  style: Get.theme.textTheme.headline2!
                      .copyWith(color: Get.theme.colorScheme.secondary),
                ),
              ],
            ),
           const  SizedBox(height: 3),
            const CustomTextField(
              textHint: 'descreption',
              minLines: 3,
              maxLines: 7,
            ),
           const  SizedBox(
              height: 20,
            ),
            Text(
              prefixTitlesSpace + 'Task priority',
              style: Get.theme.textTheme.headline4!.copyWith(
                color: Get.theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
           const  SizedBox(height: 3),
           const  _TaskPriority(),
           const  SizedBox(
              height: 20,
            ),
            Text(
              prefixTitlesSpace + 'Choose date & time',
              style: Get.theme.textTheme.headline4!.copyWith(
                color: Get.theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 3),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface.withOpacity(.4),
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/ic_fluent_calendar_ltr_24_regular.svg',
                          height: 20,
                          color:
                              Get.theme.colorScheme.secondary.withOpacity(.5),
                        ),
                        Text(
                          "Choose Date",
                          style: Get.theme.textTheme.headline4!.copyWith(
                            color:
                                Get.theme.colorScheme.secondary.withOpacity(.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
               const SizedBox(
                  width: 15,
                ),
                Expanded(
                  child: Container(
                    padding: EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface.withOpacity(.4),
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SvgPicture.asset(
                          'assets/icons/ic_fluent_clock_24_regular.svg',
                          height: 20,
                          color:
                              Get.theme.colorScheme.secondary.withOpacity(.5),
                        ),
                        Text(
                          "Choose Time",
                          style: Get.theme.textTheme.headline4!.copyWith(
                            color:
                                Get.theme.colorScheme.secondary.withOpacity(.5),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}

class _TaskPriority extends StatefulWidget {
  const _TaskPriority({Key? key}) : super(key: key);

  @override
  State<_TaskPriority> createState() => __TaskPriorityState();
}

class __TaskPriorityState extends State<_TaskPriority> {
  String? _selectedPriority;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _getPriorityButton(priority: 'Low', color: CstColors.e),
      const   SizedBox(
          width: 10,
        ),
        _getPriorityButton(priority: 'Medium', color: CstColors.d),
       const  SizedBox(
          width: 10,
        ),
        _getPriorityButton(priority: 'High', color: CstColors.c),
      ],
    );
  }

  Widget _getPriorityButton(
      {required String priority, required Color color, Function()? onTap}) {
    final bool selected = priority == _selectedPriority;
    return GestureDetector(
      onTap: () {
        // onTap!();
        setState(() {
          _selectedPriority = priority;
        });
      },
      child: AnimatedContainer(
        duration: 100.milliseconds,
        padding: EdgeInsets.all(selected ? 12 : 15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.5),
          border: selected ? Border.all(width: 3, color: color) : null,
          color: selected
              ? color.withOpacity(.2)
              : Get.theme.colorScheme.surface.withOpacity(.4),
        ),
        child: Text(
          priority,
          style: Get.theme.textTheme.headline4!.copyWith(
            color: selected
                ? color
                : Get.theme.colorScheme.secondary.withOpacity(.5),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
