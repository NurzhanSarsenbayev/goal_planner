import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/goals/application/goal_details_view_builder.dart';
import 'package:goal_planner/models/goal.dart';
import 'package:goal_planner/models/milestone.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('GoalDetailsViewBuilder', () {
    test('excludes recurring occurrences from direct goal tasks', () {
      final goal = _goal(id: 'goal-1');

      final view = const GoalDetailsViewBuilder().build(
        goal: goal,
        milestones: const [],
        tasks: [
          _task(id: 'direct-task', goalId: goal.id),
          _task(
            id: 'recurring-occurrence',
            goalId: goal.id,
            recurringRuleId: 'rule-1',
          ),
        ],
        recurringRules: const [],
      );

      expect(view.goalTasks.map((task) => task.id), ['direct-task']);
      expect(view.directGoalTasks.map((task) => task.id), ['direct-task']);
    });

    test('excludes recurring occurrences from milestone task lists', () {
      final goal = _goal(id: 'goal-1');
      final milestone = _milestone(id: 'milestone-1', goalId: goal.id);

      final view = const GoalDetailsViewBuilder().build(
        goal: goal,
        milestones: [milestone],
        tasks: [
          _task(
            id: 'milestone-task',
            goalId: goal.id,
            milestoneId: milestone.id,
          ),
          _task(
            id: 'recurring-milestone-occurrence',
            goalId: goal.id,
            milestoneId: milestone.id,
            recurringRuleId: 'rule-1',
          ),
        ],
        recurringRules: const [],
      );

      expect(view.tasksForMilestone(milestone.id).map((task) => task.id), [
        'milestone-task',
      ]);
    });

    test('does not count completed recurring occurrences in goal progress', () {
      final goal = _goal(id: 'goal-1');

      final view = const GoalDetailsViewBuilder().build(
        goal: goal,
        milestones: const [],
        tasks: [
          _task(
            id: 'completed-direct-task',
            goalId: goal.id,
            isCompleted: true,
          ),
          _task(
            id: 'completed-recurring-occurrence',
            goalId: goal.id,
            recurringRuleId: 'rule-1',
            isCompleted: true,
          ),
        ],
        recurringRules: const [],
      );

      expect(view.completedTasks, 1);
      expect(view.goalTasks.length, 1);
    });

    test('includes recurring rules linked to the goal', () {
      final goal = _goal(id: 'goal-1');

      final view = const GoalDetailsViewBuilder().build(
        goal: goal,
        milestones: const [],
        tasks: const [],
        recurringRules: [
          _recurringRule(id: 'goal-rule', goalId: goal.id),
          _recurringRule(
            id: 'milestone-rule',
            goalId: goal.id,
            milestoneId: 'm1',
          ),
          _recurringRule(id: 'other-goal-rule', goalId: 'other-goal'),
          _recurringRule(id: 'standalone-rule'),
        ],
      );

      expect(view.goalRecurringRules.map((rule) => rule.id), [
        'goal-rule',
        'milestone-rule',
      ]);
    });
  });
}

Goal _goal({required String id}) {
  return Goal(
    id: id,
    title: id,
    description: '',
    status: GoalStatus.active,
    createdAt: DateTime(2026, 5, 1),
  );
}

Milestone _milestone({required String id, required String goalId}) {
  return Milestone(
    id: id,
    goalId: goalId,
    title: id,
    description: '',
    createdAt: DateTime(2026, 5, 1),
  );
}

PlannerTask _task({
  required String id,
  String? goalId,
  String? milestoneId,
  String? recurringRuleId,
  bool isCompleted = false,
}) {
  return PlannerTask(
    id: id,
    title: id,
    description: '',
    goalId: goalId,
    milestoneId: milestoneId,
    recurringRuleId: recurringRuleId,
    isCompleted: isCompleted,
    createdAt: DateTime(2026, 5, 1),
  );
}

RecurringTaskRule _recurringRule({
  required String id,
  String? goalId,
  String? milestoneId,
}) {
  return RecurringTaskRule(
    id: id,
    title: id,
    description: '',
    goalId: goalId,
    milestoneId: milestoneId,
    recurrenceType: RecurrenceType.weekly,
    weekdays: const [DateTime.monday],
    monthDay: null,
    startDate: DateTime(2026, 5, 1),
    createdAt: DateTime(2026, 5, 1),
  );
}
