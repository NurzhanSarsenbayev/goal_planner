import 'package:flutter/material.dart';

import '../../../../models/goal.dart';
import '../../../../models/milestone.dart';
import '../../../../models/planner_task.dart';
import '../../../../models/recurring_task_rule.dart';
import '../widgets/goal_recurring_tasks_section.dart';
import '../../application/goal_details_view_builder.dart';
import '../goal_details_dialog_actions.dart';
import '../widgets/direct_goal_tasks_section.dart';
import '../widgets/goal_header.dart';
import '../../../milestones/presentation/widgets/milestones_section.dart';

class GoalDetailsScreen extends StatelessWidget {
  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.milestones,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskCreated,
    required this.onDeleteTask,
    required this.onTaskUpdated,
    required this.onTaskMovedToDirectGoal,
    required this.onTaskAssignedToMilestone,
    required this.onMilestoneCreated,
    required this.onMilestoneUpdated,
    required this.onMilestoneDeletedAndTasksMovedToDirect,
    required this.onMilestoneDeletedWithTasks,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onCompleteTaskOnDate,
    required this.recurringRules,
  });

  final Goal goal;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onTaskCreated;
  final void Function(String taskId) onDeleteTask;

  final void Function({
    required String taskId,
    required String title,
    required String description,
  })
  onTaskUpdated;

  final void Function(String taskId) onTaskMovedToDirectGoal;

  final void Function({required String taskId, required String milestoneId})
  onTaskAssignedToMilestone;

  final void Function(Milestone milestone) onMilestoneCreated;

  final void Function({
    required String milestoneId,
    required String title,
    required String description,
  })
  onMilestoneUpdated;

  final void Function(String milestoneId)
  onMilestoneDeletedAndTasksMovedToDirect;
  final void Function(String milestoneId) onMilestoneDeletedWithTasks;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;
  final GoalDetailsViewBuilder _viewBuilder = const GoalDetailsViewBuilder();
  final GoalDetailsDialogActions _dialogActions =
      const GoalDetailsDialogActions();

  @override
  Widget build(BuildContext context) {
    final view = _viewBuilder.build(
      goal: goal,
      milestones: milestones,
      tasks: tasks,
      recurringRules: recurringRules,
    );
    return Scaffold(
      appBar: AppBar(title: Text(goal.title)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GoalHeader(
            goal: goal,
            totalTasks: view.goalTasks.length,
            completedTasks: view.completedTasks,
          ),
          const SizedBox(height: 16),
          MilestonesSection(
            goal: goal,
            milestones: view.goalMilestones,
            goalTasks: view.goalTasks,
            recurringRulesByMilestoneId: view.recurringRulesByMilestoneId,
            onAddMilestone: () {
              _dialogActions.showAddMilestoneDialog(
                context,
                goal: goal,
                onMilestoneCreated: onMilestoneCreated,
              );
            },
            onEditMilestone: (milestone) {
              _dialogActions.showEditMilestoneDialog(
                context,
                milestone: milestone,
                onMilestoneUpdated: onMilestoneUpdated,
              );
            },
            onDeleteMilestone: (milestone) {
              _dialogActions.showDeleteMilestoneDialog(
                context,
                milestone: milestone,
                taskCount: view.tasksForMilestone(milestone.id).length,
                onMoveTasksToDirect: onMilestoneDeletedAndTasksMovedToDirect,
                onDeleteTasks: onMilestoneDeletedWithTasks,
              );
            },
            onAddTaskToMilestone: (milestoneId) {
              _dialogActions.showAddTaskDialog(
                context,
                goal: goal,
                milestoneId: milestoneId,
                onTaskCreated: onTaskCreated,
              );
            },
            onToggleTaskCompleted: (task) {
              _dialogActions.toggleTaskCompletedWithDateFlow(
                context,
                task: task,
                onToggleTaskCompleted: onToggleTaskCompleted,
                onCompleteTaskOnDate: onCompleteTaskOnDate,
              );
            },
            onEditTask: (task) {
              _dialogActions.showEditTaskDialog(
                context,
                task: task,
                onTaskUpdated: onTaskUpdated,
              );
            },
            onMoveTaskToDirectGoal: onTaskMovedToDirectGoal,
            onScheduleTaskForToday: onScheduleTaskForToday,
            onScheduleTaskForDate: (task) {
              _dialogActions.showScheduleTaskDatePicker(
                context,
                task: task,
                onScheduleTaskForDate: onScheduleTaskForDate,
              );
            },
            onDeleteTask: onDeleteTask,
          ),
          const SizedBox(height: 16),
          GoalRecurringTasksSection(rules: view.directGoalRecurringRules),
          if (view.directGoalRecurringRules.isNotEmpty)
            const SizedBox(height: 16),
          DirectGoalTasksSection(
            goal: goal,
            tasks: view.directGoalTasks,
            onAddTask: () {
              _dialogActions.showAddTaskDialog(
                context,
                goal: goal,
                onTaskCreated: onTaskCreated,
              );
            },
            onToggleTaskCompleted: (task) {
              _dialogActions.toggleTaskCompletedWithDateFlow(
                context,
                task: task,
                onToggleTaskCompleted: onToggleTaskCompleted,
                onCompleteTaskOnDate: onCompleteTaskOnDate,
              );
            },
            onEditTask: (task) {
              _dialogActions.showEditTaskDialog(
                context,
                task: task,
                onTaskUpdated: onTaskUpdated,
              );
            },
            onMoveTaskToMilestone: (task) {
              _dialogActions.showMoveTaskToMilestoneDialog(
                context,
                task: task,
                milestones: view.goalMilestones,
                onTaskAssignedToMilestone: onTaskAssignedToMilestone,
              );
            },
            onScheduleTaskForToday: onScheduleTaskForToday,
            onScheduleTaskForDate: (task) {
              _dialogActions.showScheduleTaskDatePicker(
                context,
                task: task,
                onScheduleTaskForDate: onScheduleTaskForDate,
              );
            },
            onDeleteTask: onDeleteTask,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
