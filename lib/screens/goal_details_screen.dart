import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/add_milestone_dialog.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/goal_header.dart';
import '../widgets/milestones_section.dart';
import '../widgets/direct_goal_tasks_section.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.milestones,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskCreated,
    required this.onDeleteTask,
    required this.onMilestoneCreated,
    required this.onScheduleTaskForToday,
  });

  final Goal goal;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onTaskCreated;
  final void Function(String taskId) onDeleteTask;
  final void Function(Milestone milestone) onMilestoneCreated;
  final void Function(String taskId) onScheduleTaskForToday;

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
  late List<Milestone> _milestones;
  late List<PlannerTask> _tasks;

  @override
  void initState() {
    super.initState();
    _milestones = List.of(widget.milestones);
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

  void _scheduleTaskForToday(String taskId) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        return task.scheduledToday();
      }).toList();
    });

    widget.onScheduleTaskForToday(taskId);
  }

  void _createTask({
    required String title,
    required String description,
    String? milestoneId,
  }) {
    final now = DateTime.now();

    final task = PlannerTask(
      id: 'task_${now.microsecondsSinceEpoch}',
      goalId: widget.goal.id,
      milestoneId: milestoneId,
      title: title,
      description: description,
      createdAt: now,
    );

    setState(() {
      _tasks = [..._tasks, task];
    });

    widget.onTaskCreated(task);
  }

  Future<void> _showAddTaskDialog({String? milestoneId}) async {
    final result = await showDialog<TaskDraft>(
      context: context,
      builder: (context) {
        return const AddTaskDialog();
      },
    );

    if (result == null) {
      return;
    }

    _createTask(
      title: result.title,
      description: result.description,
      milestoneId: milestoneId,
    );
  }

  Future<void> _showAddMilestoneDialog() async {
    final result = await showDialog<MilestoneDraft>(
      context: context,
      builder: (context) {
        return const AddMilestoneDialog();
      },
    );

    if (result == null) {
      return;
    }

    final now = DateTime.now();

    final milestone = Milestone(
      id: 'milestone_${now.microsecondsSinceEpoch}',
      goalId: widget.goal.id,
      title: result.title,
      description: result.description,
      createdAt: now,
    );

    setState(() {
      _milestones = [..._milestones, milestone];
    });

    widget.onMilestoneCreated(milestone);
  }

  @override
  Widget build(BuildContext context) {
    final goalTasks = _tasks
        .where((task) => task.goalId == widget.goal.id)
        .toList();

    final goalMilestones = _milestones
        .where((milestone) => milestone.goalId == widget.goal.id)
        .toList();

    final milestoneIds = goalMilestones.map((milestone) => milestone.id).toSet();

    final directGoalTasks = goalTasks
        .where(
          (task) =>
              task.milestoneId == null ||
              !milestoneIds.contains(task.milestoneId),
        )
        .toList();

    final completedTasks = goalTasks.where((task) => task.isCompleted).length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          GoalHeader(
            goal: widget.goal,
            totalTasks: goalTasks.length,
            completedTasks: completedTasks,
          ),
          const SizedBox(height: 16),
          MilestonesSection(
            goal: widget.goal,
            milestones: goalMilestones,
            goalTasks: goalTasks,
            onAddMilestone: _showAddMilestoneDialog,
            onAddTaskToMilestone: (milestoneId) {
              _showAddTaskDialog(milestoneId: milestoneId);
            },
            onToggleTaskCompleted: _toggleTaskCompleted,
            onScheduleTaskForToday: _scheduleTaskForToday,
            onDeleteTask: _deleteTask,
          ),
          const SizedBox(height: 16),
          DirectGoalTasksSection(
            goal: widget.goal,
            tasks: directGoalTasks,
            onAddTask: _showAddTaskDialog,
            onToggleTaskCompleted: _toggleTaskCompleted,
            onScheduleTaskForToday: _scheduleTaskForToday,
            onDeleteTask: _deleteTask,
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}