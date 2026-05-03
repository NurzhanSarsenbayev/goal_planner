import 'package:flutter/material.dart';

import '../../../../app/app_dialogs.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../../widgets/common/placeholder_screen.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../application/today_task_view_builder.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onCompleteTaskOnDate,
    required this.onEditTask,
    required this.onAttachTaskToGoal,
    required this.onDetachTaskFromGoal,
    required this.onDeleteTask,
    required this.onAddTask,
    required this.onRemoveTaskFromToday,
    required this.onScheduleTaskForDate,
    required this.onAddRecurringTask,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onRemoveTaskFromToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function(PlannerTask task) onAttachTaskToGoal;
  final void Function(String taskId) onDetachTaskFromGoal;
  final void Function(String taskId) onDeleteTask;
  final VoidCallback onAddTask;
  final VoidCallback onAddRecurringTask;
  final TodayTaskViewBuilder _viewBuilder = const TodayTaskViewBuilder();

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

  Future<void> _showAddActionSheet(BuildContext context) async {
    final selectedAction = await showModalBottomSheet<_TodayAddAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('One-time task'),
                subtitle: const Text('Create a task for today'),
                onTap: () {
                  Navigator.of(context).pop(_TodayAddAction.oneTimeTask);
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Recurring task'),
                subtitle: const Text('Create a task that repeats'),
                onTap: () {
                  Navigator.of(context).pop(_TodayAddAction.recurringTask);
                },
              ),
            ],
          ),
        );
      },
    );

    switch (selectedAction) {
      case _TodayAddAction.oneTimeTask:
        onAddTask();
      case _TodayAddAction.recurringTask:
        onAddRecurringTask();
      case null:
        return;
    }
  }

  @override
  Widget build(BuildContext context) {
    final view = _viewBuilder.build(goals: goals, tasks: tasks);

    return Stack(
      children: [
        if (view.isEmpty)
          const PlaceholderScreen(
            title: 'Today',
            description: 'No tasks scheduled for today yet.',
            icon: Icons.today,
          )
        else
          ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              if (view.overdueTasks.isNotEmpty) ...[
                Text('Overdue', style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final task in view.overdueTasks) ...[
                  _buildTaskCard(context, view, task),
                  const SizedBox(height: 8),
                ],
                const SizedBox(height: 24),
              ],
              Text(
                'To do today',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (view.pendingTodayTasks.isEmpty)
                Text(
                  'No tasks left for today.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else
                for (final task in view.pendingTodayTasks) ...[
                  _buildTaskCard(context, view, task),
                  const SizedBox(height: 8),
                ],

              if (view.doneTodayTasks.isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  'Done today',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                for (final task in view.doneTodayTasks) ...[
                  _buildTaskCard(context, view, task),
                  const SizedBox(height: 8),
                ],
              ],
            ],
          ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              _showAddActionSheet(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Add task'),
          ),
        ),
      ],
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    TodayTaskView view,
    PlannerTask task,
  ) {
    final goal = view.findGoalById(task.goalId);
    final isStandaloneTask = task.goalId == null;
    final isGoalLinkedTask = task.goalId != null;

    return TaskCard(
      key: ValueKey(task.id),
      task: task,
      goal: goal,
      onToggleCompleted: () {
        handleTaskCompletionWithDateFlow(
          context,
          task: task,
          onToggleTaskCompleted: onToggleTaskCompleted,
          onCompleteTaskOnDate: onCompleteTaskOnDate,
        );
      },
      onEdit: () => onEditTask(task),
      onAttachToGoal: isStandaloneTask ? () => onAttachTaskToGoal(task) : null,
      onDetachFromGoal: isGoalLinkedTask
          ? () => onDetachTaskFromGoal(task.id)
          : null,
      onRemoveFromToday: task.isScheduledForToday
          ? () => onRemoveTaskFromToday(task.id)
          : null,
      onUnschedule: view.isOverdue(task)
          ? () => onRemoveTaskFromToday(task.id)
          : null,
      onScheduleDate: () {
        _showScheduleTaskDatePicker(context, task);
      },
      onDelete: () => onDeleteTask(task.id),
    );
  }
}

enum _TodayAddAction { oneTimeTask, recurringTask }
