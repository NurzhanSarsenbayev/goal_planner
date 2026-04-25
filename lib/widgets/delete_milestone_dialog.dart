import 'package:flutter/material.dart';

enum DeleteMilestoneAction {
  moveTasksToDirect,
  deleteTasks,
}

class DeleteMilestoneDialog extends StatelessWidget {
  const DeleteMilestoneDialog({
    super.key,
    required this.milestoneTitle,
    required this.taskCount,
  });

  final String milestoneTitle;
  final int taskCount;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete milestone?'),
      content: Text(
        taskCount == 0
            ? 'Delete "$milestoneTitle"?'
            : 'What should happen to $taskCount task(s) inside "$milestoneTitle"?',
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        if (taskCount > 0)
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(
                DeleteMilestoneAction.moveTasksToDirect,
              );
            },
            child: const Text('Move tasks to Direct tasks'),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(
              DeleteMilestoneAction.deleteTasks,
            );
          },
          child: Text(
            taskCount == 0 ? 'Delete' : 'Delete milestone and tasks',
          ),
        ),
      ],
    );
  }
}