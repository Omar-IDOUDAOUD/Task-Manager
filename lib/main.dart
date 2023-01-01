import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:task_manager/core/constants/colors.dart';
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
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        appBarTheme: AppBarTheme(),
        indicatorColor: Colors.black,
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: CstColors.la,
          labelColor: Colors.black,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            fontFamily: "Poppins",
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
            fontFamily: "Poppins",
          ),
        ),
        colorScheme: ColorScheme.light(
          brightness: Brightness.light,
          background: CstColors.le,
          primary: Colors.black,
          secondary:  CstColors.lc,
          tertiary: CstColors.ld,
          surface: CstColors.lb,
        ),
        textTheme: const TextTheme(
          // headlines
          headline1: TextStyle(
            fontFamily: "Poppins",
            fontSize: 8,
          ),
          headline2: TextStyle(
            fontFamily: "Poppins",
            fontSize: 10,
          ),
          headline3: TextStyle(
            fontFamily: "Poppins",
            fontSize: 12,
          ),
          headline4: TextStyle(
            fontFamily: "Poppins",
            fontSize: 13,
          ),
       
        ),
      ),
      home: const Home(),
    );
  }
}
