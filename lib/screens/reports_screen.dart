import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../shared/planner_dates.dart';
import '../widgets/common/placeholder_screen.dart';
import '../widgets/tasks/task_card.dart';

class ReportsScreen extends StatelessWidget {
  const ReportsScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final completedTodayTasks = _completedTasksForDate(todayDate());
    final goalLinkedTasks = completedTodayTasks
        .where((task) => task.goalId != null)
        .toList();
    final standaloneTasks = completedTodayTasks
        .where((task) => task.goalId == null)
        .toList();
    final groupedByGoal = _groupTasksByGoal(goalLinkedTasks);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Reports'),
      ),
      body: completedTodayTasks.isEmpty
          ? const PlaceholderScreen(
        title: 'Reports',
        description: 'No completed tasks for today yet.',
        icon: Icons.analytics,
      )
          : ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            'Today',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _ReportSummaryCard(
            completedCount: completedTodayTasks.length,
            goalLinkedCount: goalLinkedTasks.length,
            standaloneCount: standaloneTasks.length,
          ),
          const SizedBox(height: 24),
          Text(
            'By goal',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          if (groupedByGoal.isEmpty)
            Text(
              'No goal-linked tasks completed today.',
              style: Theme.of(context).textTheme.bodyMedium,
            )
          else
            for (final group in groupedByGoal) ...[
              _GoalReportSection(
                goal: group.goal,
                tasks: group.tasks,
                onToggleTaskCompleted: onToggleTaskCompleted,
                onEditTask: onEditTask,
                onDeleteTask: onDeleteTask,
              ),
              const SizedBox(height: 16),
            ],
          if (standaloneTasks.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Standalone',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            for (final task in standaloneTasks) ...[
              TaskCard(
                task: task,
                goal: null,
                onToggleCompleted: () {
                  onToggleTaskCompleted(task.id);
                },
                onEdit: () {
                  onEditTask(task);
                },
                onDelete: () {
                  onDeleteTask(task.id);
                },
              ),
              const SizedBox(height: 8),
            ],
          ],
        ],
      ),
    );
  }

  List<PlannerTask> _completedTasksForDate(DateTime date) {
    final selectedDate = dateOnly(date);

    final completedTasks = tasks.where((task) {
      final completedAt = task.completedAt;

      if (completedAt == null) {
        return false;
      }

      return dateOnly(completedAt) == selectedDate;
    }).toList()
      ..sort((first, second) {
        final firstCompletedAt = first.completedAt!;
        final secondCompletedAt = second.completedAt!;

        return secondCompletedAt.compareTo(firstCompletedAt);
      });

    return completedTasks;
  }

  List<_GoalTaskGroup> _groupTasksByGoal(List<PlannerTask> sourceTasks) {
    final groups = <_GoalTaskGroup>[];

    for (final goal in goals) {
      final goalTasks = sourceTasks
          .where((task) => task.goalId == goal.id)
          .toList();

      if (goalTasks.isEmpty) {
        continue;
      }

      groups.add(_GoalTaskGroup(goal: goal, tasks: goalTasks));
    }

    return groups;
  }
}

class _ReportSummaryCard extends StatelessWidget {
  const _ReportSummaryCard({
    required this.completedCount,
    required this.goalLinkedCount,
    required this.standaloneCount,
  });

  final int completedCount;
  final int goalLinkedCount;
  final int standaloneCount;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _SummaryRow(label: 'Completed tasks', value: completedCount),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Goal-linked', value: goalLinkedCount),
            const SizedBox(height: 8),
            _SummaryRow(label: 'Standalone', value: standaloneCount),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  const _SummaryRow({
    required this.label,
    required this.value,
  });

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(
          value.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ],
    );
  }
}

class _GoalReportSection extends StatelessWidget {
  const _GoalReportSection({
    required this.goal,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          goal.title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        const SizedBox(height: 8),
        for (final task in tasks) ...[
          TaskCard(
            task: task,
            goal: goal,
            onToggleCompleted: () {
              onToggleTaskCompleted(task.id);
            },
            onEdit: () {
              onEditTask(task);
            },
            onDelete: () {
              onDeleteTask(task.id);
            },
          ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}

class _GoalTaskGroup {
  const _GoalTaskGroup({
    required this.goal,
    required this.tasks,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
}