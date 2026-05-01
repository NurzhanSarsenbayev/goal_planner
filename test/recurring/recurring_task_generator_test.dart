import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';
import 'package:goal_planner/features/recurring/domain/recurring_task_generator.dart';

void main() {
  group('generateRecurringTaskOccurrences', () {
    final startDate = DateTime(2026, 4, 27); // Monday
    final endDate = DateTime(2026, 5, 3); // Sunday

    test('generates weekly occurrences inside date range', () {
      final rule = _weeklyRule(
        id: 'rule-1',
        weekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: startDate,
        endDate: endDate,
      );

      expect(generated.map((task) => task.scheduledDate).toList(), [
        DateTime(2026, 4, 27), // Monday
        DateTime(2026, 4, 29), // Wednesday
        DateTime(2026, 5, 1), // Friday
      ]);
    });

    test('generates monthly occurrence inside date range', () {
      final rule = _monthlyRule(id: 'rule-1', monthDay: 1);

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: startDate,
        endDate: endDate,
      );

      expect(generated.length, 1);
      expect(generated.first.scheduledDate, DateTime(2026, 5, 1));
    });

    test('returns empty list when end date is before start date', () {
      final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.monday]);

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: DateTime(2026, 5, 2),
        endDate: DateTime(2026, 5, 1),
      );

      expect(generated, isEmpty);
    });

    test('does not generate inactive rule occurrences', () {
      final rule = _weeklyRule(
        id: 'rule-1',
        weekdays: [DateTime.monday],
        isActive: false,
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: startDate,
        endDate: endDate,
      );

      expect(generated, isEmpty);
    });

    test('does not generate occurrence before rule start date', () {
      final rule = _weeklyRule(
        id: 'rule-1',
        weekdays: [DateTime.monday],
        startDate: DateTime(2026, 4, 28),
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: DateTime(2026, 4, 27),
        endDate: DateTime(2026, 4, 27),
      );

      expect(generated, isEmpty);
    });

    test('does not generate occurrence after rule end date', () {
      final rule = _weeklyRule(
        id: 'rule-1',
        weekdays: [DateTime.monday],
        endDate: DateTime(2026, 4, 26),
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: DateTime(2026, 4, 27),
        endDate: DateTime(2026, 4, 27),
      );

      expect(generated, isEmpty);
    });

    test('does not generate occurrence when exception exists', () {
      final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.monday]);

      final exception = RecurringTaskException(
        id: 'exception-1',
        ruleId: rule.id,
        date: startDate,
        createdAt: startDate,
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [exception],
        existingTasks: [],
        startDate: startDate,
        endDate: startDate,
      );

      expect(generated, isEmpty);
    });

    test('does not generate duplicate occurrence when task already exists', () {
      final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.monday]);

      final existingTask = PlannerTask(
        id: 'existing-task',
        title: 'Workout',
        description: '',
        recurringRuleId: rule.id,
        scheduledDate: startDate,
        createdAt: startDate,
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [existingTask],
        startDate: startDate,
        endDate: startDate,
      );

      expect(generated, isEmpty);
    });

    test('does not generate duplicates inside same generation result', () {
      final rule = _weeklyRule(id: 'rule-1', weekdays: [DateTime.monday]);

      final generated = generateRecurringTaskOccurrences(
        rules: [rule, rule],
        exceptions: [],
        existingTasks: [],
        startDate: startDate,
        endDate: startDate,
      );

      expect(generated.length, 1);
    });

    test('generated occurrence copies rule placement and content', () {
      final rule = _weeklyRule(
        id: 'rule-1',
        title: 'Workout',
        description: 'Strength training',
        goalId: 'goal-1',
        milestoneId: 'milestone-1',
        weekdays: [DateTime.monday],
      );

      final generated = generateRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        startDate: startDate,
        endDate: startDate,
      );

      final task = generated.single;

      expect(task.title, 'Workout');
      expect(task.description, 'Strength training');
      expect(task.goalId, 'goal-1');
      expect(task.milestoneId, 'milestone-1');
      expect(task.recurringRuleId, rule.id);
      expect(task.scheduledDate, startDate);
    });

    test('uses deterministic occurrence task id', () {
      final id = recurringOccurrenceTaskId(
        ruleId: 'rule-1',
        date: DateTime(2026, 4, 27),
      );

      expect(id, 'task_recurring_rule-1_20260427');
    });
  });

  group('generateUpcomingRecurringTaskOccurrences', () {
    test('generates from today for configured number of days', () {
      final today = DateTime(2026, 4, 27); // Monday
      final rule = _weeklyRule(
        id: 'rule-1',
        weekdays: [DateTime.monday, DateTime.wednesday],
      );

      final generated = generateUpcomingRecurringTaskOccurrences(
        rules: [rule],
        exceptions: [],
        existingTasks: [],
        today: today,
        days: 3,
      );

      expect(generated.map((task) => task.scheduledDate).toList(), [
        DateTime(2026, 4, 27),
        DateTime(2026, 4, 29),
      ]);
    });
  });
}

RecurringTaskRule _weeklyRule({
  required String id,
  required List<int> weekdays,
  String title = 'Workout',
  String description = '',
  String? goalId,
  String? milestoneId,
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
}) {
  return RecurringTaskRule(
    id: id,
    title: title,
    description: description,
    goalId: goalId,
    milestoneId: milestoneId,
    recurrenceType: RecurrenceType.weekly,
    weekdays: weekdays,
    monthDay: null,
    startDate: startDate ?? DateTime(2026, 4, 1),
    endDate: endDate,
    isActive: isActive,
    createdAt: DateTime(2026, 4, 1),
  );
}

RecurringTaskRule _monthlyRule({
  required String id,
  required int monthDay,
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
}) {
  return RecurringTaskRule(
    id: id,
    title: 'Pay taxes',
    description: '',
    recurrenceType: RecurrenceType.monthly,
    weekdays: const [],
    monthDay: monthDay,
    startDate: startDate ?? DateTime(2026, 4, 1),
    endDate: endDate,
    isActive: isActive,
    createdAt: DateTime(2026, 4, 1),
  );
}
