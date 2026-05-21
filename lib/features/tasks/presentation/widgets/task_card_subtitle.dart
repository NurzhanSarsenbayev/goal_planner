import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../../shared/planner_dates.dart';
import '../../../../shared/planner_time.dart';

class TaskCardSubtitle extends StatelessWidget {
  const TaskCardSubtitle({
    super.key,
    required this.task,
    required this.goal,
    this.onScheduleForToday,
  });

  final PlannerTask task;
  final Goal? goal;
  final VoidCallback? onScheduleForToday;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final shouldShowScheduleButton =
        onScheduleForToday != null && !task.isScheduledForToday;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (task.description.isNotEmpty) Text(task.description),
        if (goal != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              l10n.taskCardGoalLabel(goal!.title),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (task.scheduledDate != null)
          Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _scheduledDateLabel(l10n, task.scheduledDate!),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        if (shouldShowScheduleButton)
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onScheduleForToday,
                icon: const Icon(Icons.today),
                label: Text(l10n.taskCardPlanTodayButton),
              ),
            ),
          ),
      ],
    );
  }

  String _scheduledDateLabel(AppLocalizations l10n, DateTime date) {
    final dateLabel = task.isScheduledForToday
        ? l10n.taskCardScheduledToday
        : l10n.taskCardScheduledDate(formatPlannerDate(date));

    final parts = <String>[dateLabel];

    final scheduledTimeMinutes = task.scheduledTimeMinutes;
    if (scheduledTimeMinutes != null) {
      parts.add(formatPlannerTime(scheduledTimeMinutes));
    }

    final reminderMinutesBefore = task.reminderMinutesBefore;
    if (reminderMinutesBefore != null) {
      parts.add(
        '${l10n.taskReminderFieldLabel}: '
        '${_reminderLabel(l10n, reminderMinutesBefore)}',
      );
    }

    return parts.join(' · ');
  }

  String _reminderLabel(AppLocalizations l10n, int minutesBefore) {
    if (minutesBefore == 0) {
      return l10n.taskReminderAtTimeOption;
    }

    if (minutesBefore % 60 == 0) {
      return l10n.taskReminderHoursBeforeOption(minutesBefore ~/ 60);
    }

    return l10n.taskReminderMinutesBeforeOption(minutesBefore);
  }
}
