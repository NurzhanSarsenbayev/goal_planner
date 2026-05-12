import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';

enum DeleteMilestoneAction { moveTasksToDirect, deleteTasks }

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
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.milestoneDeleteDialogTitle),
      content: Text(
        taskCount == 0
            ? l10n.milestoneDeleteDialogEmptyMessage(milestoneTitle)
            : l10n.milestoneDeleteDialogWithTasksMessage(
                taskCount,
                milestoneTitle,
              ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonCancel),
        ),
        if (taskCount > 0)
          TextButton(
            onPressed: () {
              Navigator.of(
                context,
              ).pop(DeleteMilestoneAction.moveTasksToDirect);
            },
            child: Text(l10n.milestoneDeleteDialogMoveTasksToDirectButton),
          ),
        FilledButton(
          onPressed: () {
            Navigator.of(context).pop(DeleteMilestoneAction.deleteTasks);
          },
          child: Text(
            taskCount == 0
                ? l10n.commonDelete
                : l10n.milestoneDeleteDialogDeleteWithTasksButton,
          ),
        ),
      ],
    );
  }
}
