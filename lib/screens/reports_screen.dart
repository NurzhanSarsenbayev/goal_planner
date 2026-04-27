import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../reports/report_builder.dart';
import '../reports/report_period.dart';
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
  ReportPeriod _selectedPeriod = ReportPeriod.today;

  @override
  Widget build(BuildContext context) {
    final report = buildReportSummary(
      goals: widget.goals,
      tasks: widget.tasks,
      period: _selectedPeriod,
      today: DateTime.now(),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Reports')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Text(
            _selectedPeriod.title,
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
          if (report.completedTasks.isEmpty)
            _EmptyReportCard(periodTitle: _selectedPeriod.title)
          else ...[
            _ReportSummaryCard(
              completedCount: report.completedCount,
              goalLinkedCount: report.goalLinkedCount,
              standaloneCount: report.standaloneCount,
            ),
            const SizedBox(height: 24),
            Text('By goal', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            if (report.goalGroups.isEmpty)
              Text(
                'No goal-linked tasks completed in this period.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final group in report.goalGroups) ...[
                _GoalReportSection(
                  goal: group.goal,
                  tasks: group.tasks,
                  onToggleTaskCompleted: widget.onToggleTaskCompleted,
                  onEditTask: widget.onEditTask,
                  onDeleteTask: widget.onDeleteTask,
                ),
                const SizedBox(height: 16),
              ],
            if (report.standaloneTasks.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                'Standalone',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              for (final task in report.standaloneTasks) ...[
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
}

class _ReportPeriodSelector extends StatelessWidget {
  const _ReportPeriodSelector({
    required this.selectedPeriod,
    required this.onChanged,
  });

  final ReportPeriod selectedPeriod;
  final void Function(ReportPeriod period) onChanged;

  @override
  Widget build(BuildContext context) {
    return SegmentedButton<ReportPeriod>(
      segments: const [
        ButtonSegment(value: ReportPeriod.today, label: Text('Today')),
        ButtonSegment(value: ReportPeriod.last7Days, label: Text('7 days')),
        ButtonSegment(value: ReportPeriod.last14Days, label: Text('14 days')),
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
