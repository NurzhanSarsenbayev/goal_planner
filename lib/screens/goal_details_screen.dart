import 'package:flutter/material.dart';

import '../features/goals/application/goal_details_view_builder.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/milestones/delete_milestone_dialog.dart';
import '../widgets/tasks/direct_goal_tasks_section.dart';
import '../widgets/goals/goal_header.dart';
import '../widgets/milestones/milestone_dialog.dart';
import '../widgets/milestones/milestones_section.dart';
import '../widgets/milestones/move_task_to_milestone_dialog.dart';
import '../widgets/tasks/task_dialog.dart';
import '../app/app_dialogs.dart';

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
  });

  final Goal goal;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
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

  Future<void> _showAddTaskDialog(
    BuildContext context, {
    String? milestoneId,
  }) async {
    final result = await showDialog<TaskDraft>(
      context: context,
      builder: (context) {
        return const TaskDialog();
      },
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();

    final task = PlannerTask(
      id: 'task_${now.microsecondsSinceEpoch}',
      goalId: goal.id,
      milestoneId: milestoneId,
      title: result.title,
      description: result.description,
      createdAt: now,
    );

    onTaskCreated(task);
  }

  Future<void> _showEditTaskDialog(
    BuildContext context,
    PlannerTask task,
  ) async {
    final result = await showDialog<TaskDraft>(
      context: context,
      builder: (context) {
        return TaskDialog(
          initialTitle: task.title,
          initialDescription: task.description,
          title: 'Edit task',
          submitLabel: 'Save',
        );
      },
    );

    if (result == null) {
      return;
    }

    onTaskUpdated(
      taskId: task.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showMoveTaskToMilestoneDialog(
    BuildContext context,
    PlannerTask task,
  ) async {
    final view = _viewBuilder.build(
      goal: goal,
      milestones: milestones,
      tasks: tasks,
    );
    final result = await showDialog<Milestone>(
      context: context,
      builder: (context) {
        return MoveTaskToMilestoneDialog(milestones: view.goalMilestones);
      },
    );

    if (result == null) {
      return;
    }

    onTaskAssignedToMilestone(taskId: task.id, milestoneId: result.id);
  }

  Future<void> _showScheduleTaskDatePicker(
    BuildContext context,
    PlannerTask task,
  ) async {
    final selectedDate = await showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    onScheduleTaskForDate(taskId: task.id, scheduledDate: selectedDate);
  }

  Future<void> _showAddMilestoneDialog(BuildContext context) async {
    final result = await showDialog<MilestoneDraft>(
      context: context,
      builder: (context) {
        return const MilestoneDialog();
      },
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();

    final milestone = Milestone(
      id: 'milestone_${now.microsecondsSinceEpoch}',
      goalId: goal.id,
      title: result.title,
      description: result.description,
      createdAt: now,
    );

    onMilestoneCreated(milestone);
  }

  Future<void> _showEditMilestoneDialog(
    BuildContext context,
    Milestone milestone,
  ) async {
    final result = await showDialog<MilestoneDraft>(
      context: context,
      builder: (context) {
        return MilestoneDialog(
          initialTitle: milestone.title,
          initialDescription: milestone.description,
          title: 'Edit milestone',
          submitLabel: 'Save',
        );
      },
    );

    if (result == null) {
      return;
    }

    onMilestoneUpdated(
      milestoneId: milestone.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showDeleteMilestoneDialog(
    BuildContext context,
    Milestone milestone,
  ) async {
    final view = _viewBuilder.build(
      goal: goal,
      milestones: milestones,
      tasks: tasks,
    );

    final milestoneTasks = view.tasksForMilestone(milestone.id);

    final result = await showDialog<DeleteMilestoneAction>(
      context: context,
      builder: (context) {
        return DeleteMilestoneDialog(
          milestoneTitle: milestone.title,
          taskCount: milestoneTasks.length,
        );
      },
    );

    if (result == null) {
      return;
    }

    switch (result) {
      case DeleteMilestoneAction.moveTasksToDirect:
        onMilestoneDeletedAndTasksMovedToDirect(milestone.id);
      case DeleteMilestoneAction.deleteTasks:
        onMilestoneDeletedWithTasks(milestone.id);
    }
  }

  void _toggleTaskCompletedWithDateFlow(
    BuildContext context,
    PlannerTask task,
  ) {
    handleTaskCompletionWithDateFlow(
      context,
      task: task,
      onToggleTaskCompleted: onToggleTaskCompleted,
      onCompleteTaskOnDate: onCompleteTaskOnDate,
    );
  }

  @override
  Widget build(BuildContext context) {
    final view = _viewBuilder.build(
      goal: goal,
      milestones: milestones,
      tasks: tasks,
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
            onAddMilestone: () => _showAddMilestoneDialog(context),
            onEditMilestone: (milestone) {
              _showEditMilestoneDialog(context, milestone);
            },
            onDeleteMilestone: (milestone) {
              _showDeleteMilestoneDialog(context, milestone);
            },
            onAddTaskToMilestone: (milestoneId) {
              _showAddTaskDialog(context, milestoneId: milestoneId);
            },
            onToggleTaskCompleted: (task) {
              _toggleTaskCompletedWithDateFlow(context, task);
            },
            onEditTask: (task) {
              _showEditTaskDialog(context, task);
            },
            onMoveTaskToDirectGoal: onTaskMovedToDirectGoal,
            onScheduleTaskForToday: onScheduleTaskForToday,
            onScheduleTaskForDate: (task) {
              _showScheduleTaskDatePicker(context, task);
            },
            onDeleteTask: onDeleteTask,
          ),
          const SizedBox(height: 16),
          DirectGoalTasksSection(
            goal: goal,
            tasks: view.directGoalTasks,
            onAddTask: () => _showAddTaskDialog(context),
            onToggleTaskCompleted: (task) {
              _toggleTaskCompletedWithDateFlow(context, task);
            },
            onEditTask: (task) {
              _showEditTaskDialog(context, task);
            },
            onMoveTaskToMilestone: (task) {
              _showMoveTaskToMilestoneDialog(context, task);
            },
            onScheduleTaskForToday: onScheduleTaskForToday,
            onScheduleTaskForDate: (task) {
              _showScheduleTaskDatePicker(context, task);
            },
            onDeleteTask: onDeleteTask,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
