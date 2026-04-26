import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';

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

  @override
  Widget build(BuildContext context) {
    final shouldShowScheduleButton =
        onScheduleForToday != null && !task.isScheduledForToday;
    final shouldShowScheduleDate = onScheduleDate != null;
    final shouldShowRemoveFromToday = onRemoveFromToday != null;

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
        title: Text(
          task.title,
          style: task.isCompleted
              ? const TextStyle(decoration: TextDecoration.lineThrough)
              : null,
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            if (goal != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Goal: ${goal!.title}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            if (task.scheduledDate != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  _scheduledDateLabel(task.scheduledDate!),
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
                    label: const Text('Plan today'),
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
              case _TaskAction.scheduleDate:
                onScheduleDate?.call();
              case _TaskAction.delete:
                onDelete();
            }
          },
          itemBuilder: (context) {
            return [
              const PopupMenuItem(value: _TaskAction.edit, child: Text('Edit')),
              if (shouldShowRemoveFromToday)
                const PopupMenuItem(
                  value: _TaskAction.removeFromToday,
                  child: Text('Remove from Today'),
                ),
              if (shouldShowAttachToGoal)
                const PopupMenuItem(
                  value: _TaskAction.attachToGoal,
                  child: Text('Attach to goal'),
                ),
              if (shouldShowDetachFromGoal)
                const PopupMenuItem(
                  value: _TaskAction.detachFromGoal,
                  child: Text('Detach from goal'),
                ),
              if (shouldShowMoveToMilestone)
                const PopupMenuItem(
                  value: _TaskAction.moveToMilestone,
                  child: Text('Move to milestone'),
                ),
              if (shouldShowMoveToDirectGoal)
                const PopupMenuItem(
                  value: _TaskAction.moveToDirectGoal,
                  child: Text('Move to Direct tasks'),
                ),
              const PopupMenuItem(
                value: _TaskAction.delete,
                child: Text('Delete'),
              ),
              if (shouldShowScheduleDate)
                const PopupMenuItem(
                  value: _TaskAction.scheduleDate,
                  child: Text('Schedule date'),
                ),
            ];
          },
        ),
      ),
    );
  }

  String _scheduledDateLabel(DateTime date) {
    if (task.isScheduledForToday) {
      return 'Scheduled: Today';
    }

    return 'Scheduled: ${_formatDate(date)}';
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }
}

enum _TaskAction {
  edit,
  scheduleDate,
  removeFromToday,
  attachToGoal,
  detachFromGoal,
  moveToMilestone,
  moveToDirectGoal,
  delete,
}
