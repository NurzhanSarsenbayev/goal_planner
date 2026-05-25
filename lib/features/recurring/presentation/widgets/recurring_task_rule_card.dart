import 'package:flutter/material.dart';

import '../../../../shared/planner_time.dart';
import '../../../../l10n/app_localizations.dart';
import '../../../../models/recurring_task_rule.dart';

class RecurringTaskRuleCard extends StatelessWidget {
  const RecurringTaskRuleCard({
    super.key,
    required this.rule,
    this.onActiveChanged,
    this.onDelete,
    this.onEdit,
  });

  final RecurringTaskRule rule;
  final ValueChanged<bool>? onActiveChanged;
  final VoidCallback? onDelete;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Card(
      child: ListTile(
        leading: Icon(
          rule.isActive ? Icons.repeat : Icons.pause_circle_outline,
        ),
        title: Text(rule.title),
        subtitle: Text(_ruleSubtitle(l10n)),
        trailing: onActiveChanged == null && onEdit == null && onDelete == null
            ? null
            : PopupMenuButton<_RecurringTaskRuleAction>(
                onSelected: (action) {
                  switch (action) {
                    case _RecurringTaskRuleAction.activate:
                      onActiveChanged?.call(true);
                    case _RecurringTaskRuleAction.deactivate:
                      onActiveChanged?.call(false);
                    case _RecurringTaskRuleAction.delete:
                      onDelete?.call();
                    case _RecurringTaskRuleAction.edit:
                      onEdit?.call();
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (onActiveChanged != null && rule.isActive)
                      PopupMenuItem(
                        value: _RecurringTaskRuleAction.deactivate,
                        child: Text(l10n.recurringRuleActionDeactivate),
                      )
                    else if (onActiveChanged != null)
                      PopupMenuItem(
                        value: _RecurringTaskRuleAction.activate,
                        child: Text(l10n.recurringRuleActionActivate),
                      ),
                    if (onDelete != null)
                      PopupMenuItem(
                        value: _RecurringTaskRuleAction.delete,
                        child: Text(l10n.commonDelete),
                      ),
                    if (onEdit != null)
                      PopupMenuItem(
                        value: _RecurringTaskRuleAction.edit,
                        child: Text(l10n.commonEdit),
                      ),
                  ];
                },
              ),
      ),
    );
  }

  String _ruleSubtitle(AppLocalizations l10n) {
    final placement = _placementLabel(l10n);
    final recurrence = _recurrenceLabel(l10n);
    final schedule = _scheduleLabel(l10n);

    final recurrenceLabel = placement == null
        ? recurrence
        : l10n.recurringRuleSubtitleWithPlacement(recurrence, placement);

    final baseLabel = schedule == null
        ? recurrenceLabel
        : l10n.recurringRuleSubtitleWithPlacement(recurrenceLabel, schedule);

    if (rule.isActive) {
      return baseLabel;
    }

    return l10n.recurringRuleInactiveSubtitle(baseLabel);
  }

  String? _placementLabel(AppLocalizations l10n) {
    if (rule.milestoneId != null) {
      return l10n.recurringRuleMilestoneTaskLabel;
    }

    if (rule.goalId != null) {
      return l10n.recurringRuleGoalTaskLabel;
    }

    return null;
  }

  String _recurrenceLabel(AppLocalizations l10n) {
    return switch (rule.recurrenceType) {
      RecurrenceType.weekly => _weeklyLabel(l10n),
      RecurrenceType.monthly => _monthlyLabel(l10n),
    };
  }

  String _weeklyLabel(AppLocalizations l10n) {
    if (rule.weekdays.isEmpty) {
      return l10n.recurringRuleWeeklyLabel;
    }

    final labels = rule.weekdays
        .map((weekday) {
          return _weekdayLabel(l10n, weekday);
        })
        .join(', ');

    return l10n.recurringRuleWeeklyWithDays(labels);
  }

  String _monthlyLabel(AppLocalizations l10n) {
    final monthDay = rule.monthDay;

    if (monthDay == null) {
      return l10n.recurringRuleMonthlyLabel;
    }

    return l10n.recurringRuleMonthlyDay(monthDay);
  }

  String _weekdayLabel(AppLocalizations l10n, int weekday) {
    return switch (weekday) {
      DateTime.monday => l10n.recurringWeekdayMonShort,
      DateTime.tuesday => l10n.recurringWeekdayTueShort,
      DateTime.wednesday => l10n.recurringWeekdayWedShort,
      DateTime.thursday => l10n.recurringWeekdayThuShort,
      DateTime.friday => l10n.recurringWeekdayFriShort,
      DateTime.saturday => l10n.recurringWeekdaySatShort,
      DateTime.sunday => l10n.recurringWeekdaySunShort,
      _ => '?',
    };
  }

  String? _scheduleLabel(AppLocalizations l10n) {
    final scheduledTimeMinutes = rule.scheduledTimeMinutes;

    if (scheduledTimeMinutes == null) {
      return null;
    }

    final timeLabel = l10n.taskTimeSelectedButton(
      formatPlannerTime(scheduledTimeMinutes),
    );

    final reminderMinutesBefore = rule.reminderMinutesBefore;

    if (reminderMinutesBefore == null) {
      return timeLabel;
    }

    return l10n.recurringRuleSubtitleWithPlacement(
      timeLabel,
      _reminderLabel(l10n, reminderMinutesBefore),
    );
  }

  String _reminderLabel(AppLocalizations l10n, int reminderMinutesBefore) {
    if (reminderMinutesBefore == 0) {
      return l10n.taskReminderAtTimeOption;
    }

    if (reminderMinutesBefore % 60 == 0) {
      return l10n.taskReminderHoursBeforeOption(reminderMinutesBefore ~/ 60);
    }

    return l10n.taskReminderMinutesBeforeOption(reminderMinutesBefore);
  }
}

enum _RecurringTaskRuleAction { activate, deactivate, edit, delete }
