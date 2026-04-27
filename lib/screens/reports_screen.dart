import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../shared/planner_dates.dart';
import '../widgets/tasks/task_card.dart';

class ReportsScreen extends StatefulWidget {
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
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  _ReportPeriod _selectedPeriod = _ReportPeriod.today;

  @override
  Widget build(BuildContext context) {
    final completedTasks = _completedTasksForPeriod(_selectedPeriod);
    final goalLinkedTasks = completedTasks
        .where((task) => task.goalId != null)
        .toList();
    final standaloneTasks = completedTasks
        .where((task) => task.goalId == null)
        .toList();
    final groupedByGoal = _groupTasksByGoal(goalLinkedTasks);

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _periodTitle(_selectedPeriod),
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 16),
          _ReportPeriodSelector(
            selectedPeriod: _selectedPeriod,
            onChanged: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
          ),
          const SizedBox(height: 16),
          if (completedTasks.isEmpty)
            _EmptyReportCard(periodTitle: _periodTitle(_selectedPeriod))
          else ...[
            _ReportSummaryCard(
              completedCount: completedTasks.length,
              goalLinkedCount: goalLinkedTasks.length,
              standaloneCount: standaloneTasks.length,
            ),
            const SizedBox(height: 24),
            Text('By goal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (groupedByGoal.isEmpty)
              Text(
                'No goal-linked tasks completed in this period.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final group in groupedByGoal) ...[
                _GoalReportSection(
                  goal: group.goal,
                  tasks: group.tasks,
                  onToggleTaskCompleted: widget.onToggleTaskCompleted,
                  onEditTask: widget.onEditTask,
                  onDeleteTask: widget.onDeleteTask,
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
                    widget.onToggleTaskCompleted(task.id);
                  },
                  onEdit: () {
                    widget.onEditTask(task);
                  },
                  onDelete: () {
                    widget.onDeleteTask(task.id);
                  },
                ),
                const SizedBox(height: 8),
              ],
            ],
          ],
        ],
      ),
    );
  }

  List<PlannerTask> _completedTasksForPeriod(_ReportPeriod period) {
    final today = todayDate();
    final startDate = _periodStartDate(period, today);

    final completedTasks =
        widget.tasks.where((task) {
          final completedAt = task.completedAt;

          if (completedAt == null) {
            return false;
          }

          final completedDate = dateOnly(completedAt);

          return !completedDate.isBefore(startDate) &&
              !completedDate.isAfter(today);
        }).toList()..sort((first, second) {
          final firstCompletedAt = first.completedAt!;
          final secondCompletedAt = second.completedAt!;

          return secondCompletedAt.compareTo(firstCompletedAt);
        });

    return completedTasks;
  }

  DateTime _periodStartDate(_ReportPeriod period, DateTime today) {
    return switch (period) {
      _ReportPeriod.today => today,
      _ReportPeriod.last7Days => today.subtract(const Duration(days: 6)),
      _ReportPeriod.last14Days => today.subtract(const Duration(days: 13)),
    };
  }

  List<_GoalTaskGroup> _groupTasksByGoal(List<PlannerTask> sourceTasks) {
    final groups = <_GoalTaskGroup>[];

    for (final goal in widget.goals) {
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

  String _periodTitle(_ReportPeriod period) {
    return switch (period) {
      _ReportPeriod.today => 'Today',
      _ReportPeriod.last7Days => 'Last 7 days',
      _ReportPeriod.last14Days => 'Last 14 days',
    };
  }
}

enum _ReportPeriod { today, last7Days, last14Days }

class _ReportPeriodSelector extends StatelessWidget {
  const _ReportPeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final _ReportPeriod selectedPeriod;
  final void Function(_ReportPeriod period) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<_ReportPeriod>(
      segments: const [
        ButtonSegment(value: _ReportPeriod.today, label: Text('Today')),
        ButtonSegment(value: _ReportPeriod.last7Days, label: Text('7 days')),
        ButtonSegment(value: _ReportPeriod.last14Days, label: Text('14 days')),
      ],
      selected: {selectedPeriod},
      onSelectionChanged: (selection) {
        onChanged(selection.first);
      },
    );
  }
}

class _EmptyReportCard extends StatelessWidget {
  const _EmptyReportCard({required this.periodTitle});

  final String periodTitle;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            const Icon(Icons.analytics),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No completed tasks for $periodTitle yet.',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      ),
    );
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
  const _SummaryRow({required this.label, required this.value});

  final String label;
  final int value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Text(label)),
        Text(value.toString(), style: Theme.of(context).textTheme.titleMedium),
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
        Text(goal.title, style: Theme.of(context).textTheme.titleSmall),
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
  const _GoalTaskGroup({required this.goal, required this.tasks});

  final Goal goal;
  final List<PlannerTask> tasks;
}
