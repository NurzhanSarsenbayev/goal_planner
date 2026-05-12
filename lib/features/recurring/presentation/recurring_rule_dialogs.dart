import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/recurring_task_rule.dart';
import 'widgets/add_recurring_task_rule_dialog.dart';

Future<AddRecurringTaskRuleDraft?> showAddRecurringTaskRuleDialog(
  BuildContext context, {
  required List<Goal> goals,
  required List<Milestone> milestones,
  DateTime? initialDate,
  String? initialGoalId,
  String? initialMilestoneId,
}) {
  return showDialog<AddRecurringTaskRuleDraft>(
    context: context,
    builder: (context) {
      return AddRecurringTaskRuleDialog(
        goals: goals,
        milestones: milestones,
        initialDate: initialDate,
        initialGoalId: initialGoalId,
        initialMilestoneId: initialMilestoneId,
      );
    },
  );
}

Future<AddRecurringTaskRuleDraft?> showEditRecurringTaskRuleDialog(
  BuildContext context, {
  required RecurringTaskRule rule,
  required List<Goal> goals,
  required List<Milestone> milestones,
}) {
  return showDialog<AddRecurringTaskRuleDraft>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AddRecurringTaskRuleDialog(
        goals: goals,
        milestones: milestones,
        initialRule: rule,
        dialogTitle: l10n.recurringRuleDialogEditTitle,
        submitLabel: l10n.commonSave,
      );
    },
  );
}
