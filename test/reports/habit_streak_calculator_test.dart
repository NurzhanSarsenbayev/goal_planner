import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/reports/application/habit_streak_calculator.dart';

void main() {
  group('calculateCurrentHabitStreakDays', () {
    final today = DateTime(2026, 5, 10);

    test('counts successful days and treats skipped days as neutral', () {
      final habit = _habit(id: 'habit-1');

      final streak = calculateCurrentHabitStreakDays(
        habits: [habit],
        entries: [
          _entry(habitId: habit.id, date: today, status: HabitEntryStatus.done),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.skipped,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 2)),
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 3)),
            status: HabitEntryStatus.failed,
          ),
        ],
        startDate: today.subtract(const Duration(days: 6)),
        endDate: today,
      );

      expect(streak, 2);
    });

    test('breaks when a past expected habit day has no mark', () {
      final habit = _habit(id: 'habit-1');

      final streak = calculateCurrentHabitStreakDays(
        habits: [habit],
        entries: [
          _entry(habitId: habit.id, date: today, status: HabitEntryStatus.done),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 2)),
            status: HabitEntryStatus.done,
          ),
        ],
        startDate: today.subtract(const Duration(days: 6)),
        endDate: today,
      );

      expect(streak, 1);
    });

    test('treats today without a mark as pending, not failed', () {
      final habit = _habit(id: 'habit-1');

      final streak = calculateCurrentHabitStreakDays(
        habits: [habit],
        entries: [
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 2)),
            status: HabitEntryStatus.done,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 3)),
            status: HabitEntryStatus.failed,
          ),
        ],
        startDate: today.subtract(const Duration(days: 6)),
        endDate: today,
      );

      expect(streak, 2);
    });

    test(
      'requires all expected habits to be resolved for a successful day',
      () {
        final firstHabit = _habit(id: 'first');
        final secondHabit = _habit(id: 'second');

        final streak = calculateCurrentHabitStreakDays(
          habits: [firstHabit, secondHabit],
          entries: [
            _entry(
              habitId: firstHabit.id,
              date: today,
              status: HabitEntryStatus.done,
            ),
            _entry(
              habitId: secondHabit.id,
              date: today,
              status: HabitEntryStatus.skipped,
            ),
            _entry(
              habitId: firstHabit.id,
              date: today.subtract(const Duration(days: 1)),
              status: HabitEntryStatus.done,
            ),
          ],
          startDate: today.subtract(const Duration(days: 6)),
          endDate: today,
        );

        expect(streak, 1);
      },
    );

    test('does not penalize days before habit creation', () {
      final habit = _habit(
        id: 'new-habit',
        createdAt: today.subtract(const Duration(days: 1)),
      );

      final streak = calculateCurrentHabitStreakDays(
        habits: [habit],
        entries: [
          _entry(habitId: habit.id, date: today, status: HabitEntryStatus.done),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.done,
          ),
        ],
        startDate: today.subtract(const Duration(days: 6)),
        endDate: today,
      );

      expect(streak, 2);
    });

    test('treats incomplete marks as failed days', () {
      final habit = _habit(id: 'habit-1');

      final streak = calculateCurrentHabitStreakDays(
        habits: [habit],
        entries: [
          _entry(
            habitId: habit.id,
            date: today,
            status: HabitEntryStatus.incomplete,
          ),
          _entry(
            habitId: habit.id,
            date: today.subtract(const Duration(days: 1)),
            status: HabitEntryStatus.done,
          ),
        ],
        startDate: today.subtract(const Duration(days: 6)),
        endDate: today,
      );

      expect(streak, 0);
    });
  });
}

Habit _habit({
  required String id,
  bool isArchived = false,
  DateTime? createdAt,
}) {
  final timestamp = createdAt ?? DateTime(2026, 5, 1);

  return Habit(
    id: id,
    title: id,
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: isArchived,
    createdAt: timestamp,
    updatedAt: timestamp,
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
    completedCount: status == HabitEntryStatus.done ? 1 : 0,
    createdAt: date,
    updatedAt: date,
  );
}
