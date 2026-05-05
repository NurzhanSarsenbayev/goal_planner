import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_application_service.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('HabitApplicationService', () {
    const service = HabitApplicationService();

    test('creates binary habit with normalized title and sort order', () {
      final now = DateTime(2026, 5, 5);

      final result = service.createHabit(
        habits: [_habit(sortOrder: 2)],
        title: '  Drink water  ',
        description: '  Daily  ',
        now: now,
      );

      expect(result.hasChange, isTrue);
      expect(result.habits, hasLength(2));

      final created = result.habitToPersist!;

      expect(created.title, 'Drink water');
      expect(created.description, 'Daily');
      expect(created.trackingType, HabitTrackingType.binary);
      expect(created.targetCount, isNull);
      expect(created.sortOrder, 3);
      expect(created.isArchived, isFalse);
      expect(created.createdAt, now);
      expect(created.updatedAt, now);
    });

    test('does not create habit with empty title', () {
      final habits = [_habit()];

      final result = service.createHabit(
        habits: habits,
        title: '   ',
        description: '',
      );

      expect(result.hasChange, isFalse);
      expect(result.habits, same(habits));
    });

    test('creates count habit with normalized target count', () {
      final result = service.createHabit(
        habits: const [],
        title: 'Water',
        description: '',
        trackingType: HabitTrackingType.count,
        targetCount: 8,
        now: DateTime(2026, 5, 5),
      );

      expect(result.habitToPersist!.trackingType, HabitTrackingType.count);
      expect(result.habitToPersist!.targetCount, 8);
    });

    test('uses default target count for invalid count habit target', () {
      final result = service.createHabit(
        habits: const [],
        title: 'Water',
        description: '',
        trackingType: HabitTrackingType.count,
        targetCount: 0,
      );

      expect(result.habitToPersist!.targetCount, 1);
    });

    test('updates habit details', () {
      final now = DateTime(2026, 5, 6);
      final habit = _habit(title: 'Old');

      final result = service.updateHabit(
        habits: [habit],
        habitId: habit.id,
        title: '  New  ',
        description: '  Updated  ',
        now: now,
      );

      final updated = result.habitToPersist!;

      expect(updated.title, 'New');
      expect(updated.description, 'Updated');
      expect(updated.updatedAt, now);
      expect(result.habits.single.title, 'New');
    });

    test('does not update missing habit', () {
      final habits = [_habit()];

      final result = service.updateHabit(
        habits: habits,
        habitId: 'missing',
        title: 'New',
        description: '',
      );

      expect(result.hasChange, isFalse);
      expect(result.habits, same(habits));
    });

    test('archives habit', () {
      final now = DateTime(2026, 5, 6);
      final habit = _habit(isArchived: false);

      final result = service.archiveHabit(
        habits: [habit],
        habitId: habit.id,
        now: now,
      );

      final archived = result.habitToPersist!;

      expect(archived.isArchived, isTrue);
      expect(archived.updatedAt, now);
      expect(result.habits.single.isArchived, isTrue);
    });

    test('does not archive missing habit', () {
      final habits = [_habit()];

      final result = service.archiveHabit(habits: habits, habitId: 'missing');

      expect(result.hasChange, isFalse);
      expect(result.habits, same(habits));
    });

    test('deletes habit from list', () {
      final habit = _habit();

      final result = service.deleteHabit(habits: [habit], habitId: habit.id);

      expect(result.habits, isEmpty);
      expect(result.habitIdToDelete, habit.id);
    });

    test('does not delete missing habit', () {
      final habits = [_habit()];

      final result = service.deleteHabit(habits: habits, habitId: 'missing');

      expect(result.hasChange, isFalse);
      expect(result.habits, same(habits));
    });

    test('creates entry for habit/date when marking first time', () {
      final now = DateTime(2026, 5, 5, 10);
      final habit = _habit();

      final result = service.markEntry(
        entries: const [],
        habit: habit,
        date: DateTime(2026, 5, 5, 21),
        status: HabitEntryStatus.done,
        now: now,
      );

      final entry = result.entryToPersist!;

      expect(result.entries, hasLength(1));
      expect(entry.habitId, habit.id);
      expect(entry.date, DateTime(2026, 5, 5));
      expect(entry.status, HabitEntryStatus.done);
      expect(entry.completedCount, 1);
      expect(entry.createdAt, now);
      expect(entry.updatedAt, now);
    });

    test('updates existing entry for same habit/date', () {
      final habit = _habit();
      final entry = _entry(habitId: habit.id, status: HabitEntryStatus.done);
      final now = DateTime(2026, 5, 6);

      final result = service.markEntry(
        entries: [entry],
        habit: habit,
        date: DateTime(2026, 5, 5, 23),
        status: HabitEntryStatus.failed,
        now: now,
      );

      final updated = result.entryToPersist!;

      expect(result.entries, hasLength(1));
      expect(updated.id, entry.id);
      expect(updated.status, HabitEntryStatus.failed);
      expect(updated.completedCount, 0);
      expect(updated.updatedAt, now);
    });

    test('marks count habit as incomplete when below target', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final result = service.markEntry(
        entries: const [],
        habit: habit,
        date: DateTime(2026, 5, 5),
        status: HabitEntryStatus.incomplete,
        completedCount: 2,
      );

      final entry = result.entryToPersist!;

      expect(entry.status, HabitEntryStatus.incomplete);
      expect(entry.completedCount, 2);
    });

    test('marks count habit as done when reaching target', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final result = service.markEntry(
        entries: const [],
        habit: habit,
        date: DateTime(2026, 5, 5),
        status: HabitEntryStatus.incomplete,
        completedCount: 3,
      );

      final entry = result.entryToPersist!;

      expect(entry.status, HabitEntryStatus.done);
      expect(entry.completedCount, 3);
    });

    test('keeps skipped as explicit neutral status', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final result = service.markEntry(
        entries: const [],
        habit: habit,
        date: DateTime(2026, 5, 5),
        status: HabitEntryStatus.skipped,
        completedCount: 2,
      );

      final entry = result.entryToPersist!;

      expect(entry.status, HabitEntryStatus.skipped);
      expect(entry.completedCount, 0);
    });

    test('clears existing entry', () {
      final habit = _habit();
      final entry = _entry(habitId: habit.id);

      final result = service.clearEntry(
        entries: [entry],
        habitId: habit.id,
        date: DateTime(2026, 5, 5),
      );

      expect(result.entries, isEmpty);
      expect(result.entryIdToDelete, entry.id);
    });

    test('does not clear missing entry', () {
      final entries = [_entry()];

      final result = service.clearEntry(
        entries: entries,
        habitId: 'missing',
        date: DateTime(2026, 5, 5),
      );

      expect(result.hasChange, isFalse);
      expect(result.entries, same(entries));
    });
  });
}

Habit _habit({
  String id = 'habit-1',
  String title = 'Habit',
  String description = '',
  HabitTrackingType trackingType = HabitTrackingType.binary,
  int? targetCount,
  int sortOrder = 0,
  bool isArchived = false,
}) {
  return Habit(
    id: id,
    title: title,
    description: description,
    trackingType: trackingType,
    targetCount: targetCount,
    sortOrder: sortOrder,
    isArchived: isArchived,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}

HabitEntry _entry({
  String id = 'entry-1',
  String habitId = 'habit-1',
  HabitEntryStatus status = HabitEntryStatus.none,
  int completedCount = 0,
}) {
  return HabitEntry(
    id: id,
    habitId: habitId,
    date: DateTime(2026, 5, 5),
    status: status,
    completedCount: completedCount,
    createdAt: DateTime(2026, 5, 5),
    updatedAt: DateTime(2026, 5, 5),
  );
}
