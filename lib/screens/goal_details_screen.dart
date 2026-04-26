import 'package:flutter/material.dart';

import '../controllers/goal_details_controller.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/delete_milestone_dialog.dart';
import '../widgets/direct_goal_tasks_section.dart';
import '../widgets/goal_header.dart';
import '../widgets/milestone_dialog.dart';
import '../widgets/milestones_section.dart';
import '../widgets/move_task_to_milestone_dialog.dart';
import '../widgets/task_dialog.dart';
import '../app/app_dialogs.dart';

class GoalDetailsScreen extends StatefulWidget {
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
  }) onTaskUpdated;

  final void Function(String taskId) onTaskMovedToDirectGoal;

  final void Function({
  required String taskId,
  required String milestoneId,
  }) onTaskAssignedToMilestone;

  final void Function(Milestone milestone) onMilestoneCreated;

  final void Function({
  required String milestoneId,
  required String title,
  required String description,
  }) onMilestoneUpdated;

  final void Function(String milestoneId) onMilestoneDeletedAndTasksMovedToDirect;
  final void Function(String milestoneId) onMilestoneDeletedWithTasks;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function({
  required String taskId,
  required DateTime scheduledDate,
  }) onScheduleTaskForDate;

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late final GoalDetailsController _controller;

  @override
  void initState() {
    super.initState();

    _controller = GoalDetailsController(
      goal: widget.goal,
      milestones: widget.milestones,
      tasks: widget.tasks,
      onToggleTaskCompleted: widget.onToggleTaskCompleted,
      onTaskCreated: widget.onTaskCreated,
      onDeleteTask: widget.onDeleteTask,
      onTaskUpdated: widget.onTaskUpdated,
      onTaskMovedToDirectGoal: widget.onTaskMovedToDirectGoal,
      onTaskAssignedToMilestone: widget.onTaskAssignedToMilestone,
      onMilestoneCreated: widget.onMilestoneCreated,
      onMilestoneUpdated: widget.onMilestoneUpdated,
      onMilestoneDeletedAndTasksMovedToDirect:
      widget.onMilestoneDeletedAndTasksMovedToDirect,
      onMilestoneDeletedWithTasks: widget.onMilestoneDeletedWithTasks,
      onScheduleTaskForToday: widget.onScheduleTaskForToday,
      onScheduleTaskForDate: widget.onScheduleTaskForDate,
    );

    _controller.addListener(_onControllerChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _controller.dispose();
    super.dispose();
  }

  void _onControllerChanged() {
    setState(() {});
  }

  Future<void> _showAddTaskDialog({String? milestoneId}) async {
    final result = await showDialog<TaskDraft>(
      context: context,
      builder: (context) {
        return const TaskDialog();
      },
    );

    if (result == null) {
      return;
    }

    _controller.createTask(
      title: result.title,
      description: result.description,
      milestoneId: milestoneId,
    );
  }

  Future<void> _showEditTaskDialog(PlannerTask task) async {
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

    _controller.updateTask(
      taskId: task.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showMoveTaskToMilestoneDialog(PlannerTask task) async {
    final result = await showDialog<Milestone>(
      context: context,
      builder: (context) {
        return MoveTaskToMilestoneDialog(
          milestones: _controller.goalMilestones,
        );
      },
    );

    if (result == null) {
      return;
    }

    _controller.assignTaskToMilestone(
      taskId: task.id,
      milestoneId: result.id,
    );
  }

  Future<void> _showScheduleTaskDatePicker(PlannerTask task) async {
    final selectedDate = await showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    _controller.scheduleTaskForDate(
      taskId: task.id,
      scheduledDate: selectedDate,
    );
  }

  Future<void> _showAddMilestoneDialog() async {
    final result = await showDialog<MilestoneDraft>(
      context: context,
      builder: (context) {
        return const MilestoneDialog();
      },
    );

    if (result == null) {
      return;
    }

    _controller.createMilestone(
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showEditMilestoneDialog(Milestone milestone) async {
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

    _controller.updateMilestone(
      milestoneId: milestone.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showDeleteMilestoneDialog(Milestone milestone) async {
    final milestoneTasks = _controller.tasksForMilestone(milestone.id);

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
        _controller.deleteMilestoneAndMoveTasksToDirect(milestone.id);
      case DeleteMilestoneAction.deleteTasks:
        _controller.deleteMilestoneWithTasks(milestone.id);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GoalHeader(
            goal: widget.goal,
            totalTasks: _controller.goalTasks.length,
            completedTasks: _controller.completedTasks,
          ),
          const SizedBox(height: 16),
          MilestonesSection(
            goal: widget.goal,
            milestones: _controller.goalMilestones,
            goalTasks: _controller.goalTasks,
            onAddMilestone: _showAddMilestoneDialog,
            onEditMilestone: _showEditMilestoneDialog,
            onDeleteMilestone: _showDeleteMilestoneDialog,
            onAddTaskToMilestone: (milestoneId) {
              _showAddTaskDialog(milestoneId: milestoneId);
            },
            onToggleTaskCompleted: _controller.toggleTaskCompleted,
            onEditTask: _showEditTaskDialog,
            onMoveTaskToDirectGoal: _controller.moveTaskToDirectGoal,
            onScheduleTaskForToday: _controller.scheduleTaskForToday,
            onScheduleTaskForDate: _showScheduleTaskDatePicker,
            onDeleteTask: _controller.deleteTask,
          ),
          const SizedBox(height: 16),
          DirectGoalTasksSection(
            goal: widget.goal,
            tasks: _controller.directGoalTasks,
            onAddTask: _showAddTaskDialog,
            onToggleTaskCompleted: _controller.toggleTaskCompleted,
            onEditTask: _showEditTaskDialog,
            onMoveTaskToMilestone: _showMoveTaskToMilestoneDialog,
            onScheduleTaskForToday: _controller.scheduleTaskForToday,
            onScheduleTaskForDate: _showScheduleTaskDatePicker,
            onDeleteTask: _controller.deleteTask,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}