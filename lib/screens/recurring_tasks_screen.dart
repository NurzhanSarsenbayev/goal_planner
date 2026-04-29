import 'package:flutter/material.dart';

import '../models/recurring_task_rule.dart';
import '../widgets/common/placeholder_screen.dart';
import '../widgets/recurring/recurring_task_rule_card.dart';

class RecurringTasksScreen extends StatelessWidget {
  const RecurringTasksScreen({
    super.key,
    required this.rules,
    required this.onAddRule,
  });

  final List<RecurringTaskRule> rules;
  final VoidCallback onAddRule;

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

                return RecurringTaskRuleCard(rule: rule);
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
