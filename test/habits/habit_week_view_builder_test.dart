import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_week_view_builder.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('HabitWeekViewBuilder', () {
    const builder = HabitWeekViewBuilder();

    test('normalizes week start and creates seven dates', () {
      final view = builder.build(
        habits: const [],
        entries: const [],
        weekStart: DateTime(2026, 5, 4, 21, 30),
      );

      expect(view.weekStart, DateTime(2026, 5, 4));
      expect(view.dates, [
        DateTime(2026, 5, 4),
        DateTime(2026, 5, 5),
        DateTime(2026, 5, 6),
        DateTime(2026, 5, 7),
        DateTime(2026, 5, 8),
        DateTime(2026, 5, 9),
        DateTime(2026, 5, 10),
      ]);
    });

    test('excludes archived habits', () {
      final activeHabit = _habit(id: 'active');
      final archivedHabit = _habit(id: 'archived', isArchived: true);

      final view = builder.build(
        habits: [archivedHabit, activeHabit],
        entries: const [],
        weekStart: DateTime(2026, 5, 4),
      );

      expect(view.rows, hasLength(1));
      expect(view.rows.single.habit.id, 'active');
    });

    test('sorts habits by sort order and createdAt fallback', () {
      final third = _habit(
        id: 'third',
        sortOrder: 2,
        createdAt: DateTime(2026, 5, 1),
      );
      final second = _habit(
        id: 'second',
        sortOrder: 1,
        createdAt: DateTime(2026, 5, 2),
      );
      final first = _habit(
        id: 'first',
        sortOrder: 1,
        createdAt: DateTime(2026, 5, 1),
      );

      final view = builder.build(
        habits: [third, second, first],
        entries: const [],
        weekStart: DateTime(2026, 5, 4),
      );

      expect(view.rows.map((row) => row.habit.id), [
        'first',
        'second',
        'third',
      ]);
    });

    test('creates empty cells when entries are missing', () {
      final habit = _habit(id: 'habit-1');

      final view = builder.build(
        habits: [habit],
        entries: const [],
        weekStart: DateTime(2026, 5, 4),
      );

      expect(view.rows.single.cells, hasLength(7));
      expect(
        view.rows.single.cells.map((cell) => cell.status),
        everyElement(HabitEntryStatus.none),
      );
      expect(
        view.rows.single.cells.map((cell) => cell.hasEntry),
        everyElement(isFalse),
      );
    });

    test('matches entries by habit and date', () {
      final habit = _habit(id: 'habit-1');
      final entry = _entry(
        habitId: 'habit-1',
        date: DateTime(2026, 5, 6, 21, 30),
        status: HabitEntryStatus.done,
      );

      final view = builder.build(
        habits: [habit],
        entries: [entry],
        weekStart: DateTime(2026, 5, 4),
      );

      final cell = view.rows.single.cells[2];

      expect(cell.date, DateTime(2026, 5, 6));
      expect(cell.status, HabitEntryStatus.done);
      expect(cell.entry, same(entry));
      expect(cell.hasEntry, isTrue);
    });

    test('ignores entries for another habit', () {
      final habit = _habit(id: 'habit-1');
      final otherEntry = _entry(
        habitId: 'habit-2',
        date: DateTime(2026, 5, 6),
        status: HabitEntryStatus.done,
      );

      final view = builder.build(
        habits: [habit],
        entries: [otherEntry],
        weekStart: DateTime(2026, 5, 4),
      );

      expect(
        view.rows.single.cells.map((cell) => cell.status),
        everyElement(HabitEntryStatus.none),
      );
    });
  });
}

Habit _habit({
  required String id,
  bool isArchived = false,
  int sortOrder = 0,
  DateTime? createdAt,
}) {
  return Habit(
    id: id,
    title: id,
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: sortOrder,
    isArchived: isArchived,
    createdAt: createdAt ?? DateTime(2026, 5, 1),
    updatedAt: createdAt ?? DateTime(2026, 5, 1),
  );
}

HabitEntry _entry({
  required String habitId,
  required DateTime date,
  HabitEntryStatus status = HabitEntryStatus.none,
}) {
  return HabitEntry(
    id: 'entry-$habitId-${date.toIso8601String()}',
    habitId: habitId,
    date: date,
    status: status,
    completedCount: status == HabitEntryStatus.done ? 1 : 0,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}
