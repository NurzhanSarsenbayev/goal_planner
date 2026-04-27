import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../reports/report_builder.dart';
import '../reports/report_period.dart';
import '../widgets/reports/day_report_section.dart';
import '../widgets/reports/empty_report_card.dart';
import '../widgets/reports/goal_report_section.dart';
import '../widgets/reports/report_period_selector.dart';
import '../widgets/reports/report_summary_card.dart';
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
          ReportPeriodSelector(
            selectedPeriod: _selectedPeriod,
            onChanged: (period) {
              setState(() {
                _selectedPeriod = period;
              });
            },
          ),
          const SizedBox(height: 16),
          if (report.completedTasks.isEmpty)
            EmptyReportCard(periodTitle: _selectedPeriod.title)
          else ...[
            ReportSummaryCard(
              completedCount: report.completedCount,
              goalLinkedCount: report.goalLinkedCount,
              standaloneCount: report.standaloneCount,
              activeDaysCount: report.activeDaysCount,
              periodDaysCount: report.period.daysCount,
              goalLinkedSharePercent: report.goalLinkedSharePercent,
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
                GoalReportSection(
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
            const SizedBox(height: 24),
            Text('By day', style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            for (final group in report.dayGroups) ...[
              DayReportSection(
                date: group.date,
                tasks: group.tasks,
                goals: widget.goals,
                onToggleTaskCompleted: widget.onToggleTaskCompleted,
                onEditTask: widget.onEditTask,
                onDeleteTask: widget.onDeleteTask,
              ),
              const SizedBox(height: 16),
            ],
          ],
        ],
      ),
    );
  }
}
