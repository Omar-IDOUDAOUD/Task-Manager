import 'package:flutter/material.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: TaskCard(isLive: false),
      ),
    );
  }
}
