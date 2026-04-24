import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import '../widgets/add_milestone_dialog.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/goal_header.dart';
import '../widgets/milestone_card.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.milestones,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskCreated,
    required this.onMilestoneCreated,
    required this.onScheduleTaskForToday,
  });

  final Goal goal;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onTaskCreated;
  final void Function({
    required String goalId,
    required String title,
    required String description,
  }) onMilestoneCreated;
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

    widget.onMilestoneCreated(
      goalId: widget.goal.id,
      title: result.title,
      description: result.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalTasks =
        _tasks.where((task) => task.goalId == widget.goal.id).toList();

    final goalMilestones =
        _milestones.where((milestone) => milestone.goalId == widget.goal.id).toList();

    final milestoneIds = goalMilestones.map((milestone) => milestone.id).toSet();

    final ungroupedTasks = goalTasks
        .where((task) => task.milestoneId == null || !milestoneIds.contains(task.milestoneId))
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
          _SectionHeader(
            title: 'Milestones',
            actionLabel: 'Add milestone',
            onActionPressed: _showAddMilestoneDialog,
          ),
          const SizedBox(height: 8),
          if (goalMilestones.isEmpty)
            const PlaceholderScreen(
              title: 'No milestones yet',
              description: 'Add milestones to group tasks inside this goal.',
              icon: Icons.account_tree_outlined,
            )
          else
            ...goalMilestones.map((milestone) {
              final milestoneTasks = goalTasks
                  .where((task) => task.milestoneId == milestone.id)
                  .toList();

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: MilestoneCard(
                  goal: widget.goal,
                  milestone: milestone,
                  tasks: milestoneTasks,
                  onAddTask: () => _showAddTaskDialog(milestoneId: milestone.id),
                  onToggleTaskCompleted: _toggleTaskCompleted,
                  onScheduleTaskForToday: _scheduleTaskForToday,
                ),
              );
            }),
          const SizedBox(height: 16),
          _SectionHeader(
            title: 'Ungrouped tasks',
            actionLabel: 'Add task',
            onActionPressed: () => _showAddTaskDialog(),
          ),
          const SizedBox(height: 8),
          if (ungroupedTasks.isEmpty)
            Text(
              'No ungrouped tasks.',
              style: Theme.of(context).textTheme.bodySmall,
            )
          else
            ...ungroupedTasks.map(
              (task) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: TaskCard(
                  task: task,
                  goal: widget.goal,
                  onToggleCompleted: () => _toggleTaskCompleted(task.id),
                  onScheduleForToday: () => _scheduleTaskForToday(task.id),
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.title,
    required this.actionLabel,
    required this.onActionPressed,
  });

  final String title;
  final String actionLabel;
  final VoidCallback onActionPressed;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ),
        TextButton.icon(
          onPressed: onActionPressed,
          icon: const Icon(Icons.add),
          label: Text(actionLabel),
        ),
      ],
    );
  }
}