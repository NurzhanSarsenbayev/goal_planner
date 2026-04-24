import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
    required this.onToggleCompleted,
    this.onScheduleForToday,
  });

  final PlannerTask task;
  final Goal? goal;
  final VoidCallback onToggleCompleted;
  final VoidCallback? onScheduleForToday;

  @override
  Widget build(BuildContext context) {
    final shouldShowScheduleButton =
        onScheduleForToday != null && !task.isScheduledForToday;

    return Card(
      child: ListTile(
        onTap: onToggleCompleted,
        leading: Icon(
          task.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
        ),
        title: Text(
          task.title,
          style: task.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
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
            if (task.isScheduledForToday)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Planned for today',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (shouldShowScheduleButton)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onScheduleForToday,
                    icon: const Icon(Icons.today),
                    label: const Text('Plan today'),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}