import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/new_task_bottom_sheet.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

/// MAIN ABSTRACT
class TasksTab extends StatefulWidget {
  const TasksTab({Key? key}) : super(key: key);

  @override
  State<TasksTab> createState() => _TasksTabState();
}

class _TasksTabState extends State<TasksTab>
    with SingleTickerProviderStateMixin {
  int _currentPart = 0;
  int? _categorySelectedId;
  String? _categorySelectedTitle;

  late AnimationController _partsNavigationTopBarAnCtrl;

  final _partsFadeTransitionDuration = 500.milliseconds;

  @override
  void initState() {
    super.initState();
    _partsNavigationTopBarAnCtrl = AnimationController(
        vsync: this, duration: 100.milliseconds, lowerBound: 0, upperBound: 65);
  }

  final TasksController _controller = Get.find();

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        AnimatedSwitcher(
          layoutBuilder: (currentChild, previousChild) {
            return Align(
              alignment: Alignment.topCenter,
              child: currentChild,
            );
          },
          duration: _partsFadeTransitionDuration,
          transitionBuilder: (child, animation) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          child: _getCurrentTabPart(),
        ),
        // ),
        AnimatedBuilder(
          animation: CurvedAnimation(
            curve: Curves.linearToEaseOut,
            parent: _partsNavigationTopBarAnCtrl,
          ),
          builder: (ctx, child) => Positioned(
            top: 0,
            right: 0,
            left: 0,
            height: _partsNavigationTopBarAnCtrl.value,
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: Get.theme.scaffoldBackgroundColor,
                borderRadius:
                    const BorderRadius.vertical(bottom: Radius.circular(20)),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(.1),
                    blurRadius: 50,
                  ),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 0,
          left: 0,
          child: _TasksTabPartsNavigation(
            specificCategoryName:
                _categorySelectedId != null ? _categorySelectedTitle : null,
            onChangedPart: (newPart) {
              if (_currentPart != newPart)
                setState(
                  () {
                    _currentPart = newPart;
                    _categorySelectedId = null;
                  },
                );
            },
          ),
        ),
        Positioned(
          top: 12,
          left: 25,
          child: AnimatedScale(
            duration: 200.milliseconds,
            curve: Curves.easeInToLinear,
            scale: _categorySelectedId != null ? 1 : 0,
            child: GestureDetector(
              onTap: () {
                _controller.deleteLastSavedCategoryTasks(); 
                setState(() {
                  _categorySelectedId = null;
                });
              },
              child: SizedBox.square(
                dimension: 35,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(.15),
                        blurRadius: 20,
                      ),
                    ],
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: Get.theme.colorScheme.secondary,
                    size: 15,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _tabScrollListener(double scrollOffset) {
    if (scrollOffset > 20)
      _partsNavigationTopBarAnCtrl.forward();
    else
      _partsNavigationTopBarAnCtrl.reverse();
  }

  _TodayTasks? _todayTasksWidget;
  _AllTasks? _allTasksWidget;
  _Categories? _categoriesWidget;

  _getCurrentTabPart() {
    _partsNavigationTopBarAnCtrl.reverse();
    if (_categorySelectedId != null)
      return _SpecificCategoryTasks(
        categoryId: _categorySelectedId!,
        controller: _controller,
        scrollListener: _tabScrollListener,
      );
    if (_currentPart == 0) {
      _todayTasksWidget ??= _TodayTasks(
        controller: _controller,
        scrollListener: _tabScrollListener,
      );
      return _todayTasksWidget;
    } else if (_currentPart == 1) {
      _allTasksWidget ??= _AllTasks(
        controller: _controller,
        scrollListener: _tabScrollListener,
      );
      return _allTasksWidget;
    } else if (_currentPart == 2) {
      _categoriesWidget ??= _Categories(
        controller: _controller,
        scrollListener: _tabScrollListener,
        onSelectedCatecory: (id, categoryTitle) {
          setState(() {
            _categorySelectedId = id;
            _categorySelectedTitle = categoryTitle;
          });
        },
      );
      return _categoriesWidget;
    }
  }
}

/// PARTS
class _TodayTasks extends StatelessWidget {
  _TodayTasks({Key? key, this.scrollListener, required this.controller})
      : super(key: key);
  final TasksController controller;
  final Function(double scrollOffset)? scrollListener;
  // int _lastLoadedDataLength = 0;
  // int _getLastLoadedDataLength(newValue) {
  //   final copy = _lastLoadedDataLength;
  //   _lastLoadedDataLength = newValue;
  //   return copy;
  // }

  bool get _getCanLoadMoreData {
    final copy = controller.canLoadMoreDataInTodaysTasksPart;
    controller.canLoadMoreDataInTodaysTasksPart = true;
    return copy ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.canLoadMoreDataInTodaysTasksPart != null)
      controller.canLoadMoreDataInTodaysTasksPart = false;
    return GetBuilder<TasksController>(
      init: controller,
      builder: (controller) {
        return ListView(
          controller: controller.tasksTabToaysTasksScrollController
            ..addListener(() {
              if (scrollListener != null)
                scrollListener!(
                    controller.tasksTabToaysTasksScrollController.offset);
            }),
          padding:
              const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
          children: [
            _Title(
              title: 'Today\'s Task',
              subTitle: 'Wednesday, May 20',
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<TaskModel>>(
              future: controller.getTodaysTasks(_getCanLoadMoreData),
              builder: (ctx, screenShot) {
                return Column(
                  children: [
                    if (screenShot.hasData)
                      ...List.generate(
                        screenShot.data!.length,
                        (index) => Padding(
                          padding: EdgeInsets.only(bottom: 20),
                          child: TaskCard(
                            data: screenShot.data!.elementAt(index),
                          ),
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
            ),
          ],
        );
      },
      id: TODAYS_TASKS_WID_ID,
    );
  }
}

class _AllTasks extends StatelessWidget {
  const _AllTasks({Key? key, required this.controller, this.scrollListener})
      : super(key: key);
  final Function(double scrollOffset)? scrollListener;

  final TasksController controller;
  bool get _getCanLoadMoreData {
    var copy = controller.canLoadMoreDataInAllTasksPart;
    controller.canLoadMoreDataInAllTasksPart = true;
    return copy ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.canLoadMoreDataInAllTasksPart != null)
      controller.canLoadMoreDataInAllTasksPart = false;
    return GetBuilder<TasksController>(
      init: controller,
      builder: (controller) {
        return ListView(
          controller: controller.tasksTabAllTasksScrollController
            ..addListener(() {
              if (scrollListener != null)
                scrollListener!(
                    controller.tasksTabAllTasksScrollController.offset);
            }),
          padding:
              const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
          children: [
            _Title(
              title: "All Tasks",
              subTitle: "20% of tasks completed",
            ),
            SizedBox(
              height: 20,
            ),
            FutureBuilder<List<TaskModel>>(
              future: controller.getAllTasks(_getCanLoadMoreData),
              builder: (ctx, screenShot) {
                return Column(
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
            ),
          ],
        );
      },
      id: ALL_TASKS_WID_ID,
    );
  }
}

class _Categories extends StatelessWidget {
  const _Categories({
    Key? key,
    required this.onSelectedCatecory,
    required this.controller,
    this.scrollListener,
  }) : super(key: key);
  final TasksController controller;
  final Function(double scrollOffset)? scrollListener;
  final Function(int id, String categoryTitle) onSelectedCatecory;
  bool get _getCanLoadMoreData {
    var copy = controller.canLoadMoreDataInCategoriesPart;
    controller.canLoadMoreDataInCategoriesPart = true;
    return copy ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.canLoadMoreDataInCategoriesPart != null)
      controller.canLoadMoreDataInCategoriesPart = false;
    return GetBuilder<TasksController>(
      init: controller,
      builder: (controller) => SingleChildScrollView(
        controller: controller.tasksTabCategoriesScrollController
          ..addListener(() {
            if (scrollListener != null)
              scrollListener!(
                  controller.tasksTabCategoriesScrollController.offset);
          }),
        padding:
            const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
        child: FutureBuilder<List<CategoryModel>>(
          future: controller.getCategories(_getCanLoadMoreData),
          builder: (ctx, screenShot) {
            return Column(
              children: [
                if (screenShot.hasData)
                  StaggeredGrid.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    children: List.generate(
                      screenShot.data!.length,
                      (index) => _CategoryCard(
                        onTap: () => onSelectedCatecory(
                            screenShot.data!.elementAt(index).id!,
                            screenShot.data!.elementAt(index).title!),
                        data: screenShot.data!.elementAt(index),
                      ),
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
        ),
      ),
      id: CATEGORIES_WID_ID,
    );
  }
}

class _SpecificCategoryTasks extends StatelessWidget {
  const _SpecificCategoryTasks(
      {Key? key,
      required this.categoryId,
      this.scrollListener,
      required this.controller})
      : super(key: key);
  final int categoryId;
  final Function(double scrollOffset)? scrollListener;

  final TasksController controller;
  bool get _getCanLoadMoreData {
    var copy = controller.canLoadMoreDataInCategoryTasks;
    controller.canLoadMoreDataInCategoryTasks = true;
    return copy ?? true;
  }

  @override
  Widget build(BuildContext context) {
    if (controller.canLoadMoreDataInCategoryTasks != null)
      controller.canLoadMoreDataInCategoryTasks = false;
    return GetBuilder<TasksController>(
      builder: (controller) => SingleChildScrollView(
        controller: controller.categoryTasksScrollController
          ..addListener(() {
            if (scrollListener != null)
              scrollListener!(controller.categoryTasksScrollController.offset);
          }),
        padding:
            const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
        child: FutureBuilder<List<TaskModel>>(
          future: controller.getCategoryTasks(categoryId, _getCanLoadMoreData),
          builder: (ctx, screenShot) {
            return Column(
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
        ),
      ),
      id: CATEGORYTASKS_WID_ID,
    );
  }
}

/// WIDGETS

class _Title extends StatelessWidget {
  const _Title({
    Key? key,
    required this.title,
    required this.subTitle,
  }) : super(key: key);
  final String title;
  final String subTitle;

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
              title,
              style: Get.theme.textTheme.headline6!.copyWith(height: 1),
            ),
            Text(
              subTitle,
              style: Get.theme.textTheme.headline3,
            ),
          ],
        ),
        const _AddTaskButton(),
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
      onTap: () {
        Get.bottomSheet(NewTaskBottomSheetWidget(),
            isScrollControlled: true,
            ignoreSafeArea: true,
            isDismissible: true,
            barrierColor: Colors.transparent);
      },
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
  const _TasksTabPartsNavigation(
      {Key? key, required this.onChangedPart, this.specificCategoryName})
      : super(key: key);
  final String? specificCategoryName;
  final Function(int newPart) onChangedPart;

  @override
  State<_TasksTabPartsNavigation> createState() =>
      TasksTabPartsNavigationState();
}

class TasksTabPartsNavigationState extends State<_TasksTabPartsNavigation> {
  int _currentPart = 0;
  final _controller = Get.find<TasksController>();
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(vertical: 22.5, horizontal: 25),
          scrollDirection: Axis.horizontal,
          reverse: true,
          child: Row(
            children: [
              GestureDetector(
                onTap: () => setState(() {
                  _currentPart = 0;
                  widget.onChangedPart(0);
                }),
                child: AnimatedDefaultTextStyle(
                  style: Get.theme.textTheme.headline4!.copyWith(
                    color: _currentPart == 0
                        ? CstColors.a
                        : Get.theme.colorScheme.secondary,
                    fontWeight:
                        _currentPart == 0 ? FontWeight.bold : FontWeight.w400,
                  ),
                  duration: 200.milliseconds,
                  child: const Text(
                    "Today's Tasks",
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: _currentPart == 0
                        ? CstColors.a
                        : Get.theme.colorScheme.secondary,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Obx(() {
                    return Text(
                      _controller.todayTasksNumber.value.toString(),
                      style: Get.theme.textTheme.headline1?.copyWith(
                        color: Get.theme.scaffoldBackgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  })),
              _divider(),
              GestureDetector(
                onTap: () => setState(() {
                  _currentPart = 1;
                  widget.onChangedPart(1);
                }),
                child: AnimatedDefaultTextStyle(
                  style: Get.theme.textTheme.headline4!.copyWith(
                    color: _currentPart == 1
                        ? CstColors.a
                        : Get.theme.colorScheme.secondary,
                    fontWeight:
                        _currentPart == 1 ? FontWeight.bold : FontWeight.w400,
                  ),
                  duration: 200.milliseconds,
                  child: const Text(
                    "All Tasks",
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                decoration: BoxDecoration(
                  color: _currentPart == 1
                      ? CstColors.a
                      : Get.theme.colorScheme.secondary,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Obx(
                  () {
                    return Text(
                      _controller.allTasksNumber.value.toString(),
                      style: Get.theme.textTheme.headline1?.copyWith(
                        color: Get.theme.scaffoldBackgroundColor,
                        fontWeight: FontWeight.bold,
                      ),
                    );
                  },
                ),
              ),
              _divider(),
              GestureDetector(
                onTap: () => setState(() {
                  if (widget.specificCategoryName != null) return;
                  _currentPart = 2;
                  widget.onChangedPart(2);
                }),
                child: AnimatedSize(
                  duration: 200.milliseconds,
                  curve: Curves.linearToEaseOut,
                  alignment: Alignment.centerLeft,
                  child: AnimatedDefaultTextStyle(
                    style: Get.theme.textTheme.headline4!.copyWith(
                      color: _currentPart == 2
                          ? CstColors.a
                          : Get.theme.colorScheme.secondary,
                      fontWeight:
                          _currentPart == 2 ? FontWeight.bold : FontWeight.w400,
                    ),
                    duration: 200.milliseconds,
                    child: Text(
                      "Categories${widget.specificCategoryName != null ? " > ${widget.specificCategoryName}" : ""}",
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  _divider() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: SizedBox(
          width: 1,
          height: 13,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(1),
              color: Get.theme.colorScheme.secondary,
            ),
          ),
        ),
      );
}

class _CategoryCard extends StatelessWidget {
  const _CategoryCard({
    Key? key,
    required this.onTap,
    required this.data,
  }) : super(key: key);
  final Function() onTap;
  final CategoryModel data;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: data.color,
        ),
        padding: EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SvgPicture.asset(
                  'assets/icons/ic_fluent_archive_24_filled.svg',
                  color: Colors.white,
                  height: 13,
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: Text(
                    data.title!,
                    overflow: TextOverflow.ellipsis,
                    style: Get.theme.textTheme.headline5?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                ),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    data.tasksNumber.toString(),
                    style: Get.theme.textTheme.headline1?.copyWith(
                      color: CstColors.b,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            if (data.threeLastTasksTitles!.isNotEmpty) ...[
              const SizedBox(
                height: 5,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: List.generate(
                  data.threeLastTasksTitles!.length,
                  (index) {
                    final cell = data.threeLastTasksTitles!.elementAt(index);
                    if (cell == null) return const SizedBox.shrink();
                    return Text(
                      cell,
                      style: Get.theme.textTheme.headline1?.copyWith(
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white.withOpacity(.8),
                        decoration: TextDecoration.lineThrough,
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(
                height: 5,
              ),
            ],
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Productivity',
                  style: Get.theme.textTheme.headline5?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: data.productivityPerCentage!.toInt().toString(),
                    style: const TextStyle(
                      height: 1,
                      fontSize: 25,
                      color: Colors.white,
                      fontFamily: "Puppins",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  const TextSpan(
                    text: '%',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                      fontFamily: "Puppins",
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 3,
            ),
            LayoutBuilder(
              builder: (BuildContext ctx, BoxConstraints constraints) {
                return Container(
                  height: 7,
                  width: constraints.maxWidth,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(.5),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  child: FractionallySizedBox(
                    widthFactor: data.productivityPerCentage! * 0.01,
                    alignment: Alignment.centerLeft,
                    heightFactor: 1.0,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
