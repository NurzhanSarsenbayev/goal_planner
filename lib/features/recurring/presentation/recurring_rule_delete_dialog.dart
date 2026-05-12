import 'package:flutter/material.dart';

import '../../../l10n/app_localizations.dart';
import '../../../models/recurring_task_rule.dart';

Future<bool> showDeleteRecurringTaskRuleDialog(
  BuildContext context, {
  required RecurringTaskRule rule,
}) async {
  final shouldDelete = await showDialog<bool>(
    context: context,
    builder: (context) {
      final l10n = AppLocalizations.of(context);

      return AlertDialog(
        title: Text(l10n.recurringRuleDeleteDialogTitle),
        content: Text(l10n.recurringRuleDeleteDialogMessage(rule.title)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: Text(l10n.commonDelete),
          ),
        ],
      );
    },
  );

  return shouldDelete == true;
}
