import 'package:flutter/material.dart';

import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../application/habit_report_loader.dart';
import '../../application/report_builder.dart';
import '../../domain/habit_report_summary.dart';
import '../../domain/report_period.dart';
import '../widgets/day_report_section.dart';
import '../widgets/empty_report_card.dart';
import '../widgets/goal_report_section.dart';
import '../widgets/habit_report_section.dart';
import '../widgets/habit_report_summary_card.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/report_summary_card.dart';
import '../widgets/standalone_report_section.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.habitReportLoader,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final HabitReportLoader habitReportLoader;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onDeleteTask;

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  ReportPeriod _selectedPeriod = ReportPeriod.today;
  HabitReportSummary? _habitReport;
  bool _isHabitReportLoading = false;
  int _habitReportRequestId = 0;

  @override
  void initState() {
    super.initState();

    _loadHabitReport();
  }

  @override
  void didUpdateWidget(covariant ReportsScreen oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.habitReportLoader != widget.habitReportLoader ||
        oldWidget.goals != widget.goals ||
        oldWidget.tasks != widget.tasks) {
      _loadHabitReport();
    }
  }

  Future<void> _loadHabitReport() async {
    final requestId = _habitReportRequestId + 1;
    _habitReportRequestId = requestId;

    setState(() {
      _isHabitReportLoading = true;
    });

    final habitReport = await widget.habitReportLoader.load(_selectedPeriod);

    if (!mounted || requestId != _habitReportRequestId) {
      return;
    }

    setState(() {
      _habitReport = habitReport;
      _isHabitReportLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final taskReport = buildReportSummary(
      goals: widget.goals,
      tasks: widget.tasks,
      period: _selectedPeriod,
      today: DateTime.now(),
    );

    final habitReport = _habitReport;
    final hasTaskReport = taskReport.completedTasks.isNotEmpty;
    final hasHabitReport = habitReport != null && habitReport.hasHabitData;
    final isEmptyReport =
        !hasTaskReport && !hasHabitReport && !_isHabitReportLoading;

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
              _loadHabitReport();
            },
          ),
          const SizedBox(height: 16),
          if (_isHabitReportLoading) ...[
            const LinearProgressIndicator(),
            const SizedBox(height: 16),
          ],
          if (isEmptyReport)
            EmptyReportCard(periodTitle: _selectedPeriod.title)
          else ...[
            if (hasTaskReport) ...[
              Text('Tasks', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              ReportSummaryCard(
                completedCount: taskReport.completedCount,
                plannedCount: taskReport.plannedCount,
                planCompletionPercent: taskReport.planCompletionPercent,
                currentStreakDays: taskReport.currentStreakDays,
              ),
              const SizedBox(height: 24),
            ],
            if (hasHabitReport) ...[
              HabitReportSummaryCard(summary: habitReport),
              const SizedBox(height: 24),
              Text(
                'Habit breakdown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              HabitReportSection(summary: habitReport),
              const SizedBox(height: 24),
            ],
            if (hasTaskReport) ...[
              Text(
                'Goal contribution',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              if (taskReport.goalGroups.isEmpty &&
                  taskReport.standaloneTasks.isEmpty)
                Text(
                  'No completed tasks in this period.',
                  style: Theme.of(context).textTheme.bodyMedium,
                )
              else ...[
                for (final group in taskReport.goalGroups) ...[
                  GoalReportSection(goal: group.goal, tasks: group.tasks),
                  const SizedBox(height: 8),
                ],
                if (taskReport.standaloneTasks.isNotEmpty) ...[
                  StandaloneReportSection(
                    completedCount: taskReport.standaloneCount,
                  ),
                  const SizedBox(height: 8),
                ],
              ],
              const SizedBox(height: 24),
              Text('By day', style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final group in taskReport.dayGroups) ...[
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
        ],
      ),
    );
  }
}
