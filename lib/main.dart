import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:task_manager/binding/home_binding.dart';
import 'package:task_manager/core/constants/colors.dart';
import 'package:task_manager/view/home.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized(); 
  runApp(const TaskManger());
}

class TaskManger extends StatelessWidget {
  const TaskManger({Key? key}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      getPages: [
        GetPage(
          name: '/home',
          page: () => const Home(),
          binding: HomeBinding(), 
        ),
      ],
      initialRoute: '/home',
      theme: ThemeData(
        appBarTheme: const AppBarTheme(
          systemOverlayStyle: SystemUiOverlayStyle.light,
        ),
        indicatorColor: Colors.black,
        tabBarTheme: TabBarTheme(
          unselectedLabelColor: CstColors.la,
          labelColor: Colors.black,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 15,
            fontFamily: "Poppins",
          ),
          unselectedLabelStyle: const TextStyle(
            fontWeight: FontWeight.normal,
            fontSize: 15,
            fontFamily: "Poppins",
          ),
        ),
        scaffoldBackgroundColor: Colors.white,
        colorScheme: ColorScheme.light(
          brightness: Brightness.light,
          background: CstColors.le,
          primary: Colors.black,
          secondary: CstColors.lc,
          tertiary: CstColors.ld,
          surface: CstColors.lb,
        ),
        textTheme: const TextTheme(
          // headlines
          headline1: TextStyle(
              fontFamily: "Poppins", fontSize: 8, fontWeight: FontWeight.w500),
          headline2: TextStyle(
              fontFamily: "Poppins", fontSize: 10, fontWeight: FontWeight.w500),
          headline3: TextStyle(
              fontFamily: "Poppins", fontSize: 12, fontWeight: FontWeight.w500),
          headline4: TextStyle(
              fontFamily: "Poppins", fontSize: 13, fontWeight: FontWeight.w500),
          headline5: TextStyle(
              fontFamily: "Poppins", fontSize: 14, fontWeight: FontWeight.w500),
          headline6: TextStyle(
            fontFamily: "Poppins",
            fontSize: 25,
            fontWeight: FontWeight.w400,
            color: Colors.black,
          ),
        ),
      ),
    );
  }
}
