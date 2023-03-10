// ignore_for_file: curly_braces_in_flow_control_structures

import 'dart:math';

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

List<String> Logs = [];
ValueNotifier<String?> LogViewerNotifier = ValueNotifier(null)
  ..addListener(() {
    Logs.add(LogViewerNotifier.value!);
  });

class _TestScreenState extends State<TestScreen> {
  TasksController _controller = Get.find();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("log viewer"),
        actions: [
          IconButton(
              onPressed: () {
                Logs.clear();
                LogViewerNotifier.notifyListeners();
              },
              icon: Icon(Icons.cleaning_services_rounded))
        ],
      ),
      body: ColoredBox(
        color: Colors.blue,
        child: Column(
          children: [
            Expanded(
              child: ValueListenableBuilder<String?>(
                valueListenable: LogViewerNotifier,
                builder: (_, String? log, c) {
                  // if (log != null) _logList.add(log);
                  return ListView.builder(
                    itemCount: Logs.length,
                    itemBuilder: (_, i) => ListTile(
                      leading: Icon(
                        Icons.info_outline_rounded,
                        color: Colors.white,
                      ),
                      title: Text(
                        Logs.elementAt(i),
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(15.0),
              child: Wrap(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                alignment: WrapAlignment.center,
                spacing: 10,
                runSpacing: 10,
                children: [
                  MaterialButton(
                    color: Colors.white,
                    child: Text("log tester"),
                    onPressed: () {
                      PrintLogOnScreen("test log");
                    },
                  ),
                  MaterialButton(
                    color: Colors.white,
                    child: Text("insert task"),
                    onPressed: () async {
                      PrintLogOnScreen("Inserting task started");
                      final d = await _controller.createTask(
                        TaskModel(
                          title: 'hhh',
                          categoryId: 1,
                          completed: false,
                          creationDate: DateTime.now(),
                          completionDate: DateTime.now().add(1.hours),
                          priority: TaskPriorities.low,
                          sendAlert: false,
                          terminationDate: DateTime.now().add(1.hours),
                          description: 'test desc',
                        ),
                      );
                      PrintLogOnScreen("Inserting task finish");
                    },
                  ),
                  MaterialButton(
                    color: Colors.white,
                    child: Text("load taday data"),
                    onPressed: () async {
                      PrintLogOnScreen("loding today tasks start");
                      final d = await _controller.getTodaysTasks(0);
                      PrintLogOnScreen(
                          "loding today tasks finish, data: ${d.map((e) => [
                                e.id,
                                e.title
                              ])}");
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

void PrintLogOnScreen(String msg) {
  final rv = Random.secure().nextInt(1000);
  LogViewerNotifier.value = "log N: $rv: $msg";
  // print("-------------->${LogViewerNotifier.value}");
}
