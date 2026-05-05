import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';

void main() {
  group('HabitEntry', () {
    test('normalizes date to date-only', () {
      final entry = _entry(date: DateTime(2026, 5, 5, 21, 30));

      expect(entry.date, DateTime(2026, 5, 5));
    });

    test('exposes status helpers', () {
      final entry = _entry(status: HabitEntryStatus.done);

      expect(entry.isMarked, isTrue);
      expect(entry.isCompleted, isTrue);
      expect(entry.isFailure, isFalse);
    });

    test('copyWith can update status and completed count', () {
      final entry = _entry();

      final updated = entry.copyWith(
        status: HabitEntryStatus.incomplete,
        completedCount: 2,
      );

      expect(updated.status, HabitEntryStatus.incomplete);
      expect(updated.completedCount, 2);
      expect(updated.habitId, entry.habitId);
    });

    test('copyWith can clear note', () {
      final entry = _entry(note: 'Felt tired');

      final updated = entry.copyWith(note: null);

      expect(updated.note, isNull);
    });

    test('copyWith preserves note when omitted', () {
      final entry = _entry(note: 'Good day');

      final updated = entry.copyWith(status: HabitEntryStatus.failed);

      expect(updated.note, 'Good day');
      expect(updated.status, HabitEntryStatus.failed);
    });
  });
}

HabitEntry _entry({
  DateTime? date,
  HabitEntryStatus status = HabitEntryStatus.none,
  int completedCount = 0,
  String? note,
}) {
  return HabitEntry(
    id: 'entry-1',
    habitId: 'habit-1',
    date: date ?? DateTime(2026, 5, 5),
    status: status,
    completedCount: completedCount,
    note: note,
    createdAt: DateTime(2026, 5, 1),
    updatedAt: DateTime(2026, 5, 1),
  );
}
