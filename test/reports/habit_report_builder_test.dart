import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/reports/application/habit_report_builder.dart';
import 'package:goal_planner/features/reports/domain/report_period.dart';

void main() {
  group('buildHabitReportSummary', () {
    final today = DateTime(2026, 5, 10);

    test('counts marked habit entries inside selected period', () {
      final habit = _habit(id: 'habit-1');

      final summary = buildHabitReportSummary(
        habits: [habit],
        entries: [
          _entry(habitId: habit.id, date: today, status: HabitEntryStatus.done),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.failed,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 2)),
            status: HabitEntryStatus.skipped,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 3)),
            status: HabitEntryStatus.incomplete,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 7)),
            status: HabitEntryStatus.done,
          ),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.doneCount, 1);
      expect(summary.missedCount, 2);
      expect(summary.skippedCount, 1);
      expect(summary.partialCount, 1);
      expect(summary.markedCount, 5);
    });

    test('counts expected marks for full selected period', () {
      final habit = _habit(id: 'new-habit', createdAt: today);

      final summary = buildHabitReportSummary(
        habits: [habit],
        entries: [],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.expectedMarkCount, 7);
      expect(summary.consistencyPercent, 0);
      expect(summary.hasHabitData, isTrue);
    });

    test(
      'does not produce consistency over 100 when backfilled marks exist',
      () {
        final habit = _habit(id: 'habit-1');

        final summary = buildHabitReportSummary(
          habits: [habit],
          entries: [
            _entry(
              habitId: habit.id,
              date: today,
              status: HabitEntryStatus.done,
            ),
            _entry(
              habitId: habit.id,
              date: today.subtract(const Duration(days: 1)),
              status: HabitEntryStatus.done,
            ),
          ],
          period: ReportPeriod.today,
          today: today,
        );

        expect(summary.expectedMarkCount, 1);
        expect(summary.doneCount, 1);
        expect(summary.consistencyPercent, 100);
      },
    );

    test('calculates consistency percent from done over expected marks', () {
      final habit = _habit(id: 'habit-1');

      final summary = buildHabitReportSummary(
        habits: [habit],
        entries: [
          _entry(habitId: habit.id, date: today, status: HabitEntryStatus.done),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.done,
          ),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.expectedMarkCount, 7);
      expect(summary.doneCount, 2);
      expect(summary.consistencyPercent, 29);
    });

    test(
      'ignores archived habits for expected marks but keeps their history',
      () {
        final archivedHabit = _habit(id: 'archived', isArchived: true);

        final summary = buildHabitReportSummary(
          habits: [archivedHabit],
          entries: [
            _entry(
              habitId: archivedHabit.id,
              date: today,
              status: HabitEntryStatus.done,
            ),
          ],
          period: ReportPeriod.last7Days,
          today: today,
        );

        expect(summary.activeHabitCount, 0);
        expect(summary.expectedMarkCount, 0);
        expect(summary.doneCount, 1);
        expect(summary.hasHabitData, isTrue);
      },
    );

    test('excludes skipped marks from consistency denominator', () {
      final firstHabit = _habit(id: 'first');
      final secondHabit = _habit(id: 'second');
      final skippedHabit = _habit(id: 'skipped');

      final summary = buildHabitReportSummary(
        habits: [firstHabit, secondHabit, skippedHabit],
        entries: [
          _entry(
            habitId: firstHabit.id,
            date: today,
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: secondHabit.id,
            date: today,
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: skippedHabit.id,
            date: today,
            status: HabitEntryStatus.skipped,
          ),
        ],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.expectedMarkCount, 3);
      expect(summary.skippedCount, 1);
      expect(summary.actionableExpectedMarkCount, 2);
      expect(summary.doneCount, 2);
      expect(summary.consistencyPercent, 100);
    });

    test('groups habit entries by habit and day', () {
      final firstHabit = _habit(id: 'first', sortOrder: 0);
      final secondHabit = _habit(id: 'second', sortOrder: 1);

      final summary = buildHabitReportSummary(
        habits: [secondHabit, firstHabit],
        entries: [
          _entry(
            habitId: secondHabit.id,
            date: today,
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: firstHabit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.failed,
          ),
        ],
        period: ReportPeriod.last7Days,
        today: today,
      );

      expect(summary.habitGroups.map((group) => group.habit.id), [
        firstHabit.id,
        secondHabit.id,
      ]);
      expect(summary.dayGroups.length, 2);
      expect(summary.dayGroups.first.date, today);
      expect(summary.dayGroups.first.entries.first.habitId, secondHabit.id);
    });

    test('ignores entries for unknown habits', () {
      final summary = buildHabitReportSummary(
        habits: [],
        entries: [
          _entry(
            habitId: 'missing',
            date: today,
            status: HabitEntryStatus.done,
          ),
        ],
        period: ReportPeriod.today,
        today: today,
      );

      expect(summary.doneCount, 0);
      expect(summary.hasHabitData, isFalse);
    });
  });
}

Habit _habit({
  required String id,
  int sortOrder = 0,
  bool isArchived = false,
  DateTime? createdAt,
}) {
  final now = DateTime(2026, 5, 1);

  return Habit(
    id: id,
    title: id,
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: sortOrder,
    isArchived: isArchived,
    createdAt: createdAt ?? now,
    updatedAt: now,
  );
}

HabitEntry _entry({
  required String habitId,
  required DateTime date,
  required HabitEntryStatus status,
}) {
  return HabitEntry(
    id: '$habitId-${date.toIso8601String()}',
    habitId: habitId,
    date: date,
    status: status,
    completedCount: 0,
    createdAt: date,
    updatedAt: date,
  );
}
