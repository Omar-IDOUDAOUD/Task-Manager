import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/view/home/home.dart';

void main() {
  runApp(const TaskManger());
}

class TaskManger extends StatelessWidget {
  const TaskManger({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const Home(),
    );
  }
}
