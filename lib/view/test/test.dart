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
  // final TasksController _ctrl = Get.find();
  // final List<TaskModel> _data = [];
  // final ScrollController _scrollController = ScrollController();
  // bool _canLoadMoreData = true;
  // int _paginationOffset = 0;

  // final _mylistkey = GlobalKey<AnimatedListState>();
  // final _mylist = List.generate(50, (index) => "item $index");
  // final _mytween = Tween(begin: Offset.zero, end: Offset.zero);

  @override
  void initState() {
    // TODO: implement initState
    // _scrollController.addListener(() {
    //   if (_canLoadMoreData &&
    //       _scrollController.offset ==
    //           _scrollController.position.maxScrollExtent) {
    //     _loadMoreData();
    //   }
    // });
    // _loadMoreData();
  }

  int _p = 0;

  _getWidget() {
    if (_p == 0)
      return Container(
        key: ValueKey(_p),
        height: 50,
        width: 100,
        color: Colors.red,
      );
    if (_p == 1)
      return Container(
        key: ValueKey(_p),
        height: 100,
        width: 50,
        color: Colors.green,
      );
    if (_p == 2)
      return Container(
        key: ValueKey(_p),
        height: 80,
        width: 80,
        color: Colors.purple,
      );
  }

  final ot = Tween(begin: Offset(-1, 0), end: Offset.zero);
  // final _mytweenoffsetstart = Tween(begin: Offset.zero, end: Offset.zero);
  // final _mytweenoffsetend = Tween(begin: Offset(1, 0), end: Offset.zero);
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          setState(() {
            if (_p == 2) {
              _p = 0;
              return;
            }
            _p++;
          });
        },
        child: PageView.builder(
          itemBuilder: (ctx, i) {
            print('build item $i');
            return SizedBox.square(
              dimension: 200,
              child: ColoredBox(
                color: Colors.green,
                child: Center(
                  child: Text("$i"),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
