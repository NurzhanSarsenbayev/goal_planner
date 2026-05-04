import 'package:flutter/material.dart';

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
      return MilestoneDialog(
        initialTitle: milestone.title,
        initialDescription: milestone.description,
        title: 'Edit milestone',
        submitLabel: 'Save',
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
