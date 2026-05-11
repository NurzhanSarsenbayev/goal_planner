import 'package:flutter/material.dart';

import '../recurring_rule_delete_dialog.dart';
import '../../../../models/recurring_task_rule.dart';
import '../../../../shared/presentation/widgets/placeholder_screen.dart';
import '../widgets/recurring_task_rule_card.dart';

class RecurringTasksScreen extends StatelessWidget {
  const RecurringTasksScreen({
    super.key,
    required this.rules,
    required this.onAddRule,
    required this.onRuleActiveChanged,
    required this.onDeleteRule,
    required this.onEditRule,
  });

  final List<RecurringTaskRule> rules;
  final VoidCallback onAddRule;
  final void Function(RecurringTaskRule rule, bool isActive)
  onRuleActiveChanged;
  final ValueChanged<RecurringTaskRule> onDeleteRule;
  final ValueChanged<RecurringTaskRule> onEditRule;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Recurring tasks')),
      body: rules.isEmpty
          ? const PlaceholderScreen(
              title: 'Recurring tasks',
              description: 'No recurring task rules yet.',
              icon: Icons.repeat,
            )
          : ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: rules.length,
              separatorBuilder: (_, _) => const SizedBox(height: 8),
              itemBuilder: (context, index) {
                final rule = rules[index];
                return RecurringTaskRuleCard(
                  rule: rule,
                  onActiveChanged: (isActive) {
                    onRuleActiveChanged(rule, isActive);
                  },
                  onEdit: () {
                    onEditRule(rule);
                  },
                  onDelete: () async {
                    final shouldDelete =
                        await showDeleteRecurringTaskRuleDialog(
                          context,
                          rule: rule,
                        );

                    if (!shouldDelete) {
                      return;
                    }

                    onDeleteRule(rule);
                  },
                );
              },
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: onAddRule,
        icon: const Icon(Icons.add),
        label: const Text('Add rule'),
      ),
    );
  }
}
