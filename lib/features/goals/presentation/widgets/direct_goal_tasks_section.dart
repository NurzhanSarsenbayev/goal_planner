import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../../tasks/presentation/task_schedule_dialog_actions.dart';
import '../../../../shared/presentation/widgets/section_header.dart';

class DirectGoalTasksSection extends StatelessWidget {
  const DirectGoalTasksSection({
    super.key,
    required this.goal,
    required this.tasks,
    required this.onAddTask,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onMoveTaskToMilestone,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onEditTaskReminder,
    required this.onDeleteTask,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
  final VoidCallback onAddTask;
  final void Function(PlannerTask task) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(PlannerTask task) onMoveTaskToMilestone;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function(PlannerTask task) onScheduleTaskForDate;
  final void Function(PlannerTask task) onEditTaskReminder;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.goalDetailsDirectTasksSection,
          actionLabel: l10n.taskDialogAddTitle,
          onActionPressed: onAddTask,
        ),
        const SizedBox(height: 8),
        if (tasks.isEmpty)
          Text(
            l10n.goalDetailsNoDirectTasks,
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...tasks.map(
            (task) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: TaskCard(
                task: task,
                goal: goal,
                onToggleCompleted: () => onToggleTaskCompleted(task),
                onEdit: () => onEditTask(task),
                onMoveToMilestone: () => onMoveTaskToMilestone(task),
                onScheduleForToday: () => onScheduleTaskForToday(task.id),
                onScheduleDate: () {
                  onScheduleTaskForDate(task);
                },
                onEditReminder: TaskScheduleDialogActions.canEditReminder(task)
                    ? () => onEditTaskReminder(task)
                    : null,
                onDelete: () => onDeleteTask(task.id),
              ),
            ),
          ),
      ],
    );
  }
}
