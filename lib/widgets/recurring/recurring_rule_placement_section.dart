import 'package:flutter/material.dart';

import '../../models/goal.dart';
import '../../models/milestone.dart';

class RecurringRulePlacementSection extends StatelessWidget {
  const RecurringRulePlacementSection({
    super.key,
    required this.goals,
    required this.milestones,
    required this.selectedGoalId,
    required this.selectedMilestoneId,
    required this.onGoalChanged,
    required this.onMilestoneChanged,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final String? selectedGoalId;
  final String? selectedMilestoneId;
  final ValueChanged<String?> onGoalChanged;
  final ValueChanged<String?> onMilestoneChanged;

  @override
  Widget build(BuildContext context) {
    final availableMilestones = milestones
        .where((milestone) => milestone.goalId == selectedGoalId)
        .toList();

    return Column(
      children: [
        DropdownButtonFormField<String?>(
          initialValue: selectedGoalId,
          decoration: const InputDecoration(labelText: 'Goal'),
          items: [
            const DropdownMenuItem<String?>(
              value: null,
              child: Text('No goal'),
            ),
            for (final goal in goals)
              DropdownMenuItem<String?>(
                value: goal.id,
                child: Text(goal.title),
              ),
          ],
          onChanged: onGoalChanged,
        ),
        if (selectedGoalId != null) ...[
          const SizedBox(height: 8),
          DropdownButtonFormField<String?>(
            key: ValueKey(selectedGoalId),
            initialValue: selectedMilestoneId,
            decoration: const InputDecoration(labelText: 'Milestone'),
            items: [
              const DropdownMenuItem<String?>(
                value: null,
                child: Text('Direct goal task'),
              ),
              for (final milestone in availableMilestones)
                DropdownMenuItem<String?>(
                  value: milestone.id,
                  child: Text(milestone.title),
                ),
            ],
            onChanged: onMilestoneChanged,
          ),
        ],
      ],
    );
  }
}
