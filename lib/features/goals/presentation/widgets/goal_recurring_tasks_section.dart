import 'package:flutter/material.dart';

import '../../../../models/recurring_task_rule.dart';
import '../../../../shared/presentation/widgets/section_header.dart';
import '../../../recurring/presentation/widgets/recurring_task_rule_card.dart';

class GoalRecurringTasksSection extends StatelessWidget {
  const GoalRecurringTasksSection({
    super.key,
    required this.rules,
    required this.onAddRule,
  });

  final List<RecurringTaskRule> rules;
  final VoidCallback onAddRule;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Direct recurring tasks',
          actionLabel: 'Add recurring',
          onActionPressed: onAddRule,
        ),
        const SizedBox(height: 8),
        if (rules.isEmpty)
          Text(
            'No direct recurring tasks.',
            style: Theme.of(context).textTheme.bodySmall,
          )
        else
          ...rules.map(
            (rule) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: RecurringTaskRuleCard(rule: rule),
            ),
          ),
      ],
    );
  }
}
