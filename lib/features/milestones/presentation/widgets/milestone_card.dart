import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/milestone.dart';
import '../../../../models/planner_task.dart';
import '../../../../models/recurring_task_rule.dart';
import '../../../recurring/presentation/widgets/recurring_task_rule_card.dart';
import '../../../tasks/presentation/widgets/task_card.dart';

class MilestoneCard extends StatelessWidget {
  const MilestoneCard({
    super.key,
    required this.goal,
    required this.milestone,
    required this.tasks,
    required this.recurringRules,
    required this.onAddTask,
    required this.onAddRecurringTask,
    required this.onRecurringRuleActiveChanged,
    required this.onEditRecurringRule,
    required this.onDeleteRecurringRule,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onMoveTaskToDirectGoal,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onEditTaskReminder,
    required this.onDeleteTask,
  });

  final Goal goal;
  final Milestone milestone;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final VoidCallback onAddTask;
  final VoidCallback onAddRecurringTask;
  final void Function(RecurringTaskRule rule, bool isActive)
  onRecurringRuleActiveChanged;
  final ValueChanged<RecurringTaskRule> onEditRecurringRule;
  final ValueChanged<RecurringTaskRule> onDeleteRecurringRule;
  final VoidCallback onEditMilestone;
  final VoidCallback onDeleteMilestone;
  final void Function(PlannerTask task) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onMoveTaskToDirectGoal;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function(PlannerTask task) onScheduleTaskForDate;
  final void Function(PlannerTask task) onEditTaskReminder;
  final void Function(String taskId) onDeleteTask;

  bool _canEditReminder(PlannerTask task) {
    return task.scheduledDate != null &&
        task.scheduledTimeMinutes != null &&
        task.recurringRuleId == null;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final completedTasks = tasks.where((task) => task.isCompleted).length;
    final progressText = tasks.isEmpty
        ? l10n.milestoneCardNoTasksYet
        : l10n.milestoneCardTasksCompleted(completedTasks, tasks.length);

    return Card(
      child: ExpansionTile(
        initiallyExpanded: true,
        title: Text(milestone.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (milestone.description.isNotEmpty) Text(milestone.description),
            const SizedBox(height: 4),
            Text(progressText, style: Theme.of(context).textTheme.bodySmall),
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
            return [
              PopupMenuItem(
                value: _MilestoneAction.edit,
                child: Text(l10n.commonEdit),
              ),
              PopupMenuItem(
                value: _MilestoneAction.delete,
                child: Text(l10n.commonDelete),
              ),
            ];
          },
        ),
        children: [
          if (recurringRules.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.milestoneCardRecurringTasksSection,
                  style: Theme.of(context).textTheme.titleSmall,
                ),
              ),
            ),
            ...recurringRules.map(
              (rule) => Padding(
                padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
                child: RecurringTaskRuleCard(
                  rule: rule,
                  onActiveChanged: (isActive) {
                    onRecurringRuleActiveChanged(rule, isActive);
                  },
                  onEdit: () {
                    onEditRecurringRule(rule);
                  },
                  onDelete: () {
                    onDeleteRecurringRule(rule);
                  },
                ),
              ),
            ),
          ],
          if (tasks.isEmpty)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  l10n.milestoneCardNoTasksInMilestone,
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
                  onToggleCompleted: () => onToggleTaskCompleted(task),
                  onEdit: () => onEditTask(task),
                  onMoveToDirectGoal: () => onMoveTaskToDirectGoal(task.id),
                  onScheduleForToday: () => onScheduleTaskForToday(task.id),
                  onScheduleDate: () {
                    onScheduleTaskForDate(task);
                  },
                  onEditReminder: _canEditReminder(task)
                      ? () => onEditTaskReminder(task)
                      : null,
                  onDelete: () => onDeleteTask(task.id),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Wrap(
                spacing: 8,
                runSpacing: 4,
                children: [
                  TextButton.icon(
                    onPressed: onAddTask,
                    icon: const Icon(Icons.add),
                    label: Text(l10n.milestoneCardAddTaskButton),
                  ),
                  TextButton.icon(
                    onPressed: onAddRecurringTask,
                    icon: const Icon(Icons.repeat),
                    label: Text(l10n.milestoneCardAddRecurringButton),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum _MilestoneAction { edit, delete }
