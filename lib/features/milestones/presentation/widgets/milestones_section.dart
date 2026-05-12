import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/recurring_task_rule.dart';
import '../../../../models/milestone.dart';
import '../../../../models/planner_task.dart';
import '../../../../shared/presentation/widgets/placeholder_screen.dart';
import '../../../../shared/presentation/widgets/section_header.dart';
import 'milestone_card.dart';

class MilestonesSection extends StatelessWidget {
  const MilestonesSection({
    super.key,
    required this.goal,
    required this.milestones,
    required this.goalTasks,
    required this.recurringRulesByMilestoneId,
    required this.onAddMilestone,
    required this.onEditMilestone,
    required this.onDeleteMilestone,
    required this.onAddTaskToMilestone,
    required this.onAddRecurringTaskToMilestone,
    required this.onRecurringRuleActiveChanged,
    required this.onEditRecurringRule,
    required this.onDeleteRecurringRule,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onMoveTaskToDirectGoal,
    required this.onScheduleTaskForToday,
    required this.onScheduleTaskForDate,
    required this.onDeleteTask,
  });

  final Goal goal;
  final List<Milestone> milestones;
  final List<PlannerTask> goalTasks;
  final Map<String, List<RecurringTaskRule>> recurringRulesByMilestoneId;
  final VoidCallback onAddMilestone;
  final void Function(Milestone milestone) onEditMilestone;
  final void Function(Milestone milestone) onDeleteMilestone;
  final void Function(String milestoneId) onAddTaskToMilestone;
  final void Function(String milestoneId) onAddRecurringTaskToMilestone;
  final void Function(RecurringTaskRule rule, bool isActive)
  onRecurringRuleActiveChanged;
  final ValueChanged<RecurringTaskRule> onEditRecurringRule;
  final ValueChanged<RecurringTaskRule> onDeleteRecurringRule;
  final void Function(PlannerTask task) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function(String taskId) onMoveTaskToDirectGoal;
  final void Function(String taskId) onScheduleTaskForToday;
  final void Function(PlannerTask task) onScheduleTaskForDate;
  final void Function(String taskId) onDeleteTask;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionHeader(
          title: l10n.milestonesSectionTitle,
          actionLabel: l10n.milestonesAddButton,
          onActionPressed: onAddMilestone,
        ),
        const SizedBox(height: 8),
        if (milestones.isEmpty)
          PlaceholderScreen(
            title: l10n.milestonesEmptyTitle,
            description: l10n.milestonesEmptyDescription,
            icon: Icons.account_tree_outlined,
          )
        else
          ...milestones.map((milestone) {
            final milestoneTasks = goalTasks
                .where((task) => task.milestoneId == milestone.id)
                .toList();
            final milestoneRecurringRules =
                recurringRulesByMilestoneId[milestone.id] ??
                const <RecurringTaskRule>[];

            return Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: MilestoneCard(
                goal: goal,
                milestone: milestone,
                tasks: milestoneTasks,
                recurringRules: milestoneRecurringRules,
                onAddTask: () => onAddTaskToMilestone(milestone.id),
                onAddRecurringTask: () =>
                    onAddRecurringTaskToMilestone(milestone.id),
                onRecurringRuleActiveChanged: onRecurringRuleActiveChanged,
                onEditRecurringRule: onEditRecurringRule,
                onDeleteRecurringRule: onDeleteRecurringRule,
                onEditMilestone: () => onEditMilestone(milestone),
                onDeleteMilestone: () => onDeleteMilestone(milestone),
                onToggleTaskCompleted: onToggleTaskCompleted,
                onEditTask: onEditTask,
                onMoveTaskToDirectGoal: onMoveTaskToDirectGoal,
                onScheduleTaskForToday: onScheduleTaskForToday,
                onScheduleTaskForDate: onScheduleTaskForDate,
                onDeleteTask: onDeleteTask,
              ),
            );
          }),
      ],
    );
  }
}
