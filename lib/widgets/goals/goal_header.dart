import 'package:flutter/material.dart';

import '../../models/goal.dart';

class GoalHeader extends StatelessWidget {
  const GoalHeader({
    super.key,
    required this.goal,
    required this.totalTasks,
    required this.completedTasks,
  });

  final Goal goal;
  final int totalTasks;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    final progressText = totalTasks == 0
        ? 'No tasks yet'
        : '$completedTasks / $totalTasks tasks completed';

    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (goal.description.isNotEmpty)
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progressValue),
            const SizedBox(height: 8),
            Text(progressText, style: Theme.of(context).textTheme.bodySmall),
          ],
        ),
      ),
    );
  }
}
