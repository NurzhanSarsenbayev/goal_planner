import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../widgets/goal_card.dart';
import '../widgets/placeholder_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (sampleGoals.isEmpty) {
      return const PlaceholderScreen(
        title: 'Goals',
        description: 'No goals yet. Create your first long-term goal.',
        icon: Icons.flag,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sampleGoals.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final goal = sampleGoals[index];
        final goalTasks = sampleTasks
            .where((task) => task.goalId == goal.id)
            .toList();

        final completedTasks = goalTasks
            .where((task) => task.isCompleted)
            .length;

        return GoalCard(
          goal: goal,
          totalTasks: goalTasks.length,
          completedTasks: completedTasks,
        );
      },
    );
  }
}