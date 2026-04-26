import 'package:flutter/material.dart';

class DeleteGoalDialog extends StatefulWidget {
  const DeleteGoalDialog({
    super.key,
    required this.goalTitle,
    required this.milestoneCount,
    required this.taskCount,
  });

  final String goalTitle;
  final int milestoneCount;
  final int taskCount;

  @override
  State<DeleteGoalDialog> createState() => _DeleteGoalDialogState();
}

class _DeleteGoalDialogState extends State<DeleteGoalDialog> {
  final _confirmationController = TextEditingController();

  bool get _canDelete {
    return _confirmationController.text.trim() == 'DELETE';
  }

  @override
  void dispose() {
    _confirmationController.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    if (!_canDelete) {
      return;
    }

    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Delete goal?'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('This will permanently delete "${widget.goalTitle}".'),
          const SizedBox(height: 12),
          Text('Milestones: ${widget.milestoneCount}'),
          Text('Tasks: ${widget.taskCount}'),
          const SizedBox(height: 16),
          const Text('Type DELETE to confirm.'),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Confirmation',
              hintText: 'DELETE',
            ),
            onChanged: (_) {
              setState(() {});
            },
            onSubmitted: (_) {
              _confirmDelete();
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(false);
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _canDelete ? _confirmDelete : null,
          child: const Text('Delete goal'),
        ),
      ],
    );
  }
}
