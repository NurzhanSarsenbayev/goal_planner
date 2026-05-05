import '../domain/habit_entry_status.dart';
import 'habit_week_view_builder.dart';

class HabitWeekSummary {
  const HabitWeekSummary({
    required this.totalDays,
    required this.doneCount,
    required this.failedCount,
    required this.skippedCount,
    required this.incompleteCount,
  });

  final int totalDays;
  final int doneCount;
  final int failedCount;
  final int skippedCount;
  final int incompleteCount;

  int get markedCount {
    return doneCount + failedCount + skippedCount + incompleteCount;
  }

  int get emptyCount {
    return totalDays - markedCount;
  }
}

class HabitWeekSummaryCalculator {
  const HabitWeekSummaryCalculator();

  HabitWeekSummary calculate(List<HabitWeekCell> cells) {
    var doneCount = 0;
    var failedCount = 0;
    var skippedCount = 0;
    var incompleteCount = 0;

    for (final cell in cells) {
      switch (cell.status) {
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

    return HabitWeekSummary(
      totalDays: cells.length,
      doneCount: doneCount,
      failedCount: failedCount,
      skippedCount: skippedCount,
      incompleteCount: incompleteCount,
    );
  }
}
