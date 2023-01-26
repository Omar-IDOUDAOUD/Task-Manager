import 'package:flutter/material.dart';
import 'package:task_manager/data/model/task.dart';
import 'package:task_manager/view/home/widgets/task_card.dart';

class CompletedTab extends StatelessWidget {
  const CompletedTab({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(25),
      child: SingleChildScrollView(
        child: TaskCard(
          data: TaskModel(
            creationDate: DateTime.now(),
            title: 'completed task',
            categoryId: 1,
          ),
        ),
      ),
    );
  }
}
