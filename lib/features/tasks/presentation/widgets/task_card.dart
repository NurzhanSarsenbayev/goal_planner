import 'package:flutter/material.dart';

import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import 'task_card_action_menu.dart';
import 'task_card_subtitle.dart';

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
    this.onScheduleTime,
    this.onClearScheduledTime,
    this.onRemoveFromToday,
    this.onUnschedule,
    this.onEditReminder,
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
  final VoidCallback? onScheduleTime;
  final VoidCallback? onClearScheduledTime;
  final VoidCallback? onRemoveFromToday;
  final VoidCallback? onUnschedule;
  final VoidCallback? onEditReminder;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        onTap: onToggleCompleted,
        leading: Icon(
          task.isCompleted ? Icons.check_circle : Icons.radio_button_unchecked,
        ),
        title: Text(task.title, style: _titleStyle(context)),
        subtitle: TaskCardSubtitle(
          task: task,
          goal: goal,
          onScheduleForToday: onScheduleForToday,
        ),
        trailing: TaskCardActionMenu(
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
}
