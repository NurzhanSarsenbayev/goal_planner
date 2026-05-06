import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_today_summary.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('HabitTodaySummaryBuilder', () {
    const builder = HabitTodaySummaryBuilder();

    test('counts today statuses for active habits only', () {
      final date = DateTime(2026, 5, 6);
      final activeHabit = _habit(id: 'active-1');
      final secondActiveHabit = _habit(id: 'active-2');
      final archivedHabit = _habit(id: 'archived', isArchived: true);

      final summary = builder.build(
        habits: [activeHabit, secondActiveHabit, archivedHabit],
        entries: [
          _entry(habitId: activeHabit.id, date: date),
          _entry(
            habitId: archivedHabit.id,
            date: date,
            status: HabitEntryStatus.failed,
          ),
        ],
        date: date,
      );

      expect(summary.totalHabitCount, 2);
      expect(summary.doneCount, 1);
      expect(summary.failedCount, 0);
      expect(summary.skippedCount, 0);
      expect(summary.incompleteCount, 0);
      expect(summary.markedCount, 1);
      expect(summary.unmarkedCount, 1);
    });

    test('ignores entries from another date', () {
      final date = DateTime(2026, 5, 6);
      final habit = _habit();

      final summary = builder.build(
        habits: [habit],
        entries: [
          _entry(
            habitId: habit.id,
            date: DateTime(2026, 5, 5),
            status: HabitEntryStatus.done,
          ),
        ],
        date: date,
      );

      expect(summary.totalHabitCount, 1);
      expect(summary.doneCount, 0);
      expect(summary.unmarkedCount, 1);
    });
  });
}

Habit _habit({String id = 'habit-1', bool isArchived = false}) {
  return Habit(
    id: id,
    title: 'Habit',
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: isArchived,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}

HabitEntry _entry({
  required String habitId,
  required DateTime date,
  HabitEntryStatus status = HabitEntryStatus.done,
}) {
  return HabitEntry(
    id: '$habitId-entry',
    habitId: habitId,
    date: date,
    status: status,
    completedCount: 0,
    createdAt: date,
    updatedAt: date,
  );
}
