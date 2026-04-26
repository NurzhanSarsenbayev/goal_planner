import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import 'milestone_card.dart';
import 'placeholder_screen.dart';
import 'section_header.dart';

class MilestonesSection extends StatelessWidget {
  const MilestonesSection({
    super.key,
    required this.goal,
    required this.milestones,
    required this.goalTasks,
    required this.onAddMilestone,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    required this.onAddTaskToMilestone,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onMoveTaskToDirectGoal,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onDeleteTask,
  });

  final Goal goal;
  final List<Milestone> milestones;
  final List<PlannerTask> goalTasks;
  final VoidCallback onAddMilestone;
  final void Function(Milestone milestone) onEditMilestone;
  final void Function(Milestone milestone) onDeleteMilestone;
  final void Function(String milestoneId) onAddTaskToMilestone;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onMoveTaskToDirectGoal;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function(PlannerTask task) onScheduleTaskForDate;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: 'Milestones',
          actionLabel: 'Add milestone',
          onActionPressed: onAddMilestone,
        ),
        const SizedBox(height: 8),
        if (milestones.isEmpty)
          const PlaceholderScreen(
            title: 'No milestones yet',
            description: 'Add milestones to group tasks inside this goal.',
            icon: Icons.account_tree_outlined,
          )
        else
          ...milestones.map((milestone) {
            final milestoneTasks = goalTasks
                .where((task) => task.milestoneId == milestone.id)
                .toList();

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MilestoneCard(
                goal: goal,
                milestone: milestone,
                tasks: milestoneTasks,
                onAddTask: () => onAddTaskToMilestone(milestone.id),
                onEditMilestone: () => onEditMilestone(milestone),
                onDeleteMilestone: () => onDeleteMilestone(milestone),
                onToggleTaskCompleted: onToggleTaskCompleted,
                onEditTask: onEditTask,
                onMoveTaskToDirectGoal: onMoveTaskToDirectGoal,
                onScheduleTaskForToday: onScheduleTaskForToday,
                onScheduleTaskForDate: onScheduleTaskForDate,
                onDeleteTask: onDeleteTask,
              ),
            );
          }),
      ],
    );
  }
}
