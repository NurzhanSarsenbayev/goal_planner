import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/goal.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayTasks = sampleTasks
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
        );
      },
    );
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in sampleGoals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}