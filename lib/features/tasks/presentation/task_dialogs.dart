import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import 'widgets/add_task_with_placement_dialog.dart';
import 'widgets/task_dialog.dart';
import 'widgets/task_placement_dialog.dart';

Future<TaskDraft?> showAddTaskDialog(BuildContext context) {
  return showDialog<TaskDraft>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return TaskDialog(
        title: l10n.taskDialogAddTitle,
        submitLabel: l10n.commonAdd,
      );
    },
  );
}

Future<TaskDraft?> showEditTaskDialog(
  BuildContext context, {
  required PlannerTask task,
}) {
  return showDialog<TaskDraft>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return TaskDialog(
        initialTitle: task.title,
        initialDescription: task.description,
        title: l10n.taskDialogEditTitle,
        submitLabel: l10n.commonSave,
      );
    },
  );
}

Future<AddTaskWithPlacementDraft?> showAddTaskWithPlacementDialog(
  BuildContext context, {
  required List<Goal> goals,
  required List<Milestone> milestones,
}) {
  return showDialog<AddTaskWithPlacementDraft>(
    context: context,
    builder: (context) {
      return AddTaskWithPlacementDialog(goals: goals, milestones: milestones);
    },
  );
}

Future<TaskPlacementDraft?> showTaskPlacementDialog(
  BuildContext context, {
  required List<Goal> goals,
  required List<Milestone> milestones,
}) {
  return showDialog<TaskPlacementDraft>(
    context: context,
    builder: (context) {
      return TaskPlacementDialog(goals: goals, milestones: milestones);
    },
  );
}
