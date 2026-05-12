import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/milestone.dart';

class MoveTaskToMilestoneDialog extends StatelessWidget {
  const MoveTaskToMilestoneDialog({super.key, required this.milestones});

  final List<Milestone> milestones;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return AlertDialog(
      title: Text(l10n.moveTaskToMilestoneDialogTitle),
      content: milestones.isEmpty
          ? Text(l10n.moveTaskToMilestoneDialogEmptyMessage)
          : Column(
              mainAxisSize: MainAxisSize.min,
              children: milestones.map((milestone) {
                return ListTile(
                  title: Text(milestone.title),
                  subtitle: milestone.description.isEmpty
                      ? null
                      : Text(milestone.description),
                  onTap: () {
                    Navigator.of(context).pop(milestone);
                  },
                );
              }).toList(),
            ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text(l10n.commonCancel),
        ),
      ],
    );
  }
}
