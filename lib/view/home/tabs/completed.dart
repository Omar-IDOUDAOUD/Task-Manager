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
  void initState() {
    // TODO: implement initState
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

  void _loadMoreData() async {
    final newData = await _controller.getCompletedTasks(_paginationOffset,
        paginationLimit: _paginationLimit);
    _paginationOffset += _paginationLimit;
    setState(() {
      _data.addAll(newData);
      if (newData.length < _paginationLimit) _canLoadMoreData = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(25),
      controller: _scrollController,
      itemCount: _data.length + 1,
      itemBuilder: (ctx, index) {
        return index < _data.length
            ? TaskCard(
                data: _data.elementAt(index),
              )
            : _canLoadMoreData
                ? CupertinoActivityIndicator()
                : _data.isEmpty
                    ? Text('no data')
                    : SizedBox.shrink();
      },
    );
  }
}
