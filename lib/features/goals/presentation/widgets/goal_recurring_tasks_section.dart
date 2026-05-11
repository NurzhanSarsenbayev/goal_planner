import 'package:flutter/material.dart';

import '../../../../models/recurring_task_rule.dart';
import '../../../recurring/presentation/widgets/recurring_task_rule_card.dart';

class GoalRecurringTasksSection extends StatelessWidget {
  const GoalRecurringTasksSection({super.key, required this.rules});

  final List<RecurringTaskRule> rules;

  @override
  Widget build(BuildContext context) {
    if (rules.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Direct recurring tasks',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
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
