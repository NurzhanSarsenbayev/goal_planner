import 'package:flutter/material.dart';

import '../../tasks/presentation/task_date_dialogs.dart' as task_date_dialogs;
import '../../tasks/presentation/task_schedule_dialog_actions.dart';
import '../../tasks/presentation/task_dialogs.dart' as task_dialogs;
import '../../milestones/presentation/milestone_dialogs.dart'
    as milestone_dialogs;
import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';

class GoalDetailsDialogActions {
  const GoalDetailsDialogActions();
  final TaskScheduleDialogActions _taskScheduleDialogActions =
      const TaskScheduleDialogActions();

  Future<void> showAddTaskDialog(
    BuildContext context, {
    required Goal goal,
    required void Function(PlannerTask task) onTaskCreated,
    String? milestoneId,
  }) async {
    final result = await task_dialogs.showAddTaskDialog(context);

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

  Future<void> showEditTaskDialog(
    BuildContext context, {
    required PlannerTask task,
    required void Function({
      required String taskId,
      required String title,
      required String description,
    })
    onTaskUpdated,
  }) async {
    final result = await task_dialogs.showEditTaskDialog(context, task: task);

    if (result == null) {
      return;
    }

    onTaskUpdated(
      taskId: task.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> showMoveTaskToMilestoneDialog(
    BuildContext context, {
    required PlannerTask task,
    required List<Milestone> milestones,
    required void Function({
      required String taskId,
      required String milestoneId,
    })
    onTaskAssignedToMilestone,
  }) async {
    final result = await milestone_dialogs.showMoveTaskToMilestoneDialog(
      context,
      milestones: milestones,
    );

    if (result == null) {
      return;
    }

    onTaskAssignedToMilestone(taskId: task.id, milestoneId: result.id);
  }

  Future<void> showScheduleTaskDatePicker(
    BuildContext context, {
    required PlannerTask task,
    required void Function({
      required String taskId,
      required DateTime scheduledDate,
    })
    onScheduleTaskForDate,
  }) {
    return _taskScheduleDialogActions.showScheduleDatePicker(
      context,
      task: task,
      onScheduleTaskForDate: onScheduleTaskForDate,
    );
  }

  Future<void> showTaskReminderPicker(
    BuildContext context, {
    required PlannerTask task,
    required void Function({
      required String taskId,
      required int? reminderMinutesBefore,
    })
    onUpdateTaskReminder,
  }) {
    return _taskScheduleDialogActions.showReminderPicker(
      context,
      task: task,
      onUpdateTaskReminder: onUpdateTaskReminder,
    );
  }

  Future<void> showAddMilestoneDialog(
    BuildContext context, {
    required Goal goal,
    required void Function(Milestone milestone) onMilestoneCreated,
  }) async {
    final result = await milestone_dialogs.showAddMilestoneDialog(context);

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

  Future<void> showEditMilestoneDialog(
    BuildContext context, {
    required Milestone milestone,
    required void Function({
      required String milestoneId,
      required String title,
      required String description,
    })
    onMilestoneUpdated,
  }) async {
    final result = await milestone_dialogs.showEditMilestoneDialog(
      context,
      milestone: milestone,
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

  Future<void> showDeleteMilestoneDialog(
    BuildContext context, {
    required Milestone milestone,
    required int taskCount,
    required void Function(String milestoneId) onMoveTasksToDirect,
    required void Function(String milestoneId) onDeleteTasks,
  }) async {
    final result = await milestone_dialogs.showDeleteMilestoneDialog(
      context,
      milestone: milestone,
      taskCount: taskCount,
    );

    if (result == null) {
      return;
    }

    switch (result) {
      case milestone_dialogs.DeleteMilestoneAction.moveTasksToDirect:
        onMoveTasksToDirect(milestone.id);
      case milestone_dialogs.DeleteMilestoneAction.deleteTasks:
        onDeleteTasks(milestone.id);
    }
  }

  void toggleTaskCompletedWithDateFlow(
    BuildContext context, {
    required PlannerTask task,
    required void Function(String taskId) onToggleTaskCompleted,
    required void Function({
      required String taskId,
      required DateTime completedAt,
    })
    onCompleteTaskOnDate,
  }) {
    task_date_dialogs.handleTaskCompletionWithDateFlow(
      context,
      task: task,
      onToggleTaskCompleted: onToggleTaskCompleted,
      onCompleteTaskOnDate: onCompleteTaskOnDate,
    );
  }
}
