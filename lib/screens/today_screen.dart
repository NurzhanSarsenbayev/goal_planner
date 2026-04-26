import 'package:flutter/material.dart';

import '../app/app_dialogs.dart';
import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onAttachTaskToGoal,
    required this.onDetachTaskFromGoal,
    required this.onDeleteTask,
    required this.onAddTask,
    required this.onRemoveTaskFromToday,
    required this.onScheduleTaskForDate,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onRemoveTaskFromToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function(PlannerTask task) onAttachTaskToGoal;
  final void Function(String taskId) onDetachTaskFromGoal;
  final void Function(String taskId) onDeleteTask;
  final VoidCallback onAddTask;

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

  @override
  Widget build(BuildContext context) {
    final todayTasks = tasks.where((task) => task.isScheduledForToday).toList();

    return Stack(
      children: [
        if (todayTasks.isEmpty)
          const PlaceholderScreen(
            title: 'Today',
            description: 'No tasks scheduled for today yet.',
            icon: Icons.today,
          )
        else
          ListView.separated(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            itemCount: todayTasks.length,
            separatorBuilder: (_, _) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final task = todayTasks[index];
              final goal = _findGoalById(task.goalId);
              final isStandaloneTask = task.goalId == null;
              final isGoalLinkedTask = task.goalId != null;

              return TaskCard(
                task: task,
                goal: goal,
                onToggleCompleted: () => onToggleTaskCompleted(task.id),
                onEdit: () => onEditTask(task),
                onAttachToGoal: isStandaloneTask
                    ? () => onAttachTaskToGoal(task)
                    : null,
                onDetachFromGoal: isGoalLinkedTask
                    ? () => onDetachTaskFromGoal(task.id)
                    : null,
                onRemoveFromToday: () => onRemoveTaskFromToday(task.id),
                onScheduleDate: () {
                  _showScheduleTaskDatePicker(context, task);
                },
                onDelete: () => onDeleteTask(task.id),
              );
            },
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: onAddTask,
            icon: const Icon(Icons.add),
            label: const Text('Add task'),
          ),
        ),
      ],
    );
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
