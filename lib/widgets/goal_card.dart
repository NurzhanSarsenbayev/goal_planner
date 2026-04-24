import 'package:flutter/material.dart';

import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
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

    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.description.isNotEmpty) Text(goal.description),
            const SizedBox(height: 4),
            Text(
              progressText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}