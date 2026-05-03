import 'package:flutter/material.dart';

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
                  onDelete: () {
                    _confirmDeleteRule(context, rule);
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

  Future<void> _confirmDeleteRule(
    BuildContext context,
    RecurringTaskRule rule,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete recurring rule?'),
          content: const Text(
            'This will remove all unfinished generated tasks from this series. '
            'Completed tasks will stay in your history.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (shouldDelete != true) {
      return;
    }

    onDeleteRule(rule);
  }
}
