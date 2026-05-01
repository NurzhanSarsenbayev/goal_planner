import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';
import 'package:goal_planner/recurring/recurring_rule_lifecycle.dart';

void main() {
  group('RecurringRuleLifecycle', () {
    final lifecycle = RecurringRuleLifecycle();
    final today = DateTime(2026, 5, 1);

    test('deactivates rule and removes unfinished occurrences', () {
      final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.friday]);

      final unfinishedOccurrence = _recurringTask(
        id: 'task-1',
        ruleId: rule.id,
        isCompleted: false,
      );

      final completedOccurrence = _recurringTask(
        id: 'task-2',
        ruleId: rule.id,
        isCompleted: true,
      );

      final regularTask = _regularTask(id: 'task-3');

      final result = lifecycle.deactivateRule(
        ruleId: rule.id,
        rules: [rule],
        tasks: [unfinishedOccurrence, completedOccurrence, regularTask],
        exceptions: [],
      );

      expect(result.ruleToPersist, isNotNull);
      expect(result.ruleToPersist!.isActive, isFalse);
      expect(result.rules.single.isActive, isFalse);
      expect(result.tasks, [completedOccurrence, regularTask]);
      expect(result.generatedTasks, isEmpty);
    });

    test('activates rule and generates upcoming occurrences', () {
      final rule = _weeklyRule(
        id: 'rule-1',
        weekdays: [DateTime.friday],
        isActive: false,
      );

      final result = lifecycle.activateRule(
        ruleId: rule.id,
        rules: [rule],
        tasks: [],
        exceptions: [],
        today: today,
      );

      expect(result.ruleToPersist, isNotNull);
      expect(result.ruleToPersist!.isActive, isTrue);
      expect(result.rules.single.isActive, isTrue);
      expect(result.generatedTasks, isNotEmpty);
      expect(result.tasks, result.generatedTasks);
      expect(
        result.generatedTasks.every((task) {
          return task.recurringRuleId == rule.id;
        }),
        isTrue,
      );
    });

    test(
      'deletes rule, removes unfinished occurrences, and keeps completed history',
      () {
        final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.friday]);

        final unfinishedOccurrence = _recurringTask(
          id: 'task-1',
          ruleId: rule.id,
          isCompleted: false,
        );

        final completedOccurrence = _recurringTask(
          id: 'task-2',
          ruleId: rule.id,
          isCompleted: true,
        );

        final regularTask = _regularTask(id: 'task-3');

        final exception = RecurringTaskException(
          id: 'exception-1',
          ruleId: rule.id,
          date: DateTime(2026, 5, 1),
          createdAt: DateTime(2026, 4, 30),
        );

        final result = lifecycle.deleteRule(
          ruleId: rule.id,
          rules: [rule],
          tasks: [unfinishedOccurrence, completedOccurrence, regularTask],
          exceptions: [exception],
        );

        expect(result.ruleIdToDelete, rule.id);
        expect(result.rules, isEmpty);
        expect(result.exceptions, isEmpty);
        expect(result.tasks.length, 2);

        final detachedCompletedTask = result.tasks.singleWhere(
          (task) => task.id == completedOccurrence.id,
        );

        expect(detachedCompletedTask.isCompleted, isTrue);
        expect(detachedCompletedTask.recurringRuleId, isNull);
        expect(result.tasks, contains(regularTask));
      },
    );

    test('updates rule and rebuilds unfinished upcoming occurrences', () {
      final oldRule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.monday]);

      final updatedRule = oldRule.copyWith(weekdays: [DateTime.wednesday]);

      final oldUnfinishedOccurrence = _recurringTask(
        id: 'task-1',
        ruleId: oldRule.id,
        isCompleted: false,
        scheduledDate: DateTime(2026, 5, 4),
      );

      final completedOccurrence = _recurringTask(
        id: 'task-2',
        ruleId: oldRule.id,
        isCompleted: true,
        scheduledDate: DateTime(2026, 5, 4),
      );

      final result = lifecycle.updateRuleAndRebuildOccurrences(
        updatedRule: updatedRule,
        rules: [oldRule],
        tasks: [oldUnfinishedOccurrence, completedOccurrence],
        exceptions: [],
        today: today,
      );

      expect(result.ruleToPersist, updatedRule);
      expect(result.rules.single.weekdays, [DateTime.wednesday]);

      expect(
        result.tasks.any((task) => task.id == oldUnfinishedOccurrence.id),
        isFalse,
      );

      expect(result.tasks, contains(completedOccurrence));
      expect(result.generatedTasks, isNotEmpty);
      expect(
        result.generatedTasks.every((task) {
          return task.recurringRuleId == updatedRule.id &&
              task.scheduledDate!.weekday == DateTime.wednesday;
        }),
        isTrue,
      );
    });

    test('returns no-op result when rule is missing', () {
      final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.friday]);

      final task = _regularTask(id: 'task-1');

      final result = lifecycle.deactivateRule(
        ruleId: 'missing-rule',
        rules: [rule],
        tasks: [task],
        exceptions: [],
      );

      expect(result.rules, [rule]);
      expect(result.tasks, [task]);
      expect(result.exceptions, isEmpty);
      expect(result.ruleToPersist, isNull);
      expect(result.ruleIdToDelete, isNull);
    });
  });
}

RecurringTaskRule _weeklyRule({
  required String id,
  required List<int> weekdays,
  bool isActive = true,
}) {
  return RecurringTaskRule(
    id: id,
    title: 'Workout',
    description: '',
    recurrenceType: RecurrenceType.weekly,
    weekdays: weekdays,
    monthDay: null,
    startDate: DateTime(2026, 5, 1),
    isActive: isActive,
    createdAt: DateTime(2026, 4, 1),
  );
}

PlannerTask _recurringTask({
  required String id,
  required String ruleId,
  required bool isCompleted,
  DateTime? scheduledDate,
}) {
  return PlannerTask(
    id: id,
    title: 'Workout',
    description: '',
    recurringRuleId: ruleId,
    scheduledDate: scheduledDate ?? DateTime(2026, 5, 1),
    isCompleted: isCompleted,
    completedAt: isCompleted ? DateTime(2026, 5, 1) : null,
    createdAt: DateTime(2026, 4, 1),
  );
}

PlannerTask _regularTask({required String id}) {
  return PlannerTask(
    id: id,
    title: 'One-off task',
    description: '',
    createdAt: DateTime(2026, 4, 1),
  );
}
