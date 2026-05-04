import 'package:flutter/material.dart';

import '../task_dialogs.dart' as task_dialogs;
import '../../../tasks/presentation/task_date_dialogs.dart';
import '../../../../models/goal.dart';
import '../../../../models/milestone.dart';
import '../../../../models/planner_task.dart';
import '../../../../models/recurring_task_rule.dart';
import '../../../../shared/presentation/widgets/placeholder_screen.dart';
import '../../../recurring/presentation/widgets/recurring_task_rule_card.dart';
import '../widgets/task_card.dart';
import '../../application/all_tasks_view_builder.dart';

class AllTasksScreen extends StatelessWidget {
  const AllTasksScreen({
    super.key,
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.onToggleTaskCompleted,
    required this.onTaskUpdated,
    required this.onTaskAttachedToGoal,
    required this.onTaskDetachedFromGoal,
    required this.onDeleteTask,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onCompleteTaskOnDate,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;
  final AllTasksViewBuilder _viewBuilder = const AllTasksViewBuilder();

  final void Function({
    required String taskId,
    required String title,
    required String description,
  })
  onTaskUpdated;

  final void Function({
    required String taskId,
    required String goalId,
    String? milestoneId,
  })
  onTaskAttachedToGoal;

  final void Function(String taskId) onTaskDetachedFromGoal;
  final void Function(String taskId) onDeleteTask;

  Future<void> _showEditTaskDialog(
    BuildContext context,
    PlannerTask task,
  ) async {
    final result = await task_dialogs.showEditTaskDialog(context, task: task);

    if (result == null) {
      return;
    }

    onTaskUpdated(
      taskId: task.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showAttachTaskToGoalDialog(
    BuildContext context,
    PlannerTask task,
  ) async {
    final result = await task_dialogs.showTaskPlacementDialog(
      context,
      goals: goals,
      milestones: milestones,
    );

    if (result == null) {
      return;
    }

    onTaskAttachedToGoal(
      taskId: task.id,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
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

  @override
  Widget build(BuildContext context) {
    final view = _viewBuilder.build(
      goals: goals,
      tasks: tasks,
      recurringRules: recurringRules,
    );

    if (view.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('All tasks')),
        body: const PlaceholderScreen(
          title: 'All tasks',
          description: 'No tasks created yet.',
          icon: Icons.task_alt,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All tasks')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (view.hasVisibleTasks) ...[
            Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final task in view.visibleTasks) ...[
              _buildTaskCard(context, view, task),
              const SizedBox(height: 8),
            ],
          ],
          if (view.hasRecurringRules) ...[
            if (view.hasVisibleTasks) const SizedBox(height: 24),
            Text(
              'Recurring rules',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final rule in view.recurringRules) ...[
              RecurringTaskRuleCard(rule: rule),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  Widget _buildTaskCard(
    BuildContext context,
    AllTasksView view,
    PlannerTask task,
  ) {
    final goal = view.findGoalById(task.goalId);
    final isStandaloneTask = task.goalId == null;
    final isGoalLinkedTask = task.goalId != null;

    return TaskCard(
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
      onEdit: () {
        _showEditTaskDialog(context, task);
      },
      onAttachToGoal: isStandaloneTask
          ? () {
              _showAttachTaskToGoalDialog(context, task);
            }
          : null,
      onDetachFromGoal: isGoalLinkedTask
          ? () {
              onTaskDetachedFromGoal(task.id);
            }
          : null,
      onScheduleForToday: task.isScheduledForToday
          ? null
          : () {
              onScheduleTaskForToday(task.id);
            },
      onScheduleDate: () {
        _showScheduleTaskDatePicker(context, task);
      },
      onDelete: () {
        onDeleteTask(task.id);
      },
    );
  }
}
