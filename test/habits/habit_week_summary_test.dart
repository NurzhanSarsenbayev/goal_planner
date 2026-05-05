import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_week_summary.dart';
import 'package:goal_planner/features/habits/application/habit_week_view_builder.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';

void main() {
  group('HabitWeekSummaryCalculator', () {
    const calculator = HabitWeekSummaryCalculator();

    test('counts weekly statuses', () {
      final summary = calculator.calculate([
        _cell(HabitEntryStatus.done),
        _cell(HabitEntryStatus.done),
        _cell(HabitEntryStatus.failed),
        _cell(HabitEntryStatus.skipped),
        _cell(HabitEntryStatus.incomplete),
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
      ]);

      expect(summary.totalDays, 7);
      expect(summary.doneCount, 2);
      expect(summary.failedCount, 1);
      expect(summary.skippedCount, 1);
      expect(summary.incompleteCount, 1);
      expect(summary.markedCount, 5);
      expect(summary.emptyCount, 2);
    });

    test('handles empty week', () {
      final summary = calculator.calculate([
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
        _cell(HabitEntryStatus.none),
      ]);

      expect(summary.totalDays, 7);
      expect(summary.doneCount, 0);
      expect(summary.failedCount, 0);
      expect(summary.skippedCount, 0);
      expect(summary.incompleteCount, 0);
      expect(summary.markedCount, 0);
      expect(summary.emptyCount, 7);
    });
  });
}

HabitWeekCell _cell(HabitEntryStatus status) {
  return HabitWeekCell(date: DateTime(2026, 5, 4), status: status);
}
