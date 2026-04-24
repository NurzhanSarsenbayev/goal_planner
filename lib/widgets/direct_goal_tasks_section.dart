import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import 'section_header.dart';
import 'task_card.dart';

class DirectGoalTasksSection extends StatelessWidget {
  const DirectGoalTasksSection({
    super.key,
    required this.goal,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTaskCompleted,
    required this.onScheduleTaskForToday,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
  final VoidCallback onAddTask;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(String taskId) onScheduleTaskForToday;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Direct tasks',
          actionLabel: 'Add task',
          onActionPressed: onAddTask,
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Text(
            'No direct tasks.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(
                task: task,
                goal: goal,
                onToggleCompleted: () => onToggleTaskCompleted(task.id),
                onScheduleForToday: () => onScheduleTaskForToday(task.id),
              ),
            ),
          ),
      ],
    );
  }
}