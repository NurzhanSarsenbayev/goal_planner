import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

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
  static const _confirmationPhrase = 'DELETE';

  final _confirmationController = TextEditingController();

  bool get _canDelete {
    return _confirmationController.text.trim() == _confirmationPhrase;
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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.goalDeleteDialogTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.goalDeleteDialogMessage(widget.goalTitle)),
          const SizedBox(height: 12),
          Text(l10n.goalDeleteDialogMilestonesCount(widget.milestoneCount)),
          Text(l10n.goalDeleteDialogTasksCount(widget.taskCount)),
          const SizedBox(height: 16),
          Text(l10n.goalDeleteDialogTypeDeleteToConfirm),
          const SizedBox(height: 8),
          TextField(
            controller: _confirmationController,
            autofocus: true,
            decoration: InputDecoration(
              labelText: l10n.goalDeleteDialogConfirmationLabel,
              hintText: _confirmationPhrase,
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
          child: Text(l10n.commonCancel),
        ),
        FilledButton(
          onPressed: _canDelete ? _confirmDelete : null,
          child: Text(l10n.goalDeleteDialogDeleteButton),
        ),
      ],
    );
  }
}
