import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

class CompletedTab extends StatefulWidget {
  CompletedTab({Key? key}) : super(key: key);

  @override
  State<CompletedTab> createState() => _CompletedTabState();
}

class _CompletedTabState extends State<CompletedTab> {
  final TasksController _controller = Get.find();

  final List<TaskModel> _data = [];

  final ScrollController _scrollController = ScrollController();

  bool _canLoadMoreData = true;

  int _paginationOffset = 0;

  late final int _paginationLimit;

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.onUpdateCompletedTasksNotifier.removeListener(onUpdateListiner);
  }

  @override
  void initState() {
    _controller.onUpdateCompletedTasksNotifier.addListener(onUpdateListiner);
    _paginationLimit = (Get.size.height ~/ 150) * 2;
    _scrollController.addListener(() {
      if (_canLoadMoreData &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _loadMoreData();
  }

  void onUpdateListiner() {
    final v = _controller.onUpdateCompletedTasksNotifier.value;
    if (v!.isAddNewTask) {
      _data.insert(0, v.task!);
      _controller.completedTasksListKey.currentState!
          .insertItem(1, duration: 900.milliseconds);
      _paginationOffset++;
    } else {
      if (v.index! < _data.length) _data.removeAt(v.index!);
      _controller.completedTasksListKey.currentState!.removeItem(v.index!,
          (_, a) {
        return SizedBox.shrink();
      }, duration: 900.milliseconds);
    }
  }

  void _loadMoreData() async {
    final newData = await _controller.getCompletedTasks(_paginationOffset,
        paginationLimit: _paginationLimit);
    _paginationOffset += _paginationLimit;

    newData.forEach((element) {
      _data.add(element);
      _controller.completedTasksListKey.currentState!
          .insertItem(_data.length-1, duration: 500.milliseconds);
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
      key: _controller.completedTasksListKey,
      padding: const EdgeInsets.all(25),
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
