import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/view/home/tabs/tasks.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: TabBar(
        controller: TabController(length: 3, vsync: this),
        overlayColor: MaterialStateProperty.all(Colors.transparent),
        indicatorSize: TabBarIndicatorSize.label,
        indicatorWeight: 1.5,
        tabs: const [
          Tab(
            child: Text(
              "Tasks",
            ),
          ),
          Tab(
            child: Text(
              "Completed",
            ),
          ),
          Tab(
            child: Text(
              "Profile",
            ),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(
            height: 46,
            child: ColoredBox(color: Colors.white),
          ),
          Divider(
            color: Get.theme.colorScheme.surface,
            thickness: 0,
            height: 1.5,
          ),
          Expanded(
            child: ColoredBox(
              color: Get.theme.colorScheme.background,
              child: TasksTab(),
            ),
          )
        ],
      ),
    );
  }
}
