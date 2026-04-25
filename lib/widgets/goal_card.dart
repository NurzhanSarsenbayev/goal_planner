import 'package:flutter/material.dart';

import '../models/goal.dart';

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.totalTasks,
    required this.completedTasks,
    required this.onTap,
    required this.onEdit,
    required this.onDelete,
  });

  final Goal goal;
  final int totalTasks;
  final int completedTasks;
  final VoidCallback onTap;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final progressText = totalTasks == 0
        ? 'No tasks yet'
        : '$completedTasks / $totalTasks tasks completed';

    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Card(
      child: ListTile(
        onTap: onTap,
        leading: const Icon(Icons.flag_outlined),
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.description.isNotEmpty) Text(goal.description),
            const SizedBox(height: 8),
            LinearProgressIndicator(value: progressValue),
            const SizedBox(height: 4),
            Text(
              progressText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<_GoalAction>(
          onSelected: (action) {
            switch (action) {
              case _GoalAction.edit:
                onEdit();
              case _GoalAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: _GoalAction.edit,
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: _GoalAction.delete,
                child: Text('Delete'),
              ),
            ];
          },
        ),
      ),
    );
  }
}

enum _GoalAction {
  edit,
  delete,
}