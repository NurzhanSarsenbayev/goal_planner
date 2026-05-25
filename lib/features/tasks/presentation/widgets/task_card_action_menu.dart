import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/planner_task.dart';
import 'task_edit_actions_sheet.dart';

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
    this.onEditRecurringSeries,
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
  final VoidCallback? onEditRecurringSeries;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return IconButton(
      tooltip: l10n.commonEdit,
      icon: const Icon(Icons.more_vert),
      onPressed: () {
        showTaskEditActionsSheet(
          context,
          task: task,
          onEdit: onEdit,
          onDelete: onDelete,
          onAttachToGoal: onAttachToGoal,
          onDetachFromGoal: onDetachFromGoal,
          onMoveToMilestone: onMoveToMilestone,
          onMoveToDirectGoal: onMoveToDirectGoal,
          onScheduleDate: onScheduleDate,
          onScheduleTime: onScheduleTime,
          onClearScheduledTime: onClearScheduledTime,
          onRemoveFromToday: onRemoveFromToday,
          onUnschedule: onUnschedule,
          onEditReminder: onEditReminder,
          onEditRecurringSeries: onEditRecurringSeries,
        );
      },
    );
  }
}
