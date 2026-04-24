import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;

  @override
  Widget build(BuildContext context) {
    final todayTasks = tasks
        .where((task) => task.isScheduledForToday)
        .toList();

    if (todayTasks.isEmpty) {
      return const PlaceholderScreen(
        title: 'Today',
        description: 'No tasks scheduled for today yet.',
        icon: Icons.today,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: todayTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = todayTasks[index];
        final goal = _findGoalById(task.goalId);

        return TaskCard(
          task: task,
          goal: goal,
          onToggleCompleted: () => onToggleTaskCompleted(task.id),
        );
      },
    );
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}