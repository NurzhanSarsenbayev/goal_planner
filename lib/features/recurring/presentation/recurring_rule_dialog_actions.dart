import 'package:flutter/material.dart';

import 'recurring_rule_dialogs.dart';
import '../../../models/recurring_task_rule.dart';
import '../../../shared/planner_dates.dart';
import '../../../state/planner_store.dart';

class RecurringRuleDialogActions {
  const RecurringRuleDialogActions({required PlannerStore store})
    : _store = store;

  final PlannerStore _store;

  Future<void> showAddDialog(
    BuildContext context, {
    DateTime? startDate,
  }) async {
    final result = await showAddRecurringTaskRuleDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
      initialDate: startDate,
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();

    final rule = RecurringTaskRule(
      id: 'recurring_rule_${now.microsecondsSinceEpoch}',
      title: result.title,
      description: result.description,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
      recurrenceType: result.recurrenceType,
      weekdays: result.weekdays,
      monthDay: result.monthDay,
      startDate: dateOnly(startDate ?? todayDate()),
      createdAt: now,
    );

    _store.addRecurringTaskRule(rule);

    if (startDate != null) {
      _store.ensureRecurringTaskOccurrencesForMonth(
        DateTime(startDate.year, startDate.month),
      );
    }
  }

  Future<void> showEditDialog(
    BuildContext context,
    RecurringTaskRule rule,
  ) async {
    final result = await showEditRecurringTaskRuleDialog(
      context,
      rule: rule,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    final updatedRule = rule.copyWith(
      title: result.title,
      description: result.description,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
      recurrenceType: result.recurrenceType,
      weekdays: result.weekdays,
      monthDay: result.monthDay,
    );

    _store.updateRecurringTaskRule(updatedRule);
  }
}
