import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class GoalDetailsScreen extends StatefulWidget {
  const GoalDetailsScreen({
    super.key,
    required this.goal,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onTaskCreated,
  });

  final Goal goal;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onTaskCreated;

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
    final result = await showDialog<_TaskDraft>(
      context: context,
      builder: (context) {
        return const _AddTaskDialog();
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
          _GoalHeader(
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
                ),
              ),
            ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}

class _AddTaskDialog extends StatefulWidget {
  const _AddTaskDialog();

  @override
  State<_AddTaskDialog> createState() => _AddTaskDialogState();
}

class _AddTaskDialogState extends State<_AddTaskDialog> {
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _submit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();

    if (title.isEmpty) {
      return;
    }

    Navigator.of(context).pop(
      _TaskDraft(
        title: title,
        description: description,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add task'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _titleController,
            autofocus: true,
            decoration: const InputDecoration(
              labelText: 'Title',
              hintText: 'e.g. Write post outline',
            ),
            textInputAction: TextInputAction.next,
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descriptionController,
            decoration: const InputDecoration(
              labelText: 'Description',
              hintText: 'Optional',
            ),
            minLines: 1,
            maxLines: 3,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text('Add'),
        ),
      ],
    );
  }
}

class _TaskDraft {
  const _TaskDraft({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}

class _GoalHeader extends StatelessWidget {
  const _GoalHeader({
    required this.goal,
    required this.totalTasks,
    required this.completedTasks,
  });

  final Goal goal;
  final int totalTasks;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    final progressText = totalTasks == 0
        ? 'No tasks yet'
        : '$completedTasks / $totalTasks tasks completed';

    final progressValue = totalTasks == 0 ? 0.0 : completedTasks / totalTasks;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(goal.title, style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            if (goal.description.isNotEmpty)
              Text(
                goal.description,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            const SizedBox(height: 16),
            LinearProgressIndicator(value: progressValue),
            const SizedBox(height: 8),
            Text(
              progressText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}