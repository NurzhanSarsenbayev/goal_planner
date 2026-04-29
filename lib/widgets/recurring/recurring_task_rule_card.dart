import 'package:flutter/material.dart';

import '../../models/recurring_task_rule.dart';

class RecurringTaskRuleCard extends StatelessWidget {
  const RecurringTaskRuleCard({super.key, required this.rule});

  final RecurringTaskRule rule;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          rule.isActive ? Icons.repeat : Icons.pause_circle_outline,
        ),
        title: Text(rule.title),
        subtitle: Text(_ruleSubtitle()),
        trailing: rule.isActive
            ? null
            : Text('Inactive', style: Theme.of(context).textTheme.bodySmall),
      ),
    );
  }

  String _ruleSubtitle() {
    final placement = _placementLabel();
    final recurrence = _recurrenceLabel();

    if (placement == null) {
      return recurrence;
    }

    return '$recurrence · $placement';
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
