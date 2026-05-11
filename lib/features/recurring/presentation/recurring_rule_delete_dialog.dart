import 'package:flutter/material.dart';

import '../../../models/recurring_task_rule.dart';

Future<bool> showDeleteRecurringTaskRuleDialog(
  BuildContext context, {
  required RecurringTaskRule rule,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Delete recurring rule?'),
        content: Text(
          'This will remove all unfinished generated tasks from '
          '"${rule.title}". Completed tasks will stay in your history.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Delete'),
          ),
        ],
      );
    },
  );

  return shouldDelete == true;
}
