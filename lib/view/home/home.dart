import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/view/home/tabs/tasks.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with TickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    // TODO: implement initState
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Get.theme.scaffoldBackgroundColor,
      child: SafeArea(
        bottom: false,
        child: Scaffold(
          extendBodyBehindAppBar: true,
          appBar: TabBar(
            controller: _tabController,
            overlayColor: MaterialStateProperty.all(Colors.transparent),
            indicatorSize: TabBarIndicatorSize.label,
            indicatorWeight: 1,
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
              ),
              Divider(
                color: Get.theme.colorScheme.surface,
                thickness: 1,
                height: 1,
              ),
              Expanded(
                child: ColoredBox(
                  color: Get.theme.colorScheme.background,
                  child: TabBarView(
                    controller: _tabController,
                    children: const [
                      TasksTab(),
                      ColoredBox(color: Colors.yellow),
                      ColoredBox(color: Colors.blue)
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
