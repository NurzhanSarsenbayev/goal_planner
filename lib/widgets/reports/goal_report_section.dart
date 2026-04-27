import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../models/planner_task.dart';

class GoalReportSection extends StatelessWidget {
  const GoalReportSection({super.key, required this.goal, required this.tasks});

  final Goal goal;
  final List<PlannerTask> tasks;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(goal.title),
        subtitle: const Text('Completed tasks'),
        trailing: Text(
          tasks.length.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
