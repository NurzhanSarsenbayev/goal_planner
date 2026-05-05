import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_progress_calculator.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('HabitProgressCalculator', () {
    const calculator = HabitProgressCalculator();

    test('returns none for binary habit without explicit status', () {
      final habit = _habit(trackingType: HabitTrackingType.binary);

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 0,
      );

      expect(status, HabitEntryStatus.none);
    });

    test('returns explicit done for binary habit', () {
      final habit = _habit(trackingType: HabitTrackingType.binary);

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 0,
        explicitStatus: HabitEntryStatus.done,
      );

      expect(status, HabitEntryStatus.done);
    });

    test('returns explicit failed for binary habit', () {
      final habit = _habit(trackingType: HabitTrackingType.binary);

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 0,
        explicitStatus: HabitEntryStatus.failed,
      );

      expect(status, HabitEntryStatus.failed);
    });

    test('returns done when count habit reaches target', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 3,
      );

      expect(status, HabitEntryStatus.done);
    });

    test('returns done when count habit exceeds target', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 5,
      );

      expect(status, HabitEntryStatus.done);
    });

    test('returns incomplete when count habit is partially completed', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 2,
      );

      expect(status, HabitEntryStatus.incomplete);
    });

    test('returns none when count habit has no progress', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 0,
      );

      expect(status, HabitEntryStatus.none);
    });

    test('keeps explicit skipped for count habit', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 1,
        explicitStatus: HabitEntryStatus.skipped,
      );

      expect(status, HabitEntryStatus.skipped);
    });

    test('keeps explicit failed for count habit', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 3,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 2,
        explicitStatus: HabitEntryStatus.failed,
      );

      expect(status, HabitEntryStatus.failed);
    });

    test('falls back to explicit done when count target is invalid', () {
      final habit = _habit(
        trackingType: HabitTrackingType.count,
        targetCount: 0,
      );

      final status = calculator.statusForProgress(
        habit: habit,
        completedCount: 0,
        explicitStatus: HabitEntryStatus.done,
      );

      expect(status, HabitEntryStatus.done);
    });

    test(
      'returns none when count target is invalid and no explicit status',
      () {
        final habit = _habit(
          trackingType: HabitTrackingType.count,
          targetCount: 0,
        );

        final status = calculator.statusForProgress(
          habit: habit,
          completedCount: 3,
        );

        expect(status, HabitEntryStatus.none);
      },
    );
  });
}

Habit _habit({required HabitTrackingType trackingType, int? targetCount}) {
  return Habit(
    id: 'habit-1',
    title: 'Habit',
    description: '',
    trackingType: trackingType,
    targetCount: targetCount,
    sortOrder: 0,
    isArchived: false,
    createdAt: DateTime(2026, 5, 5),
    updatedAt: DateTime(2026, 5, 5),
  );
}
