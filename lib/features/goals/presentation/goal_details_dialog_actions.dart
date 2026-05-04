import 'package:flutter/material.dart';

import '../../tasks/presentation/task_date_dialogs.dart' as task_date_dialogs;
import '../../tasks/presentation/task_dialogs.dart' as task_dialogs;
import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../milestones/presentation/widgets/delete_milestone_dialog.dart';
import '../../milestones/presentation/widgets/milestone_dialog.dart';
import '../../milestones/presentation/widgets/move_task_to_milestone_dialog.dart';

class GoalDetailsDialogActions {
  const GoalDetailsDialogActions();

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
    final result = await showDialog<Milestone>(
      context: context,
      builder: (context) {
        return MoveTaskToMilestoneDialog(milestones: milestones);
      },
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
  }) async {
    final selectedDate = await task_date_dialogs.showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    onScheduleTaskForDate(taskId: task.id, scheduledDate: selectedDate);
  }

  Future<void> showAddMilestoneDialog(
    BuildContext context, {
    required Goal goal,
    required void Function(Milestone milestone) onMilestoneCreated,
  }) async {
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

  Future<void> showDeleteMilestoneDialog(
    BuildContext context, {
    required Milestone milestone,
    required int taskCount,
    required void Function(String milestoneId) onMoveTasksToDirect,
    required void Function(String milestoneId) onDeleteTasks,
  }) async {
    final result = await showDialog<DeleteMilestoneAction>(
      context: context,
      builder: (context) {
        return DeleteMilestoneDialog(
          milestoneTitle: milestone.title,
          taskCount: taskCount,
        );
      },
    );

    if (result == null) {
      return;
    }

    switch (result) {
      case DeleteMilestoneAction.moveTasksToDirect:
        onMoveTasksToDirect(milestone.id);
      case DeleteMilestoneAction.deleteTasks:
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
