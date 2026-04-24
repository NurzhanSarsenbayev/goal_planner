import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/goal_card.dart';
import '../widgets/placeholder_screen.dart';

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onGoalSelected,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(Goal goal) onGoalSelected;

  @override
  Widget build(BuildContext context) {
    if (goals.isEmpty) {
      return const PlaceholderScreen(
        title: 'Goals',
        description: 'No goals yet. Create your first long-term goal.',
        icon: Icons.flag,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: goals.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final goal = goals[index];
        final goalTasks = tasks.where((task) => task.goalId == goal.id).toList();

        final completedTasks =
            goalTasks.where((task) => task.isCompleted).length;

        return GoalCard(
          goal: goal,
          totalTasks: goalTasks.length,
          completedTasks: completedTasks,
          onTap: () => onGoalSelected(goal),
        );
      },
    );
  }
}