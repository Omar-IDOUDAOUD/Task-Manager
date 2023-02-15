import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/core/utils/bottom_sheet.dart' as CoreUtils;
import 'package:task_manager/core/utils/menu.dart' as CoreUtils;
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/bottomsheets/new_category.dart';
import 'package:task_manager/view/home/widgets/custom_textfield.dart';

class NewTaskBottomSheet extends StatefulWidget {
  const NewTaskBottomSheet({Key? key}) : super(key: key);

  NewTaskBottomSheet.open({Key? key}) : super(key: key) {
    CoreUtils.BottomSheet.open(
      this,
      title: "Create Task",
    );
  }

  @override
  State<NewTaskBottomSheet> createState() => _NewTaskBottomSheetState();
}

class _NewTaskBottomSheetState extends State<NewTaskBottomSheet> {
  final TasksController _controller = Get.find();

  final TextEditingController _titleController = TextEditingController();

  final TextEditingController _descController = TextEditingController();

  bool _showMore = false;

  final TaskModel _buidingModel = TaskModel(
    title: 'Untitled',
  );

  List<CategoryIdAndIndex>? _categoriesTitles;

  final _categoryDropDownMenuButtonKey = GlobalKey();

  OverlayEntry? _doneButtonOverLayEntry;

  bool _showDoneButton = false;

  late final OverlayState overLay;

  bool _readyToSaveTask = false;

  void _showDoneButtonOverLay() {
    _doneButtonOverLayEntry ??= OverlayEntry(
      builder: (context) => AnimatedPositioned(
        duration: 200.milliseconds,
        curve: Curves.linearToEaseOut,
        bottom: _showDoneButton ? 20 : -50,
        right: 30,
        left: 30,
        height: 50,
        child: GestureDetector(
          onTap: () async {
            if (!_readyToSaveTask) return;
            _buidingModel
              ..title = _titleController.text
              ..description = _descController.text;
            Get.back();
            _controller.createTask(_buidingModel);
          },
          child: AnimatedContainer(
            duration: 400.milliseconds,
            curve: Curves.linearToEaseOut,
            foregroundDecoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: _readyToSaveTask ? null : Colors.black54.withOpacity(.2),
            ),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15),
              color: CstColors.a,
              boxShadow: [
                if (_readyToSaveTask)
                  BoxShadow(
                    color: Colors.black54.withOpacity(.4),
                    blurRadius: 20,
                    offset: const Offset(0, 5),
                    spreadRadius: 0,
                  ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.check_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(
                  width: 5,
                ),
                Text(
                  "Done",
                  style: Get.theme.textTheme.headline5!.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) async {
      overLay.insert(_doneButtonOverLayEntry!);
      await 200.milliseconds.delay();
      overLay.setState(() {
        _showDoneButton = true;
      });
    });
  }

  void _hideDoneButtonOverLay() async {
    WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
      overLay.setState(() {
        _showDoneButton = false;
      });
    });
    200.milliseconds.delay().then((value) => _doneButtonOverLayEntry!.remove());
  }

  @override
  void dispose() {
    _hideDoneButtonOverLay();
    super.dispose();
  }

  @override
  void initState() {
    overLay = Overlay.of(context)!;
    super.initState();
    _titleController.addListener(() {
      overLay.setState(() {
        if (_titleController.text.isNotEmpty)
          _readyToSaveTask = true;
        else
          _readyToSaveTask = false;
      });
    });

    _showDoneButtonOverLay();
  }

  @override
  Widget build(BuildContext context) {
    const String titlesMarginSpaces = '    ';
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${titlesMarginSpaces}Task Title',
          style: Get.theme.textTheme.headline4!.copyWith(
            color: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        CustomTextField(
          textHint: 'e.g: Create work structure',
          controller: _titleController,
        ),
        const SizedBox(height: 20),
        Text(
          '${titlesMarginSpaces}Task descreption',
          style: Get.theme.textTheme.headline4!.copyWith(
            color: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        CustomTextField(
          textHint: 'descreption',
          minLines: 3,
          controller: _descController,
        ),
        const SizedBox(height: 20),
        Text(
          '${titlesMarginSpaces}Task priority',
          style: Get.theme.textTheme.headline4!.copyWith(
            color: Get.theme.colorScheme.secondary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        _TaskPriority(onSelectedPriority: (p) {
          return _buidingModel.priority = p;
        }),
        const SizedBox(height: 20),
        Row(
          children: [
            Text(
              '${titlesMarginSpaces}Completion date',
              style: Get.theme.textTheme.headline4!.copyWith(
                color: Get.theme.colorScheme.secondary,
                fontWeight: FontWeight.w700,
              ),
            ),
            const Spacer(),
            Text(
              (_buidingModel.completionDate != null
                      ? DateFormat.MMMMEEEEd()
                          .add_Hm()
                          .format(_buidingModel.completionDate!)
                      : "no date selected") +
                  titlesMarginSpaces,
              style: Get.theme.textTheme.headline2!
                  .copyWith(color: Get.theme.colorScheme.secondary),
            ),
          ],
        ),
        const SizedBox(height: 3),
        Row(
          children: [
            Expanded(
              child: _getSelectingDateTimeButton(
                "assets/icons/ic_fluent_calendar_ltr_24_regular.svg",
                "Choose Date",
                _buidingModel.completionDate != null
                    ? DateFormat('yyyy-MM-d')
                        .format(_buidingModel.completionDate!)
                    : null,
                () {
                  _hideDoneButtonOverLay();
                  final now = DateTime.now();
                  DateTime selectedDate = _buidingModel.completionDate ?? now;
                  _openDatePickerBottomSheet(selectedDate, (date) {
                    selectedDate = date;
                  }, () {
                    final selectedTime = _buidingModel.completionDate ?? now;

                    final newCompletionDateTime = DateTime(
                      selectedDate.year,
                      selectedDate.month,
                      selectedDate.day,
                      selectedTime.hour,
                      selectedTime.minute,
                    );
                    setState(() {
                      if (_buidingModel.terminationDate != null &&
                          _buidingModel.terminationDate!
                              .isBefore(newCompletionDateTime))
                        _buidingModel.terminationDate = newCompletionDateTime;
                      _buidingModel.completionDate = newCompletionDateTime;
                    });
                  }, () {
                    setState(() {
                      _buidingModel.completionDate = null;
                    });
                    Get.back();
                  });
                },
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: _getSelectingDateTimeButton(
                "assets/icons/ic_fluent_clock_24_regular.svg",
                "Choose Time",
                _buidingModel.completionDate != null
                    ? DateFormat('H:m').format(_buidingModel.completionDate!)
                    : null,
                () {
                  _hideDoneButtonOverLay();
                  final now = DateTime.now();
                  Duration selectedTime = Duration(
                      hours: _buidingModel.completionDate != null
                          ? _buidingModel.completionDate!.hour
                          : now.hour,
                      minutes: _buidingModel.completionDate != null
                          ? _buidingModel.completionDate!.minute
                          : now.minute);
                  _openTimePickerBottomSheet(
                    selectedTime,
                    (t) {
                      selectedTime = t;
                    },
                    () {
                      final selectedDate = _buidingModel.completionDate ?? now;
                      final newCompletionDateTime = DateTime(
                        selectedDate.year,
                        selectedDate.month,
                        selectedDate.day,
                        selectedTime.inHours,
                        selectedTime.inMinutes - (selectedTime.inHours * 60),
                      );
                      setState(() {
                        if (_buidingModel.terminationDate != null &&
                            _buidingModel.terminationDate!
                                .isBefore(newCompletionDateTime))
                          _buidingModel.terminationDate = newCompletionDateTime;
                        _buidingModel.completionDate = newCompletionDateTime;
                      });
                    },
                    () {
                      setState(() {
                        _buidingModel.completionDate = null;
                      });
                      Get.back();
                    },
                  );
                },
              ),
            ),
          ],
        ),
        if (_showMore) ...[
          const SizedBox(height: 20),
          Text(
            '${titlesMarginSpaces}Category',
            style: Get.theme.textTheme.headline4!.copyWith(
              color: Get.theme.colorScheme.secondary,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Builder(builder: (context) {
            return Row(
              children: [
                Expanded(
                  child: FutureBuilder<List<CategoryIdAndIndex>>(
                      future: _categoriesTitles == null
                          ? _controller.getCategoriesTitles()
                          : null,
                      builder: (context, snapshot) {
                        if (snapshot.hasData) _categoriesTitles = snapshot.data;

                        return GestureDetector(
                          child: Container(
                            key: _categoryDropDownMenuButtonKey,
                            padding: const EdgeInsets.all(15),
                            decoration: BoxDecoration(
                              color:
                                  Get.theme.colorScheme.surface.withOpacity(.4),
                              borderRadius: BorderRadius.circular(12.5),
                            ),
                            child: snapshot.connectionState ==
                                    ConnectionState.waiting
                                ? const CupertinoActivityIndicator()
                                : Row(
                                    children: [
                                      _getCategoryColorCircle(
                                        snapshot.data!
                                            .firstWhere((element) =>
                                                element.categoryId ==
                                                _buidingModel.categoryId)
                                            .categoryColor,
                                      ),
                                      const SizedBox(
                                        width: 10,
                                      ),
                                      Expanded(
                                        child: Text(
                                          snapshot.data!
                                              .firstWhere((element) =>
                                                  element.categoryId ==
                                                  _buidingModel.categoryId)
                                              .categoryTitle,
                                          style: Get.theme.textTheme.headline4!
                                              .copyWith(
                                            color: Get
                                                .theme.colorScheme.secondary
                                                .withOpacity(.5),
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ),
                                      const Spacer(),
                                      Icon(
                                        CupertinoIcons.chevron_down,
                                        color: Get.theme.colorScheme.secondary
                                            .withOpacity(.5),
                                        size: 15,
                                      ),
                                    ],
                                  ),
                          ),
                          onTap: () async {
                            if (!snapshot.hasData) return;
                            CoreUtils.Menu.open(
                              selectedItemIndex: _categoriesTitles!
                                  .firstWhere((element) =>
                                      _buidingModel.categoryId ==
                                      element.categoryId)
                                  .categoryIndex,
                              useFromWigetHeight: true,
                              onSelectedItem: (newItemIndex) {
                                // print(newItemIndex);
                                setState(() {
                                  // _categoriesTitles = null;
                                  _buidingModel.categoryId = _categoriesTitles!
                                      .firstWhere((element) =>
                                          element.categoryIndex == newItemIndex)
                                      .categoryId;
                                });
                              },
                              openFromWidgetKey: _categoryDropDownMenuButtonKey,
                              // useFromWigetHeight: true,
                              items: List.generate(
                                _categoriesTitles!.length,
                                (index) {
                                  final title =
                                      _categoriesTitles!.elementAt(index);
                                  return CoreUtils.MenuItem(
                                    label: title.categoryTitle,
                                    preLabel: _getCategoryColorCircle(
                                        title.categoryColor),
                                  );
                                },
                              ),
                            );
                          },
                        );
                      }),
                ),
                const SizedBox(
                  width: 10,
                ),
                GestureDetector(
                  onTap: () {
                    _hideDoneButtonOverLay();

                    NewCategoryBottomSheet.open(
                      onDismiss: () => _showDoneButtonOverLay(),
                      onDone: (cateogoryId) {
                        setState(() {
                          _categoriesTitles = null;
                          _buidingModel.categoryId = cateogoryId;
                        });
                      },
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: Get.theme.colorScheme.surface.withOpacity(.4),
                      borderRadius: BorderRadius.circular(12.5),
                    ),
                    child: Icon(
                      CupertinoIcons.add,
                      color: Get.theme.colorScheme.secondary.withOpacity(.5),
                      size: 20,
                    ),
                  ),
                ),
              ],
            );
          }),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${titlesMarginSpaces}Termination date',
                style: Get.theme.textTheme.headline4!.copyWith(
                  color: Get.theme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Text(
                (_buidingModel.terminationDate != null
                        ? DateFormat.MMMMEEEEd()
                            .add_Hm()
                            .format(_buidingModel.terminationDate!)
                        : "no date selected") +
                    titlesMarginSpaces,
                style: Get.theme.textTheme.headline2!
                    .copyWith(color: Get.theme.colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 3),
          Row(
            children: [
              Expanded(
                child: _getSelectingDateTimeButton(
                  "assets/icons/ic_fluent_calendar_ltr_24_regular.svg",
                  "Choose Date",
                  _buidingModel.terminationDate != null
                      ? DateFormat('yyyy-MM-d')
                          .format(_buidingModel.terminationDate!)
                      : null,
                  () {
                    _hideDoneButtonOverLay();
                    final now = _buidingModel.completionDate ?? DateTime.now();
                    DateTime selectedDate =
                        _buidingModel.terminationDate ?? now.add(2.days);
                    _openDatePickerBottomSheet(
                      selectedDate,
                      (date) {
                        selectedDate = date;
                      },
                      () {
                        final selectedTime =
                            _buidingModel.terminationDate ?? now;
                        final newTerminationDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.hour,
                          selectedTime.minute,
                        );
                        setState(() {
                          if (_buidingModel.completionDate != null &&
                              _buidingModel.completionDate!
                                  .isAfter(newTerminationDateTime)) {
                            return;
                          }
                          _buidingModel.terminationDate =
                              newTerminationDateTime;
                        });
                      },
                      () {
                        setState(() {
                          _buidingModel.terminationDate = null;
                        });
                        Get.back();
                      },
                      minimumDate: now,
                    );
                  },
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: _getSelectingDateTimeButton(
                  "assets/icons/ic_fluent_clock_24_regular.svg",
                  "Choose Time",
                  _buidingModel.terminationDate != null
                      ? DateFormat('H:m').format(_buidingModel.terminationDate!)
                      : null,
                  () {
                    _hideDoneButtonOverLay();
                    final now = _buidingModel.completionDate ?? DateTime.now();
                    Duration selectedTime = Duration(
                        hours: _buidingModel.terminationDate != null
                            ? _buidingModel.terminationDate!.hour
                            : now.hour,
                        minutes: _buidingModel.terminationDate != null
                            ? _buidingModel.terminationDate!.minute
                            : now.minute);
                    _openTimePickerBottomSheet(
                      selectedTime,
                      (t) {
                        selectedTime = t;
                      },
                      () {
                        final selectedDate =
                            _buidingModel.terminationDate ?? now;
                        final newTerminationDateTime = DateTime(
                          selectedDate.year,
                          selectedDate.month,
                          selectedDate.day,
                          selectedTime.inHours,
                          selectedTime.inMinutes - (selectedTime.inHours * 60),
                        );
                        setState(() {
                          if (_buidingModel.completionDate != null &&
                              _buidingModel.completionDate!
                                  .isAfter(newTerminationDateTime)) {
                            _buidingModel.terminationDate = now;
                            return;
                          }
                          _buidingModel.terminationDate =
                              newTerminationDateTime;
                        });
                      },
                      () {
                        setState(() {
                          _buidingModel.terminationDate = null;
                        });
                        Get.back();
                      },
                    );
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Text(
                '${titlesMarginSpaces}Get alert for this task',
                style: Get.theme.textTheme.headline4!.copyWith(
                  color: Get.theme.colorScheme.secondary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Spacer(),
              Transform.scale(
                scale: .7,
                child: CupertinoSwitch(
                  activeColor: CstColors.a,
                  value: _buidingModel.sendAlert!,
                  onChanged: (v) {
                    setState(() {
                      _buidingModel.sendAlert = v;
                    });
                  },
                ),
              ),
            ],
          ),
        ],

        //
        if (!_showMore) ...[
          const SizedBox(height: 20),
          Center(
            child: MaterialButton(
              onPressed: () async {
                setState(() {
                  _showMore = !_showMore;
                });
              },
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(5),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "Show ${_showMore ? "less" : "more"}",
                    style: Get.textTheme.headline3!
                        .copyWith(color: Colors.blueAccent),
                  ),
                  const SizedBox(
                    width: 5,
                  ),
                  Icon(
                    _showMore
                        ? CupertinoIcons.chevron_up
                        : CupertinoIcons.chevron_down,
                    color: Colors.blueAccent,
                    size: 15,
                  ),
                ],
              ),
            ),
          ),
        ],
        const SizedBox(height: 80),
      ],
    );
  }

  _getCategoryColorCircle(Color color) => SvgPicture.asset(
        'assets/icons/ic_fluent_archive_24_filled.svg',
        color: color,
        height: 15,
      );

  void _openDatePickerBottomSheet(
    DateTime? initialDate,
    Function(DateTime) onDateChanged,
    Function() onDatePick,
    Function() onDateClear, {
    DateTime? maximumDate,
    DateTime? minimumDate,
  }) {
    CoreUtils.BottomSheet.open(
        LayoutBuilder(
          builder: (context, constraints) {
            return Column(
              children: [
                SizedBox(
                  height: Get.size.height / 2.5,
                  child: Stack(
                    children: [
                      Positioned(
                        height: Get.size.height / 2.5,
                        width: constraints.maxWidth,
                        child: CupertinoDatePicker(
                          maximumYear: DateTime.now().year + 40,
                          minimumDate: minimumDate,
                          maximumDate: maximumDate,
                          initialDateTime: initialDate,
                          mode: CupertinoDatePickerMode.date,
                          onDateTimeChanged: onDateChanged,
                        ),
                      ),
                    ],
                  ),
                ),
                _getClearDateAndTimeButton(onDateClear),
                const SizedBox(height: 20)
              ],
            );
          },
        ),
        title: 'Select Date',
        onOkClick: onDatePick,
        onDismiss: () {
          _showDoneButtonOverLay();
        });
  }

  void _openTimePickerBottomSheet(
    Duration initialTime,
    Function(Duration) onTimeChanged,
    Function() onTimePick,
    Function() onTimeClear,
  ) {
    CoreUtils.BottomSheet.open(
        Column(
          children: [
            CupertinoTimerPicker(
              initialTimerDuration: initialTime,
              mode: CupertinoTimerPickerMode.hm,
              onTimerDurationChanged: onTimeChanged,
            ),
            _getClearDateAndTimeButton(onTimeClear),
            const SizedBox(height: 20),
          ],
        ),
        title: "Select Time",
        onOkClick: onTimePick, onDismiss: () {
      _showDoneButtonOverLay();
    });
  }

  Widget _getClearDateAndTimeButton(Function() onClick) => MaterialButton(
        onPressed: onClick,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Icon(
              CupertinoIcons.arrow_right,
              color: Colors.blueAccent,
              size: 15,
            ),
            const SizedBox(
              width: 5,
            ),
            Text(
              "Clear date & time",
              style:
                  Get.textTheme.headline3!.copyWith(color: Colors.blueAccent),
            ),
          ],
        ),
      );

  Widget _getSelectingDateTimeButton(
      String icon, String label, String? subLabel, Function() onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        constraints: const BoxConstraints(minHeight: 48),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 5),
        decoration: BoxDecoration(
          color: Get.theme.colorScheme.surface.withOpacity(.4),
          borderRadius: BorderRadius.circular(12.5),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SvgPicture.asset(
              icon,
              height: 20,
              color: Get.theme.colorScheme.secondary.withOpacity(.5),
            ),
            const SizedBox(
              width: 13,
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: Get.theme.textTheme.headline4!.copyWith(
                    color: Get.theme.colorScheme.secondary.withOpacity(.5),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (subLabel != null)
                  Text(
                    subLabel,
                    style: Get.theme.textTheme.headline4!.copyWith(
                      color: Get.theme.colorScheme.secondary.withOpacity(.5),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _TaskPriority extends StatefulWidget {
  const _TaskPriority({Key? key, required this.onSelectedPriority})
      : super(key: key);
  final Function(TaskPriorities priority) onSelectedPriority;

  @override
  State<_TaskPriority> createState() => __TaskPriorityState();
}

class __TaskPriorityState extends State<_TaskPriority> {
  String? _selectedPriority;
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _getPriorityButton(
            priority: 'Low',
            color: CstColors.e,
            onTap: () => widget.onSelectedPriority(TaskPriorities.low)),
        const SizedBox(
          width: 10,
        ),
        _getPriorityButton(
            priority: 'Medium',
            color: CstColors.d,
            onTap: () => widget.onSelectedPriority(TaskPriorities.medium)),
        const SizedBox(
          width: 10,
        ),
        _getPriorityButton(
            priority: 'High',
            color: CstColors.c,
            onTap: () => widget.onSelectedPriority(TaskPriorities.high)),
      ],
    );
  }

  Widget _getPriorityButton(
      {required String priority,
      required Color color,
      required Function() onTap}) {
    final bool selected = priority == _selectedPriority;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedPriority = priority;
          onTap();
        });
      },
      child: AnimatedContainer(
        duration: 100.milliseconds,
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.5),
          border: Border.all(
              width: 3,
              color: selected
                  ? color
                  : Get.theme.colorScheme.surface.withOpacity(.0)),
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
