import 'package:flutter/material.dart';

import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../application/report_builder.dart';
import '../../application/habit_report_loader.dart';
import '../../domain/habit_report_summary.dart';
import '../../domain/report_period.dart';
import '../widgets/day_report_section.dart';
import '../widgets/empty_report_card.dart';
import '../widgets/goal_report_section.dart';
import '../widgets/report_period_selector.dart';
import '../widgets/report_summary_card.dart';

import '../widgets/standalone_report_section.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onDeleteTask,
    required this.habitReportLoader,
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
              _loadHabitReport();
            },
          ),
          const SizedBox(height: 16),
          if (_isHabitReportLoading)
            const LinearProgressIndicator()
          else if (_habitReport != null && _habitReport!.hasHabitData)
            const SizedBox.shrink(),
          if (report.completedTasks.isEmpty)
            EmptyReportCard(periodTitle: _selectedPeriod.title)
          else ...[
            ReportSummaryCard(
              completedCount: report.completedCount,
              plannedCount: report.plannedCount,
              planCompletionPercent: report.planCompletionPercent,
              currentStreakDays: report.currentStreakDays,
            ),
            const SizedBox(height: 24),
            Text(
              'Goal contribution',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (report.goalGroups.isEmpty && report.standaloneTasks.isEmpty)
              Text(
                'No completed tasks in this period.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else ...[
              for (final group in report.goalGroups) ...[
                GoalReportSection(goal: group.goal, tasks: group.tasks),
                const SizedBox(height: 8),
              ],
              if (report.standaloneTasks.isNotEmpty) ...[
                StandaloneReportSection(completedCount: report.standaloneCount),
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
