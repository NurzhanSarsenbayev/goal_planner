import 'package:flutter/material.dart';

import '../models/goal.dart';
import '../models/milestone.dart';
import '../models/planner_task.dart';
import 'task_card.dart';

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    super.key,
    required this.goal,
    required this.milestone,
    required this.tasks,
    required this.onAddTask,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onMoveTaskToDirectGoal,
    required this.onScheduleTaskForToday,
    required this.onDeleteTask,
  });

  final Goal goal;
  final Milestone milestone;
  final List<PlannerTask> tasks;
  final VoidCallback onAddTask;
  final VoidCallback onEditMilestone;
  final VoidCallback onDeleteMilestone;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onMoveTaskToDirectGoal;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final progressText = tasks.isEmpty
        ? 'No tasks yet'
        : '$completedTasks / ${tasks.length} tasks completed';

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(milestone.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (milestone.description.isNotEmpty) Text(milestone.description),
            const SizedBox(height: 4),
            Text(
              progressText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        trailing: PopupMenuButton<_MilestoneAction>(
          onSelected: (action) {
            switch (action) {
              case _MilestoneAction.edit:
                onEditMilestone();
              case _MilestoneAction.delete:
                onDeleteMilestone();
            }
          },
          itemBuilder: (context) {
            return const [
              PopupMenuItem(
                value: _MilestoneAction.edit,
                child: Text('Edit'),
              ),
              PopupMenuItem(
                value: _MilestoneAction.delete,
                child: Text('Delete'),
              ),
            ];
          },
        ),
        children: [
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'No tasks in this milestone yet.',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          else
            ...tasks.map(
                  (task) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: TaskCard(
                  task: task,
                  goal: goal,
                  onToggleCompleted: () => onToggleTaskCompleted(task.id),
                  onEdit: () => onEditTask(task),
                  onMoveToDirectGoal: () => onMoveTaskToDirectGoal(task.id),
                  onScheduleForToday: () => onScheduleTaskForToday(task.id),
                  onDelete: () => onDeleteTask(task.id),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: TextButton.icon(
                onPressed: onAddTask,
                icon: const Icon(Icons.add),
                label: const Text('Add task'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneAction {
  edit,
  delete,
}