import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/planner_task.dart';

class TaskCardActionMenu extends StatelessWidget {
  const TaskCardActionMenu({
    super.key,
    required this.task,
    required this.onEdit,
    required this.onDelete,
    this.onAttachToGoal,
    this.onDetachFromGoal,
    this.onMoveToMilestone,
    this.onMoveToDirectGoal,
    this.onScheduleDate,
    this.onScheduleTime,
    this.onClearScheduledTime,
    this.onRemoveFromToday,
    this.onUnschedule,
    this.onEditReminder,
  });

  final PlannerTask task;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAttachToGoal;
  final VoidCallback? onDetachFromGoal;
  final VoidCallback? onMoveToMilestone;
  final VoidCallback? onMoveToDirectGoal;
  final VoidCallback? onScheduleDate;
  final VoidCallback? onScheduleTime;
  final VoidCallback? onClearScheduledTime;
  final VoidCallback? onRemoveFromToday;
  final VoidCallback? onUnschedule;
  final VoidCallback? onEditReminder;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final shouldShowScheduleDate = onScheduleDate != null;
    final shouldShowRemoveFromToday = onRemoveFromToday != null;
    final shouldShowUnschedule = onUnschedule != null;
    final shouldShowScheduleTime =
        onScheduleTime != null && task.scheduledDate != null;
    final shouldShowClearScheduledTime =
        onClearScheduledTime != null && task.scheduledTimeMinutes != null;
    final shouldShowAttachToGoal = onAttachToGoal != null;
    final shouldShowDetachFromGoal = onDetachFromGoal != null;
    final shouldShowMoveToMilestone = onMoveToMilestone != null;
    final shouldShowMoveToDirectGoal = onMoveToDirectGoal != null;
    final shouldShowEditReminder =
        onEditReminder != null && task.scheduledTimeMinutes != null;

    return PopupMenuButton<_TaskCardAction>(
      onSelected: (action) {
        switch (action) {
          case _TaskCardAction.edit:
            onEdit();
          case _TaskCardAction.attachToGoal:
            onAttachToGoal?.call();
          case _TaskCardAction.detachFromGoal:
            onDetachFromGoal?.call();
          case _TaskCardAction.moveToMilestone:
            onMoveToMilestone?.call();
          case _TaskCardAction.moveToDirectGoal:
            onMoveToDirectGoal?.call();
          case _TaskCardAction.removeFromToday:
            onRemoveFromToday?.call();
          case _TaskCardAction.unschedule:
            onUnschedule?.call();
          case _TaskCardAction.scheduleDate:
            onScheduleDate?.call();
          case _TaskCardAction.scheduleTime:
            onScheduleTime?.call();
          case _TaskCardAction.clearScheduledTime:
            onClearScheduledTime?.call();
          case _TaskCardAction.delete:
            onDelete();
          case _TaskCardAction.editReminder:
            onEditReminder?.call();
        }
      },
      itemBuilder: (context) {
        return [
          PopupMenuItem(
            value: _TaskCardAction.edit,
            child: Text(l10n.commonEdit),
          ),
          if (shouldShowRemoveFromToday)
            PopupMenuItem(
              value: _TaskCardAction.removeFromToday,
              child: Text(l10n.taskActionRemoveFromToday),
            ),
          if (shouldShowAttachToGoal)
            PopupMenuItem(
              value: _TaskCardAction.attachToGoal,
              child: Text(l10n.taskActionAttachToGoal),
            ),
          if (shouldShowDetachFromGoal)
            PopupMenuItem(
              value: _TaskCardAction.detachFromGoal,
              child: Text(l10n.taskActionDetachFromGoal),
            ),
          if (shouldShowMoveToMilestone)
            PopupMenuItem(
              value: _TaskCardAction.moveToMilestone,
              child: Text(l10n.taskActionMoveToMilestone),
            ),
          if (shouldShowMoveToDirectGoal)
            PopupMenuItem(
              value: _TaskCardAction.moveToDirectGoal,
              child: Text(l10n.taskActionMoveToDirectGoal),
            ),
          PopupMenuItem(
            value: _TaskCardAction.delete,
            child: Text(l10n.commonDelete),
          ),
          if (shouldShowScheduleDate)
            PopupMenuItem(
              value: _TaskCardAction.scheduleDate,
              child: Text(l10n.taskActionScheduleDate),
            ),
          if (shouldShowScheduleTime)
            PopupMenuItem(
              value: _TaskCardAction.scheduleTime,
              child: Text(
                task.scheduledTimeMinutes == null
                    ? l10n.taskActionSetTime
                    : l10n.taskActionChangeTime,
              ),
            ),
          if (shouldShowClearScheduledTime)
            PopupMenuItem(
              value: _TaskCardAction.clearScheduledTime,
              child: Text(l10n.taskActionClearTime),
            ),
          if (shouldShowUnschedule)
            PopupMenuItem(
              value: _TaskCardAction.unschedule,
              child: Text(l10n.taskActionRemoveScheduledDate),
            ),
          if (shouldShowEditReminder)
            PopupMenuItem(
              value: _TaskCardAction.editReminder,
              child: Text(l10n.taskReminderFieldLabel),
            ),
        ];
      },
    );
  }
}

enum _TaskCardAction {
  edit,
  scheduleDate,
  scheduleTime,
  clearScheduledTime,
  removeFromToday,
  unschedule,
  attachToGoal,
  detachFromGoal,
  moveToMilestone,
  moveToDirectGoal,
  delete,
  editReminder,
}
