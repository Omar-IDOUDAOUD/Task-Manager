import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/data/model/cotegoriy.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/bottomsheets/new_task_bottom_sheet.dart';
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

  late final AnimationController _partsNavigationTopBarAnCtrl;

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
        GetBuilder(
            id: TASKS_TAB_PARTS_WID_ID,
            init: _controller,
            builder: (context) {
              return AnimatedSwitcher(
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
              );
            }),
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

  _getCurrentTabPart() {
    _partsNavigationTopBarAnCtrl.reverse();
    if (_categorySelectedId != null)
      return _SpecificCategoryTasks(
        key: ValueKey(_categorySelectedId),
        categoryId: _categorySelectedId!,
        controller: _controller,
        scrollListener: _tabScrollListener,
      );
    if (_currentPart == 0) {
      return _TodayTasks(
        controller: _controller,
        scrollListener: _tabScrollListener,
      );
    } else if (_currentPart == 1) {
      return _AllTasks(
        key: ValueKey(_currentPart),
        controller: _controller,
        scrollListener: _tabScrollListener,
      );
    } else if (_currentPart == 2) {
      return _Categories(
        key: ValueKey(_currentPart),
        controller: _controller,
        scrollListener: _tabScrollListener,
        onSelectedCatecory: (id, categoryTitle) {
          setState(() {
            _categorySelectedId = id;
            _categorySelectedTitle = categoryTitle;
          });
        },
      );
    }
  }
}

/// PARTS
class _TodayTasks extends StatefulWidget {
  const _TodayTasks(
      {Key? key, required this.scrollListener, required this.controller})
      : super(key: key);
  final TasksController controller;
  final Function(double scrollOffset) scrollListener;

  @override
  State<_TodayTasks> createState() => _TodayTasksState();
}

class _TodayTasksState extends State<_TodayTasks> {
  final List<TaskModel> _data = [];
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMoreData = true;
  int _paginationOffset = 0;
  late final int _paginationLimit;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.controller.onUpdateTodayTasksNotifier
        .removeListener(onUpdateListiner);
  }

  @override
  void initState() {
    widget.controller.onUpdateTodayTasksNotifier.addListener(onUpdateListiner);
    _paginationLimit = (Get.size.height ~/ 150) * 2;
    _scrollController.addListener(() {
      widget.scrollListener(_scrollController.offset);
      if (_canLoadMoreData &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _loadMoreData();
  }

  void onUpdateListiner() {
    final v = widget.controller.onUpdateTodayTasksNotifier.value;
    if (v!.isAddNewTask) {
      _data.insert(0, v.task!);
      widget.controller.todayTasksListKey.currentState!
          .insertItem(1, duration: 900.milliseconds);
      _paginationOffset++;
    } else {
      if (v.index! < _data.length) _data.removeAt(v.index!);
      widget.controller.todayTasksListKey.currentState!.removeItem(v.index!,
          (_, a) {
        return SizedBox.shrink();
      }, duration: 900.milliseconds);
    }
  }

  void _loadMoreData() async {
    final newData = await widget.controller
        .getTodaysTasks(_paginationOffset, paginationLimit: _paginationLimit);
    _paginationOffset += _paginationLimit;

    newData.forEach((element) {
      _data.add(element);
      widget.controller.todayTasksListKey.currentState!
          .insertItem(_data.length, duration: 500.milliseconds);
    });

    if (newData.length < _paginationLimit) {
      setState(() {
        _canLoadMoreData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: widget.controller.todayTasksListKey,
      padding: const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
      controller: _scrollController,
      initialItemCount: _data.length + 2,
      itemBuilder: (ctx, index, animation) {
        if (index == 0)
          return _Title(
            title: 'Today\'s Task',
            subTitle: DateFormat.MMMMEEEEd().format(DateTime.now()),
          ).marginOnly(bottom: 20);
        index--;
        return index < _data.length
            ? SizeTransition(
                sizeFactor: CurvedAnimation(
                    parent: animation, curve: Curves.linearToEaseOut),
                child: SingleChildScrollView(
                  child: TaskCard(
                    data: _data.elementAt(index),
                  ).marginOnly(bottom: 15),
                ),
              )
            : _canLoadMoreData
                ? const CupertinoActivityIndicator()
                : _data.isEmpty
                    ? const Text('no data')
                    : const SizedBox.shrink();
      },
    );
  }
}

class _AllTasks extends StatefulWidget {
  const _AllTasks(
      {Key? key, required this.controller, required this.scrollListener})
      : super(key: key);
  final TasksController controller;
  final Function(double scrollOffset) scrollListener;

  @override
  State<_AllTasks> createState() => _AllTasksState();
}

class _AllTasksState extends State<_AllTasks> {
  final List<TaskModel> _data = [];
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMoreData = true;
  int _paginationOffset = 0;
  late final int _paginationLimit;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.controller.onUpdateAllTasksNotifier.removeListener(onUpdateListiner);
  }

  @override
  void initState() {
    widget.controller.onUpdateAllTasksNotifier.addListener(onUpdateListiner);
    _paginationLimit = (Get.size.height ~/ 150) * 2;
    _scrollController.addListener(() {
      widget.scrollListener(_scrollController.offset);
      if (_canLoadMoreData &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _loadMoreData();
  }

  void onUpdateListiner() {
    final v = widget.controller.onUpdateAllTasksNotifier.value;
    if (v!.isAddNewTask) {
      _data.insert(0, v.task!);
      widget.controller.allTasksListKey.currentState!
          .insertItem(1, duration: 900.milliseconds);
      _paginationOffset++;
    } else {
      if (v.index! < _data.length) _data.removeAt(v.index!);
      widget.controller.allTasksListKey.currentState!.removeItem(v.index!,
          (_, a) {
        return SizedBox.shrink();
      }, duration: 900.milliseconds);
    }
  }

  void _loadMoreData() async {
    final newData = await widget.controller
        .getAllTasks(_paginationOffset, paginationLimit: _paginationLimit);
    _paginationOffset += _paginationLimit;

    newData.forEach((element) {
      _data.add(element);
      widget.controller.allTasksListKey.currentState!
          .insertItem(_data.length, duration: 500.milliseconds);
    });

    if (newData.length < _paginationLimit) {
      setState(() {
        _canLoadMoreData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: widget.controller.allTasksListKey,
      padding: const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
      controller: _scrollController,
      initialItemCount: _data.length + 2,
      itemBuilder: (ctx, index, animation) {
        if (index == 0)
          return _Title(
                  title: 'All Tasks',
                  subTitle: DateFormat.MMMMEEEEd().format(DateTime.now()))
              .marginOnly(bottom: 20);
        index--;
        return index < _data.length
            ? SizeTransition(
                sizeFactor: CurvedAnimation(
                    parent: animation, curve: Curves.linearToEaseOut),
                child: SingleChildScrollView(
                  child: TaskCard(
                    data: _data.elementAt(index),
                  ).marginOnly(bottom: 15),
                ),
              )
            : _canLoadMoreData
                ? const CupertinoActivityIndicator()
                : _data.isEmpty
                    ? const Text('no data')
                    : const SizedBox.shrink();
      },
    );
  }
}

class _Categories extends StatefulWidget {
  const _Categories({
    Key? key,
    required this.onSelectedCatecory,
    required this.controller,
    required this.scrollListener,
  }) : super(key: key);
  final TasksController controller;
  final Function(double scrollOffset) scrollListener;
  final Function(int id, String categoryTitle) onSelectedCatecory;

  @override
  State<_Categories> createState() => _CategoriesState();
}

class _CategoriesState extends State<_Categories> {
  final List<CategoryModel> _data = [];
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMoreData = true;
  int _paginationOffset = 0;
  late final int _paginationLimit;

  @override
  void initState() {
    // TODO: implement initState
    _paginationLimit = (Get.size.height ~/ 120) * 2;
    _scrollController.addListener(() {
      widget.scrollListener(_scrollController.offset);
      if (_canLoadMoreData &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _loadMoreData();
  }

  void _loadMoreData() async {
    final newData = await widget.controller
        .getCategories(_paginationOffset, paginationLimit: _paginationLimit);
    // await 2.seconds.delay();
    _paginationOffset += _paginationLimit;
    setState(() {
      _data.addAll(newData);
      if (newData.length < _paginationLimit) _canLoadMoreData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      controller: _scrollController,
      padding: const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
      child: StaggeredGrid.count(
        crossAxisCount: 2,
        mainAxisSpacing: 10,
        crossAxisSpacing: 10,
        children: List.generate(
          _data.length + 2,
          (index) {
            if (index < _data.length)
              return _CategoryCard(
                onTap: () => widget.onSelectedCatecory(
                    _data.elementAt(index).id!, _data.elementAt(index).title!),
                data: _data.elementAt(index),
              );
            return _canLoadMoreData
                ? _LoadingCategoryCardWidgetIndicator()
                : const SizedBox.shrink();
          },
        ),
      ),
    );
  }
}

class _LoadingCategoryCardWidgetIndicator extends StatefulWidget {
  _LoadingCategoryCardWidgetIndicator({
    Key? key,
  }) : super(key: key);

  @override
  State<_LoadingCategoryCardWidgetIndicator> createState() =>
      _LoadingCategoryCardWidgetIndicatorState();
}

class _LoadingCategoryCardWidgetIndicatorState
    extends State<_LoadingCategoryCardWidgetIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _animation;

  _getAWidthFcator() {
    double widthFactor = Random.secure().nextDouble() * 1;
    while (widthFactor < 0.5) {
      widthFactor = _getAWidthFcator();
    }
    return widthFactor;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: 500.milliseconds)
          ..addListener(() {
            setState(() {});
          });
    _animation = ColorTween(
            begin: Get.theme.scaffoldBackgroundColor.withOpacity(.2),
            end: Get.theme.scaffoldBackgroundColor)
        .animate(_animationController);
    _animationController.repeat(reverse: true);
    _wf1 = _getAWidthFcator();
    _wf2 = _getAWidthFcator();
  }

  late final double _wf1;
  late final double _wf2;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Get.theme.colorScheme.tertiary.withOpacity(.5),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 15,
                child: FractionallySizedBox(
                  widthFactor: _wf1,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _animation.value,
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 5,
              ),
              SizedBox(
                height: 15,
                child: FractionallySizedBox(
                  widthFactor: _wf2,
                  heightFactor: 1,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      color: _animation.value,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

///
///
class _LoadingTaskCardWidgetIndicator extends StatefulWidget {
  _LoadingTaskCardWidgetIndicator({
    Key? key,
  }) : super(key: key);

  @override
  State<_LoadingTaskCardWidgetIndicator> createState() =>
      _LoadingTaskCardWidgetIndicatorState();
}

class _LoadingTaskCardWidgetIndicatorState
    extends State<_LoadingTaskCardWidgetIndicator>
    with TickerProviderStateMixin {
  late final AnimationController _animationController;
  late final Animation<Color?> _animation;

  _getAWidthFcator() {
    double widthFactor = Random.secure().nextDouble() * 1;

    while (widthFactor < 0.2) {
      widthFactor = _getAWidthFcator();
    }
    return widthFactor;
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    _animationController =
        AnimationController(vsync: this, duration: 500.milliseconds)
          ..addListener(() {
            setState(() {});
          });
    _animation = ColorTween(
            begin: Get.theme.scaffoldBackgroundColor.withOpacity(.2),
            end: Get.theme.scaffoldBackgroundColor)
        .animate(_animationController);
    _animationController.repeat(reverse: true);
    _wf1 = _getAWidthFcator();
    _wf2 = _getAWidthFcator();
  }

  late final double _wf1;
  late final double _wf2;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: Get.theme.colorScheme.tertiary.withOpacity(.3),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 15,
              child: FractionallySizedBox(
                widthFactor: _wf1,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _animation.value,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 8,
              child: FractionallySizedBox(
                widthFactor: _wf2,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _animation.value,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 5,
            ),
            SizedBox(
              height: 8,
              child: FractionallySizedBox(
                widthFactor: _wf2 / 2,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: _animation.value,
                  ),
                ),
              ),
            ),
            const SizedBox(
              height: 15,
            ),
            Row(
              children: [
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 10,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: _animation.value,
                      ),
                    ),
                  ),
                ),
                const Spacer(
                  flex: 2,
                ),
                Expanded(
                  flex: 1,
                  child: SizedBox(
                    height: 20,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: _animation.value,
                      ),
                    ),
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

class _SpecificCategoryTasks extends StatefulWidget {
  const _SpecificCategoryTasks(
      {Key? key,
      required this.categoryId,
      required this.scrollListener,
      required this.controller})
      : super(key: key);
  final int categoryId;
  final Function(double scrollOffset) scrollListener;

  final TasksController controller;

  @override
  State<_SpecificCategoryTasks> createState() => _SpecificCategoryTasksState();
}

class _SpecificCategoryTasksState extends State<_SpecificCategoryTasks> {
  final List<TaskModel> _data = [];
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMoreData = true;
  int _paginationOffset = 0;
  late final int _paginationLimit;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    widget.controller.onUpdateCategoryTasksTasksNotifier
        .removeListener(onUpdateListiner);
  }

  @override
  void initState() {
    widget.controller.onUpdateCategoryTasksTasksNotifier
        .addListener(onUpdateListiner);
    _paginationLimit = (Get.size.height ~/ 150) * 2;
    _scrollController.addListener(() {
      widget.scrollListener(_scrollController.offset);
      if (_canLoadMoreData &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _loadMoreData();
  }

  void onUpdateListiner() {
    final v = widget.controller.onUpdateCategoryTasksTasksNotifier.value;
    if (v!.isAddNewTask) {
      _data.insert(0, v.task!);
      widget.controller.categoryTasksListKey.currentState!
          .insertItem(1, duration: 900.milliseconds);
      _paginationOffset++;
    } else {
      if (v.index! < _data.length) _data.removeAt(v.index!);
      widget.controller.categoryTasksListKey.currentState!.removeItem(v.index!,
          (_, a) {
        return const SizedBox.shrink();
      }, duration: 900.milliseconds);
    }
  }

  void _loadMoreData() async {
    final newData = await widget.controller.getCategoryTasks(widget.categoryId,
        paginationOffset: _paginationOffset, paginationLimit: _paginationLimit);
    _paginationOffset += _paginationLimit;

    newData.forEach((element) {
      _data.add(element);
      widget.controller.categoryTasksListKey.currentState!
          .insertItem(_data.length - 1, duration: 500.milliseconds);
    });

    if (newData.length < _paginationLimit) {
      setState(() {
        _canLoadMoreData = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedList(
      key: widget.controller.categoryTasksListKey,
      padding: const EdgeInsets.only(top: 70, bottom: 25, left: 25, right: 25),
      controller: _scrollController,
      initialItemCount: _data.length + 1,
      itemBuilder: (ctx, index, animation) {
        return index < _data.length
            ? SizeTransition(
                sizeFactor: CurvedAnimation(
                    parent: animation, curve: Curves.linearToEaseOut),
                child: SingleChildScrollView(
                  child: TaskCard(
                    data: _data.elementAt(index),
                  ).marginOnly(bottom: 15),
                ),
              )
            : _canLoadMoreData
                ? const CupertinoActivityIndicator()
                : _data.isEmpty
                    ? const Text('no data')
                    : const SizedBox.shrink();
      },
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
        NewTaskBottomSheet.open();
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
        padding: const EdgeInsets.all(20),
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
