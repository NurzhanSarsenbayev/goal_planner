import 'package:flutter/material.dart';

import '../app/app_dialogs.dart';
import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onScheduleTaskForDate,
    required this.onRemoveTaskFromSchedule,
    required this.onDeleteTask,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function(String taskId) onRemoveTaskFromSchedule;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final scheduledGroups = _buildScheduledTaskGroups(tasks);

    if (scheduledGroups.isEmpty) {
      return const PlaceholderScreen(
        title: 'Calendar',
        description: 'No scheduled tasks yet.',
        icon: Icons.calendar_month,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      itemCount: scheduledGroups.length,
      itemBuilder: (context, groupIndex) {
        final group = scheduledGroups[groupIndex];

        return Padding(
          padding: const EdgeInsets.only(bottom: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _dateGroupTitle(group.date),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final task in group.tasks) ...[
                TaskCard(
                  task: task,
                  goal: _findGoalById(task.goalId),
                  onToggleCompleted: () => onToggleTaskCompleted(task.id),
                  onEdit: () => onEditTask(task),
                  onScheduleDate: () {
                    _showScheduleTaskDatePicker(context, task);
                  },
                  onUnschedule: () => onRemoveTaskFromSchedule(task.id),
                  onDelete: () => onDeleteTask(task.id),
                ),
                const SizedBox(height: 8),
              ],
            ],
          ),
        );
      },
    );
  }

  Future<void> _showScheduleTaskDatePicker(
    BuildContext context,
    PlannerTask task,
  ) async {
    final selectedDate = await showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    onScheduleTaskForDate(taskId: task.id, scheduledDate: selectedDate);
  }

  List<_ScheduledTaskGroup> _buildScheduledTaskGroups(
    List<PlannerTask> sourceTasks,
  ) {
    final scheduledTasks =
        sourceTasks.where((task) => task.scheduledDate != null).toList()
          ..sort((first, second) {
            final firstDate = first.scheduledDate!;
            final secondDate = second.scheduledDate!;

            final dateComparison = firstDate.compareTo(secondDate);

            if (dateComparison != 0) {
              return dateComparison;
            }

            return first.title.compareTo(second.title);
          });

    final groups = <_ScheduledTaskGroup>[];

    for (final task in scheduledTasks) {
      final scheduledDate = task.scheduledDate!;
      final dateOnly = DateTime(
        scheduledDate.year,
        scheduledDate.month,
        scheduledDate.day,
      );

      if (groups.isEmpty || groups.last.date != dateOnly) {
        groups.add(_ScheduledTaskGroup(date: dateOnly, tasks: [task]));
      } else {
        groups.last.tasks.add(task);
      }
    }

    return groups;
  }

  String _dateGroupTitle(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    }

    if (date == tomorrow) {
      return 'Tomorrow';
    }

    if (date == yesterday) {
      return 'Yesterday';
    }

    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}

class _ScheduledTaskGroup {
  _ScheduledTaskGroup({required this.date, required this.tasks});

  final DateTime date;
  final List<PlannerTask> tasks;
}
