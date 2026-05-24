import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/habit_mappers.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('habit mappers', () {
    test('maps habit tracking type from valid database value', () {
      expect(mapHabitTrackingType('binary'), HabitTrackingType.binary);
      expect(mapHabitTrackingType('count'), HabitTrackingType.count);
    });

    test('falls back to binary for unknown tracking type', () {
      expect(mapHabitTrackingType('unknown'), HabitTrackingType.binary);
    });

    test('maps habit entry status from valid database value', () {
      expect(mapHabitEntryStatus('none'), HabitEntryStatus.none);
      expect(mapHabitEntryStatus('done'), HabitEntryStatus.done);
      expect(mapHabitEntryStatus('incomplete'), HabitEntryStatus.incomplete);
      expect(mapHabitEntryStatus('failed'), HabitEntryStatus.failed);
      expect(mapHabitEntryStatus('skipped'), HabitEntryStatus.skipped);
    });

    test('falls back to none for unknown entry status', () {
      expect(mapHabitEntryStatus('unknown'), HabitEntryStatus.none);
    });

    test('maps habit database row to domain model', () {
      final row = local.Habit(
        id: 'habit-1',
        title: 'Drink water',
        description: '8 glasses',
        trackingType: 'count',
        targetCount: 8,
        sortOrder: 2,
        isArchived: false,
        isReminderEnabled: true,
        reminderTimeMinutes: 20 * 60 + 15,
        createdAt: DateTime(2026, 5, 1),
        updatedAt: DateTime(2026, 5, 2),
      );

      final habit = mapHabit(row);

      expect(habit.id, 'habit-1');
      expect(habit.title, 'Drink water');
      expect(habit.description, '8 glasses');
      expect(habit.trackingType, HabitTrackingType.count);
      expect(habit.targetCount, 8);
      expect(habit.sortOrder, 2);
      expect(habit.isArchived, isFalse);
      expect(habit.isReminderEnabled, isTrue);
      expect(habit.reminderTimeMinutes, 1215);
    });

    test('maps habit entry database row to domain model', () {
      final row = local.HabitEntry(
        id: 'entry-1',
        habitId: 'habit-1',
        date: DateTime(2026, 5, 5, 21, 30),
        status: 'done',
        completedCount: 1,
        note: 'Good day',
        createdAt: DateTime(2026, 5, 5),
        updatedAt: DateTime(2026, 5, 5),
      );

      final entry = mapHabitEntry(row);

      expect(entry.id, 'entry-1');
      expect(entry.habitId, 'habit-1');
      expect(entry.date, DateTime(2026, 5, 5));
      expect(entry.status, HabitEntryStatus.done);
      expect(entry.completedCount, 1);
      expect(entry.note, 'Good day');
    });

    test('converts tracking type to database value', () {
      expect(
        habitTrackingTypeToDatabaseValue(HabitTrackingType.binary),
        'binary',
      );
      expect(
        habitTrackingTypeToDatabaseValue(HabitTrackingType.count),
        'count',
      );
    });

    test('converts entry status to database value', () {
      expect(habitEntryStatusToDatabaseValue(HabitEntryStatus.none), 'none');
      expect(habitEntryStatusToDatabaseValue(HabitEntryStatus.done), 'done');
      expect(
        habitEntryStatusToDatabaseValue(HabitEntryStatus.incomplete),
        'incomplete',
      );
      expect(
        habitEntryStatusToDatabaseValue(HabitEntryStatus.failed),
        'failed',
      );
      expect(
        habitEntryStatusToDatabaseValue(HabitEntryStatus.skipped),
        'skipped',
      );
    });
  });
}
