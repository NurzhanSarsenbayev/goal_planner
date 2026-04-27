import 'package:flutter/material.dart';

import '../controllers/all_tasks_controller.dart';
import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/common/placeholder_screen.dart';
import '../widgets/tasks/task_card.dart';
import '../widgets/tasks/task_dialog.dart';
import '../widgets/tasks/task_placement_dialog.dart';
import '../app/app_dialogs.dart';

class AllTasksScreen extends StatefulWidget {
  const AllTasksScreen({
    super.key,
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskUpdated,
    required this.onTaskAttachedToGoal,
    required this.onTaskDetachedFromGoal,
    required this.onDeleteTask,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onCompleteTaskOnDate,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;

  final void Function({
    required String taskId,
    required String title,
    required String description,
  })
  onTaskUpdated;

  final void Function({
    required String taskId,
    required String goalId,
    String? milestoneId,
  })
  onTaskAttachedToGoal;

  final void Function(String taskId) onTaskDetachedFromGoal;
  final void Function(String taskId) onDeleteTask;

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  late final AllTasksController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AllTasksController(
      tasks: widget.tasks,
      onToggleTaskCompleted: widget.onToggleTaskCompleted,
      onTaskUpdated: widget.onTaskUpdated,
      onTaskAttachedToGoal: widget.onTaskAttachedToGoal,
      onTaskDetachedFromGoal: widget.onTaskDetachedFromGoal,
      onDeleteTask: widget.onDeleteTask,
      onScheduleTaskForToday: widget.onScheduleTaskForToday,
      onScheduleTaskForDate: widget.onScheduleTaskForDate,
      onCompleteTaskOnDate: widget.onCompleteTaskOnDate,
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

  Future<void> _showAttachTaskToGoalDialog(PlannerTask task) async {
    final result = await showDialog<TaskPlacementDraft>(
      context: context,
      builder: (context) {
        return TaskPlacementDialog(
          goals: widget.goals,
          milestones: widget.milestones,
        );
      },
    );

    if (result == null) {
      return;
    }

    _controller.attachTaskToGoal(
      taskId: task.id,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
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

  @override
  Widget build(BuildContext context) {
    final tasks = _controller.tasks;

    if (tasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: const Text('All tasks')),
        body: const PlaceholderScreen(
          title: 'All tasks',
          description: 'No tasks created yet.',
          icon: Icons.task_alt,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text('All tasks')),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = tasks[index];
          final goal = _findGoalById(task.goalId);
          final isStandaloneTask = task.goalId == null;
          final isGoalLinkedTask = task.goalId != null;

          return TaskCard(
            task: task,
            goal: goal,
            onToggleCompleted: () {
              handleTaskCompletionWithDateFlow(
                context,
                task: task,
                onToggleTaskCompleted: _controller.toggleTaskCompleted,
                onCompleteTaskOnDate: _controller.completeTaskOnDate,
              );
            },
            onEdit: () {
              _showEditTaskDialog(task);
            },
            onAttachToGoal: isStandaloneTask
                ? () {
                    _showAttachTaskToGoalDialog(task);
                  }
                : null,
            onDetachFromGoal: isGoalLinkedTask
                ? () {
                    _controller.detachTaskFromGoal(task.id);
                  }
                : null,
            onScheduleForToday: task.isScheduledForToday
                ? null
                : () {
                    _controller.scheduleTaskForToday(task.id);
                  },
            onScheduleDate: () {
              _showScheduleTaskDatePicker(task);
            },
            onDelete: () {
              _controller.deleteTask(task.id);
            },
          );
        },
      ),
    );
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in widget.goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}
