import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../models/planner_task.dart';
import '../tasks/task_card.dart';

class GoalReportSection extends StatelessWidget {
  const GoalReportSection({
    super.key,
    required this.goal,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(goal.title, style: Theme.of(context).textTheme.titleSmall),
        const SizedBox(height: 8),
        for (final task in tasks) ...[
          TaskCard(
            task: task,
            goal: goal,
            onToggleCompleted: () {
              onToggleTaskCompleted(task.id);
            },
            onEdit: () {
              onEditTask(task);
            },
            onDelete: () {
              onDeleteTask(task.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
