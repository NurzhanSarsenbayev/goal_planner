import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('RecurringTaskRule.matchesDate', () {
    test('weekly rule matches selected weekdays', () {
      final rule = _weeklyRule(
        weekdays: [DateTime.monday, DateTime.wednesday, DateTime.friday],
      );

      expect(rule.matchesDate(DateTime(2026, 4, 27)), isTrue); // Monday
      expect(rule.matchesDate(DateTime(2026, 4, 28)), isFalse); // Tuesday
      expect(rule.matchesDate(DateTime(2026, 4, 29)), isTrue); // Wednesday
      expect(rule.matchesDate(DateTime(2026, 5, 1)), isTrue); // Friday
    });

    test('monthly rule matches selected month day', () {
      final rule = _monthlyRule(monthDay: 15);

      expect(rule.matchesDate(DateTime(2026, 4, 15)), isTrue);
      expect(rule.matchesDate(DateTime(2026, 5, 15)), isTrue);
      expect(rule.matchesDate(DateTime(2026, 4, 14)), isFalse);
      expect(rule.matchesDate(DateTime(2026, 4, 16)), isFalse);
    });

    test('monthly rule matches selected day when month has that day', () {
      final rule = _monthlyRule(monthDay: 31, startDate: DateTime(2026, 1, 1));

      expect(rule.matchesDate(DateTime(2026, 1, 31)), isTrue);
      expect(rule.matchesDate(DateTime(2026, 1, 30)), isFalse);
    });

    test('monthly rule falls back to last day for shorter months', () {
      final rule = _monthlyRule(monthDay: 31);

      expect(rule.matchesDate(DateTime(2026, 4, 30)), isTrue);
      expect(rule.matchesDate(DateTime(2026, 4, 29)), isFalse);
    });

    test('monthly rule falls back to February 28 in non-leap year', () {
      final rule = _monthlyRule(monthDay: 31, startDate: DateTime(2026, 1, 1));

      expect(rule.matchesDate(DateTime(2026, 2, 28)), isTrue);
      expect(rule.matchesDate(DateTime(2026, 2, 27)), isFalse);
    });

    test('monthly rule falls back to February 29 in leap year', () {
      final rule = _monthlyRule(monthDay: 31);

      expect(rule.matchesDate(DateTime(2028, 2, 29)), isTrue);
      expect(rule.matchesDate(DateTime(2028, 2, 28)), isFalse);
    });

    test('inactive rule does not match any date', () {
      final rule = _weeklyRule(weekdays: [DateTime.monday], isActive: false);

      expect(rule.matchesDate(DateTime(2026, 4, 27)), isFalse);
    });

    test('rule does not match dates before start date', () {
      final rule = _weeklyRule(
        weekdays: [DateTime.monday],
        startDate: DateTime(2026, 4, 28),
      );

      expect(rule.matchesDate(DateTime(2026, 4, 27)), isFalse);
    });

    test('rule does not match dates after end date', () {
      final rule = _weeklyRule(
        weekdays: [DateTime.monday],
        startDate: DateTime(2026, 4, 1),
        endDate: DateTime(2026, 4, 26),
      );

      expect(rule.matchesDate(DateTime(2026, 4, 27)), isFalse);
    });

    test('matching ignores time of day', () {
      final rule = _monthlyRule(
        monthDay: 27,
        startDate: DateTime(2026, 4, 27, 23, 30),
      );

      expect(rule.matchesDate(DateTime(2026, 4, 27, 8, 15)), isTrue);
    });
  });
}

RecurringTaskRule _weeklyRule({
  required List<int> weekdays,
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
}) {
  return RecurringTaskRule(
    id: 'rule-weekly',
    title: 'Workout',
    description: '',
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
  required int monthDay,
  DateTime? startDate,
  DateTime? endDate,
  bool isActive = true,
}) {
  return RecurringTaskRule(
    id: 'rule-monthly',
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
