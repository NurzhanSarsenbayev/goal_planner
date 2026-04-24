import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
  });

  final PlannerTask task;
  final Goal? goal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          task.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            if (goal != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Goal: ${goal!.title}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}