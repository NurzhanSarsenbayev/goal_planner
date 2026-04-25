import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';
import '../widgets/task_dialog.dart';
import '../widgets/task_placement_dialog.dart';

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
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function({
  required String taskId,
  required String title,
  required String description,
  }) onTaskUpdated;
  final void Function({
  required String taskId,
  required String goalId,
  String? milestoneId,
  }) onTaskAttachedToGoal;
  final void Function(String taskId) onTaskDetachedFromGoal;
  final void Function(String taskId) onDeleteTask;

  @override
  State<AllTasksScreen> createState() => _AllTasksScreenState();
}

class _AllTasksScreenState extends State<AllTasksScreen> {
  late List<PlannerTask> _tasks;

  @override
  void initState() {
    super.initState();
    _tasks = List.of(widget.tasks);
  }

  void _toggleTaskCompleted(String taskId) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        return task.toggleCompleted();
      }).toList();
    });

    widget.onToggleTaskCompleted(taskId);
  }

  void _deleteTask(String taskId) {
    setState(() {
      _tasks = _tasks.where((task) => task.id != taskId).toList();
    });

    widget.onDeleteTask(taskId);
  }

  void _updateTask({
    required String taskId,
    required String title,
    required String description,
  }) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        return task.copyWith(
          title: title,
          description: description,
        );
      }).toList();
    });

    widget.onTaskUpdated(
      taskId: taskId,
      title: title,
      description: description,
    );
  }

  void _attachTaskToGoal({
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        if (milestoneId == null) {
          return task.assignToGoal(goalId);
        }

        return task.assignToGoalMilestone(
          goalId: goalId,
          milestoneId: milestoneId,
        );
      }).toList();
    });

    widget.onTaskAttachedToGoal(
      taskId: taskId,
      goalId: goalId,
      milestoneId: milestoneId,
    );
  }

  void _detachTaskFromGoal(String taskId) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        return task.detachFromGoal();
      }).toList();
    });

    widget.onTaskDetachedFromGoal(taskId);
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

    _updateTask(
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

    _attachTaskToGoal(
      taskId: task.id,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_tasks.isEmpty) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('All tasks'),
        ),
        body: const PlaceholderScreen(
          title: 'All tasks',
          description: 'No tasks created yet.',
          icon: Icons.task_alt,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('All tasks'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: _tasks.length,
        separatorBuilder: (_, _) => const SizedBox(height: 8),
        itemBuilder: (context, index) {
          final task = _tasks[index];
          final goal = _findGoalById(task.goalId);
          final isStandaloneTask = task.goalId == null;
          final isGoalLinkedTask = task.goalId != null;

          return TaskCard(
            task: task,
            goal: goal,
            onToggleCompleted: () => _toggleTaskCompleted(task.id),
            onEdit: () => _showEditTaskDialog(task),
            onAttachToGoal:
            isStandaloneTask ? () => _showAttachTaskToGoalDialog(task) : null,
            onDetachFromGoal:
            isGoalLinkedTask ? () => _detachTaskFromGoal(task.id) : null,
            onDelete: () => _deleteTask(task.id),
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