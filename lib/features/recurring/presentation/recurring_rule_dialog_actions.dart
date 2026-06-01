import 'package:flutter/material.dart';

import 'recurring_rule_dialogs.dart';
import 'recurring_rule_delete_dialog.dart';
import '../../../l10n/app_localizations.dart';
import '../../../models/recurring_task_rule.dart';
import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';
import '../../../state/planner_store.dart';

class RecurringRuleDialogActions {
  const RecurringRuleDialogActions({required PlannerStore store})
    : _store = store;

  final PlannerStore _store;

  Future<void> showConvertTaskToRecurringDialog(
    BuildContext context,
    PlannerTask task,
  ) async {
    final l10n = AppLocalizations.of(context);
    final shouldContinue = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(l10n.taskConvertToRecurringConfirmTitle),
          content: Text(l10n.taskConvertToRecurringConfirmBody),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: Text(l10n.commonCancel),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: Text(l10n.commonContinue),
            ),
          ],
        );
      },
    );

    if (shouldContinue != true) {
      return;
    }

    if (!context.mounted) {
      return;
    }

    final startDate = dateOnly(task.scheduledDate ?? todayDate());
    final result = await showAddRecurringTaskRuleDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
      initialDate: startDate,
      initialTitle: task.title,
      initialDescription: task.description,
      initialGoalId: task.goalId,
      initialMilestoneId: task.milestoneId,
      initialScheduledTimeMinutes: task.scheduledTimeMinutes,
      initialReminderMinutesBefore: task.reminderMinutesBefore,
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
      startDate: startDate,
      createdAt: now,
      scheduledTimeMinutes: result.scheduledTimeMinutes,
      reminderMinutesBefore: result.reminderMinutesBefore,
    );

    _store.addRecurringTaskRule(rule);
    _store.deleteTask(task.id);

    _store.ensureRecurringTaskOccurrencesForMonth(
      DateTime(startDate.year, startDate.month),
    );
  }

  Future<void> showEditDialogById(BuildContext context, String ruleId) async {
    final rule = _findRuleById(ruleId);

    if (rule == null) {
      return;
    }

    await showEditDialog(context, rule);
  }

  Future<void> showDeleteDialogById(BuildContext context, String ruleId) async {
    final rule = _findRuleById(ruleId);

    if (rule == null) {
      return;
    }

    await showDeleteDialog(context, rule);
  }

  Future<void> showAddDialog(
    BuildContext context, {
    DateTime? startDate,
    String? goalId,
    String? milestoneId,
  }) async {
    final result = await showAddRecurringTaskRuleDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
      initialDate: startDate,
      initialGoalId: goalId,
      initialMilestoneId: milestoneId,
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
      scheduledTimeMinutes: result.scheduledTimeMinutes,
      reminderMinutesBefore: result.reminderMinutesBefore,
    );

    _store.addRecurringTaskRule(rule);

    if (startDate != null) {
      _store.ensureRecurringTaskOccurrencesForMonth(
        DateTime(startDate.year, startDate.month),
      );
    }
  }

  Future<void> showDeleteDialog(
    BuildContext context,
    RecurringTaskRule rule,
  ) async {
    final shouldDelete = await showDeleteRecurringTaskRuleDialog(
      context,
      rule: rule,
    );

    if (!shouldDelete) {
      return;
    }

    _store.deleteRecurringTaskRule(rule.id);
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
      scheduledTimeMinutes: result.scheduledTimeMinutes,
      reminderMinutesBefore: result.reminderMinutesBefore,
    );

    _store.updateRecurringTaskRule(updatedRule);
  }

  RecurringTaskRule? _findRuleById(String ruleId) {
    for (final rule in _store.recurringRules) {
      if (rule.id == ruleId) {
        return rule;
      }
    }

    return null;
  }
}
