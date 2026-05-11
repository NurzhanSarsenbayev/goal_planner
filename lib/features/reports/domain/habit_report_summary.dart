import '../../../features/habits/domain/habit.dart';
import '../../../features/habits/domain/habit_entry.dart';
import 'report_period.dart';

class HabitReportSummary {
  const HabitReportSummary({
    required this.period,
    required this.startDate,
    required this.endDate,
    required this.activeHabitCount,
    required this.currentStreakDays,
    required this.habitGroups,
    required this.dayGroups,
  });

  final ReportPeriod period;
  final DateTime startDate;
  final DateTime endDate;
  final int activeHabitCount;
  final int currentStreakDays;
  final List<HabitReportGroup> habitGroups;
  final List<HabitDayReportGroup> dayGroups;

  int get expectedMarkCount {
    return habitGroups.fold(
      0,
      (total, group) => total + group.expectedMarkCount,
    );
  }

  int get doneCount {
    return habitGroups.fold(0, (total, group) => total + group.doneCount);
  }

  int get missedCount {
    return habitGroups.fold(0, (total, group) => total + group.missedCount);
  }

  int get skippedCount {
    return habitGroups.fold(0, (total, group) => total + group.skippedCount);
  }

  int get partialCount {
    return habitGroups.fold(0, (total, group) => total + group.partialCount);
  }

  int get markedCount {
    return doneCount + missedCount + skippedCount + partialCount;
  }

  int get actionableExpectedMarkCount {
    final count = expectedMarkCount - skippedCount;

    if (count < 0) {
      return 0;
    }

    return count;
  }

  int get consistencyPercent {
    if (actionableExpectedMarkCount == 0) {
      return 0;
    }

    return ((doneCount / actionableExpectedMarkCount) * 100).round();
  }

  bool get hasHabitData {
    return activeHabitCount > 0 || markedCount > 0;
  }
}

class HabitReportGroup {
  const HabitReportGroup({
    required this.habit,
    required this.entries,
    required this.expectedMarkCount,
  });

  final Habit habit;
  final List<HabitEntry> entries;
  final int expectedMarkCount;

  int get doneCount {
    return entries.where((entry) => entry.status.countsAsCompletion).length;
  }

  int get missedCount {
    return entries.where((entry) => entry.status.countsAsFailure).length;
  }

  int get skippedCount {
    return entries.where((entry) => entry.status.isSkipped).length;
  }

  int get partialCount {
    return entries.where((entry) => entry.status.isPartial).length;
  }

  int get actionableExpectedMarkCount {
    final count = expectedMarkCount - skippedCount;

    if (count < 0) {
      return 0;
    }

    return count;
  }

  int get consistencyPercent {
    if (actionableExpectedMarkCount == 0) {
      return 0;
    }

    return ((doneCount / actionableExpectedMarkCount) * 100).round();
  }
}

class HabitDayReportGroup {
  const HabitDayReportGroup({required this.date, required this.entries});

  final DateTime date;
  final List<HabitEntry> entries;
}
