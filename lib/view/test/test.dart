// ignore_for_file: curly_braces_in_flow_control_structures

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:get/get.dart';
import 'package:task_manager/controller/home/tasks_controller.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  final TasksController _ctrl = Get.find();
  final List<TaskModel> _data = [];
  final ScrollController _scrollController = ScrollController();
  bool _canLoadMoreData = true;
  int _paginationOffset = 0;

  @override
  void initState() {
    // TODO: implement initState
    _scrollController.addListener(() {
      if (_canLoadMoreData &&
          _scrollController.offset ==
              _scrollController.position.maxScrollExtent) {
        _loadMoreData();
      }
    });
    _loadMoreData();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Testing Screen'),
        centerTitle: true,
      ),
      body: Text('data'), 
    );
  }

  void _loadMoreData() async {
    final newData = await _ctrl.getAllTasks(_paginationOffset);
    _paginationOffset += 10;
    setState(() {
      if (newData.isEmpty) _canLoadMoreData = false;
      _data.addAll(newData);
    });
  }
}
