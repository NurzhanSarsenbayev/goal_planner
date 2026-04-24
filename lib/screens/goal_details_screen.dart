import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/add_task_dialog.dart';
import '../widgets/goal_header.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskCreated,
    required this.onScheduleTaskForToday,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onTaskCreated;
  final void Function(String taskId) onScheduleTaskForToday;

  @override
  State<GoalDetailsScreen> createState() => _GoalDetailsScreenState();
}

class _GoalDetailsScreenState extends State<GoalDetailsScreen> {
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

        final nextCompletedState = !task.isCompleted;

        return task.copyWith(
          isCompleted: nextCompletedState,
          completedAt: nextCompletedState ? DateTime.now() : null,
        );
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
  }) {
    final now = DateTime.now();

    final task = PlannerTask(
      id: 'task_${now.microsecondsSinceEpoch}',
      goalId: widget.goal.id,
      title: title,
      description: description,
      createdAt: now,
    );

    setState(() {
      _tasks = [..._tasks, task];
    });

    widget.onTaskCreated(task);
  }

  Future<void> _showAddTaskDialog() async {
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
    );
  }

  @override
  Widget build(BuildContext context) {
    final goalTasks = _tasks
        .where((task) => task.goalId == widget.goal.id)
        .toList();

    final completedTasks = goalTasks
        .where((task) => task.isCompleted)
        .length;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.goal.title),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddTaskDialog,
        icon: const Icon(Icons.add),
        label: const Text('Add task'),
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
          Text(
            'Tasks',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          if (goalTasks.isEmpty)
            const PlaceholderScreen(
              title: 'No tasks yet',
              description: 'Tasks connected to this goal will appear here.',
              icon: Icons.task_alt,
            )
          else
            ...goalTasks.map(
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