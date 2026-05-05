import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';

void main() {
  group('HabitEntryStatus', () {
    test('done counts as completion and not as failure', () {
      expect(HabitEntryStatus.done.countsAsCompletion, isTrue);
      expect(HabitEntryStatus.done.countsAsFailure, isFalse);
      expect(HabitEntryStatus.done.isExplicitMark, isTrue);
    });

    test('failed counts as failure', () {
      expect(HabitEntryStatus.failed.countsAsCompletion, isFalse);
      expect(HabitEntryStatus.failed.countsAsFailure, isTrue);
      expect(HabitEntryStatus.failed.isExplicitMark, isTrue);
    });

    test('incomplete counts as failure for completion-rate denominator', () {
      expect(HabitEntryStatus.incomplete.countsAsCompletion, isFalse);
      expect(HabitEntryStatus.incomplete.countsAsFailure, isTrue);
      expect(HabitEntryStatus.incomplete.isExplicitMark, isTrue);
    });

    test('skipped is explicit but does not count as failure', () {
      expect(HabitEntryStatus.skipped.countsAsCompletion, isFalse);
      expect(HabitEntryStatus.skipped.countsAsFailure, isFalse);
      expect(HabitEntryStatus.skipped.isExplicitMark, isTrue);
    });

    test('none is not an explicit mark', () {
      expect(HabitEntryStatus.none.countsAsCompletion, isFalse);
      expect(HabitEntryStatus.none.countsAsFailure, isFalse);
      expect(HabitEntryStatus.none.isExplicitMark, isFalse);
    });
  });
}
