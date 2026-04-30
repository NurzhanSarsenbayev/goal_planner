import 'package:flutter/material.dart';

import '../../models/recurring_task_rule.dart';

class RecurringTaskRuleCard extends StatelessWidget {
  const RecurringTaskRuleCard({
    super.key,
    required this.rule,
    this.onActiveChanged,
    this.onDelete,
  });

  final RecurringTaskRule rule;
  final ValueChanged<bool>? onActiveChanged;
  final VoidCallback? onDelete;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          rule.isActive ? Icons.repeat : Icons.pause_circle_outline,
        ),
        title: Text(rule.title),
        subtitle: Text(_ruleSubtitle()),
        trailing: onActiveChanged == null
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
                  }
                },
                itemBuilder: (context) {
                  return [
                    if (onActiveChanged != null && rule.isActive)
                      const PopupMenuItem(
                        value: _RecurringTaskRuleAction.deactivate,
                        child: Text('Deactivate'),
                      )
                    else if (onActiveChanged != null)
                      const PopupMenuItem(
                        value: _RecurringTaskRuleAction.activate,
                        child: Text('Activate'),
                      ),
                    if (onDelete != null)
                      const PopupMenuItem(
                        value: _RecurringTaskRuleAction.delete,
                        child: Text('Delete'),
                      ),
                  ];
                },
              ),
      ),
    );
  }

  String _ruleSubtitle() {
    final placement = _placementLabel();
    final recurrence = _recurrenceLabel();
    final baseLabel = placement == null
        ? recurrence
        : '$recurrence · $placement';

    if (rule.isActive) {
      return baseLabel;
    }

    return 'Inactive · $baseLabel';
  }

  String? _placementLabel() {
    if (rule.milestoneId != null) {
      return 'Milestone task';
    }

    if (rule.goalId != null) {
      return 'Goal task';
    }

    return null;
  }

  String _recurrenceLabel() {
    return switch (rule.recurrenceType) {
      RecurrenceType.weekly => _weeklyLabel(),
      RecurrenceType.monthly => _monthlyLabel(),
    };
  }

  String _weeklyLabel() {
    if (rule.weekdays.isEmpty) {
      return 'Weekly';
    }

    final labels = rule.weekdays.map(_weekdayLabel).join(', ');

    return 'Weekly · $labels';
  }

  String _monthlyLabel() {
    final monthDay = rule.monthDay;

    if (monthDay == null) {
      return 'Monthly';
    }

    return 'Monthly · day $monthDay';
  }

  String _weekdayLabel(int weekday) {
    return switch (weekday) {
      DateTime.monday => 'Mon',
      DateTime.tuesday => 'Tue',
      DateTime.wednesday => 'Wed',
      DateTime.thursday => 'Thu',
      DateTime.friday => 'Fri',
      DateTime.saturday => 'Sat',
      DateTime.sunday => 'Sun',
      _ => '?',
    };
  }
}

enum _RecurringTaskRuleAction { activate, deactivate, delete }
