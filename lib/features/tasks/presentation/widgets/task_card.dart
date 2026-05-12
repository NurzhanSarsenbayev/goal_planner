import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../../shared/planner_dates.dart';

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
    required this.onToggleCompleted,
    required this.onEdit,
    required this.onDelete,
    this.onAttachToGoal,
    this.onDetachFromGoal,
    this.onMoveToMilestone,
    this.onMoveToDirectGoal,
    this.onScheduleForToday,
    this.onScheduleDate,
    this.onRemoveFromToday,
    this.onUnschedule,
  });

  final PlannerTask task;
  final Goal? goal;
  final VoidCallback onToggleCompleted;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onAttachToGoal;
  final VoidCallback? onDetachFromGoal;
  final VoidCallback? onMoveToMilestone;
  final VoidCallback? onMoveToDirectGoal;
  final VoidCallback? onScheduleForToday;
  final VoidCallback? onScheduleDate;
  final VoidCallback? onRemoveFromToday;
  final VoidCallback? onUnschedule;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final shouldShowScheduleButton =
        onScheduleForToday != null && !task.isScheduledForToday;
    final shouldShowScheduleDate = onScheduleDate != null;
    final shouldShowRemoveFromToday = onRemoveFromToday != null;
    final shouldShowUnschedule = onUnschedule != null;

    final shouldShowAttachToGoal = onAttachToGoal != null;
    final shouldShowDetachFromGoal = onDetachFromGoal != null;
    final shouldShowMoveToMilestone = onMoveToMilestone != null;
    final shouldShowMoveToDirectGoal = onMoveToDirectGoal != null;

    return Card(
      child: ListTile(
        onTap: onToggleCompleted,
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        ),
        title: Text(task.title, style: _titleStyle(context)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            if (goal != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  l10n.taskCardGoalLabel(goal!.title),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (task.scheduledDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _scheduledDateLabel(l10n, task.scheduledDate!),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (shouldShowScheduleButton)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: TextButton.icon(
                    onPressed: onScheduleForToday,
                    icon: const Icon(Icons.today),
                    label: Text(l10n.taskCardPlanTodayButton),
                  ),
                ),
              ),
          ],
        ),
        trailing: PopupMenuButton<_TaskAction>(
          onSelected: (action) {
            switch (action) {
              case _TaskAction.edit:
                onEdit();
              case _TaskAction.attachToGoal:
                onAttachToGoal?.call();
              case _TaskAction.detachFromGoal:
                onDetachFromGoal?.call();
              case _TaskAction.moveToMilestone:
                onMoveToMilestone?.call();
              case _TaskAction.moveToDirectGoal:
                onMoveToDirectGoal?.call();
              case _TaskAction.removeFromToday:
                onRemoveFromToday?.call();
              case _TaskAction.unschedule:
                onUnschedule?.call();
              case _TaskAction.scheduleDate:
                onScheduleDate?.call();
              case _TaskAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: _TaskAction.edit,
                child: Text(l10n.commonEdit),
              ),
              if (shouldShowRemoveFromToday)
                PopupMenuItem(
                  value: _TaskAction.removeFromToday,
                  child: Text(l10n.taskActionRemoveFromToday),
                ),
              if (shouldShowAttachToGoal)
                PopupMenuItem(
                  value: _TaskAction.attachToGoal,
                  child: Text(l10n.taskActionAttachToGoal),
                ),
              if (shouldShowDetachFromGoal)
                PopupMenuItem(
                  value: _TaskAction.detachFromGoal,
                  child: Text(l10n.taskActionDetachFromGoal),
                ),
              if (shouldShowMoveToMilestone)
                PopupMenuItem(
                  value: _TaskAction.moveToMilestone,
                  child: Text(l10n.taskActionMoveToMilestone),
                ),
              if (shouldShowMoveToDirectGoal)
                PopupMenuItem(
                  value: _TaskAction.moveToDirectGoal,
                  child: Text(l10n.taskActionMoveToDirectGoal),
                ),
              PopupMenuItem(
                value: _TaskAction.delete,
                child: Text(l10n.commonDelete),
              ),
              if (shouldShowScheduleDate)
                PopupMenuItem(
                  value: _TaskAction.scheduleDate,
                  child: Text(l10n.taskActionScheduleDate),
                ),
              if (shouldShowUnschedule)
                PopupMenuItem(
                  value: _TaskAction.unschedule,
                  child: Text(l10n.taskActionRemoveScheduledDate),
                ),
            ];
          },
        ),
      ),
    );
  }

  TextStyle _titleStyle(BuildContext context) {
    final baseStyle =
        Theme.of(context).textTheme.titleMedium ?? const TextStyle();

    return baseStyle.copyWith(
      decoration: task.isCompleted
          ? TextDecoration.lineThrough
          : TextDecoration.none,
      decorationColor: Theme.of(context).colorScheme.onSurface,
      decorationThickness: 2,
    );
  }

  String _scheduledDateLabel(AppLocalizations l10n, DateTime date) {
    if (task.isScheduledForToday) {
      return l10n.taskCardScheduledToday;
    }

    return l10n.taskCardScheduledDate(formatPlannerDate(date));
  }
}

enum _TaskAction {
  edit,
  scheduleDate,
  removeFromToday,
  unschedule,
  attachToGoal,
  detachFromGoal,
  moveToMilestone,
  moveToDirectGoal,
  delete,
}
