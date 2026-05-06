import '../../../shared/planner_dates.dart';
import '../domain/habit.dart';
import '../domain/habit_entry.dart';
import '../domain/habit_entry_status.dart';

class HabitTodaySummary {
  const HabitTodaySummary({
    required this.totalHabitCount,
    required this.doneCount,
    required this.failedCount,
    required this.skippedCount,
    required this.incompleteCount,
  });

  final int totalHabitCount;
  final int doneCount;
  final int failedCount;
  final int skippedCount;
  final int incompleteCount;

  bool get hasHabits {
    return totalHabitCount > 0;
  }

  int get markedCount {
    return doneCount + failedCount + skippedCount + incompleteCount;
  }

  int get actionableHabitCount {
    final count = totalHabitCount - skippedCount;

    if (count < 0) {
      return 0;
    }

    return count;
  }

  int get unmarkedCount {
    return totalHabitCount - markedCount;
  }
}

class HabitTodaySummaryBuilder {
  const HabitTodaySummaryBuilder();

  HabitTodaySummary build({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required DateTime date,
  }) {
    final normalizedDate = dateOnly(date);
    final activeHabits = [
      for (final habit in habits)
        if (!habit.isArchived) habit,
    ];

    final entriesByHabitId = <String, HabitEntry>{};

    for (final entry in entries) {
      if (entry.date == normalizedDate) {
        entriesByHabitId[entry.habitId] = entry;
      }
    }

    var doneCount = 0;
    var failedCount = 0;
    var skippedCount = 0;
    var incompleteCount = 0;

    for (final habit in activeHabits) {
      final status =
          entriesByHabitId[habit.id]?.status ?? HabitEntryStatus.none;

      switch (status) {
        case HabitEntryStatus.done:
          doneCount += 1;
        case HabitEntryStatus.failed:
          failedCount += 1;
        case HabitEntryStatus.skipped:
          skippedCount += 1;
        case HabitEntryStatus.incomplete:
          incompleteCount += 1;
        case HabitEntryStatus.none:
          break;
      }
    }

    return HabitTodaySummary(
      totalHabitCount: activeHabits.length,
      doneCount: doneCount,
      failedCount: failedCount,
      skippedCount: skippedCount,
      incompleteCount: incompleteCount,
    );
  }
}
