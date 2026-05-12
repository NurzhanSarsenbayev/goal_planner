import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';

class GoalReportSection extends StatelessWidget {
  const GoalReportSection({super.key, required this.goal, required this.tasks});

  final Goal goal;
  final List<PlannerTask> tasks;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        title: Text(goal.title),
        subtitle: Text(l10n.reportsCompletedTasksSubtitle),
        trailing: Text(
          tasks.length.toString(),
          style: Theme.of(context).textTheme.titleMedium,
        ),
      ),
    );
  }
}
