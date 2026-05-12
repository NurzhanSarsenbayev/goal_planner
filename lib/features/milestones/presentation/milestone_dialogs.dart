import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/milestone.dart';
import 'widgets/delete_milestone_dialog.dart';
import 'widgets/milestone_dialog.dart';
import 'widgets/move_task_to_milestone_dialog.dart';

export 'widgets/delete_milestone_dialog.dart' show DeleteMilestoneAction;

Future<MilestoneDraft?> showAddMilestoneDialog(BuildContext context) {
  return showDialog<MilestoneDraft>(
    context: context,
    builder: (context) {
      return const MilestoneDialog();
    },
  );
}

Future<MilestoneDraft?> showEditMilestoneDialog(
  BuildContext context, {
  required Milestone milestone,
}) {
  return showDialog<MilestoneDraft>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return MilestoneDialog(
        initialTitle: milestone.title,
        initialDescription: milestone.description,
        title: l10n.milestoneDialogEditTitle,
        submitLabel: l10n.commonSave,
      );
    },
  );
}

Future<DeleteMilestoneAction?> showDeleteMilestoneDialog(
  BuildContext context, {
  required Milestone milestone,
  required int taskCount,
}) {
  return showDialog<DeleteMilestoneAction>(
    context: context,
    builder: (context) {
      return DeleteMilestoneDialog(
        milestoneTitle: milestone.title,
        taskCount: taskCount,
      );
    },
  );
}

Future<Milestone?> showMoveTaskToMilestoneDialog(
  BuildContext context, {
  required List<Milestone> milestones,
}) {
  return showDialog<Milestone>(
    context: context,
    builder: (context) {
      return MoveTaskToMilestoneDialog(milestones: milestones);
    },
  );
}
