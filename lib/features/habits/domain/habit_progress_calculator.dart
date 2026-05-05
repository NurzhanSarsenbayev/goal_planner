import 'habit.dart';
import 'habit_entry_status.dart';
import 'habit_tracking_type.dart';

class HabitProgressCalculator {
  const HabitProgressCalculator();

  HabitEntryStatus statusForProgress({
    required Habit habit,
    required int completedCount,
    HabitEntryStatus? explicitStatus,
  }) {
    final manualStatus = explicitStatus;

    if (manualStatus == HabitEntryStatus.failed ||
        manualStatus == HabitEntryStatus.skipped) {
      return manualStatus!;
    }

    if (habit.trackingType == HabitTrackingType.binary) {
      return manualStatus ?? HabitEntryStatus.none;
    }

    final targetCount = habit.targetCount;

    if (targetCount == null || targetCount <= 0) {
      return manualStatus ?? HabitEntryStatus.none;
    }

    if (completedCount >= targetCount) {
      return HabitEntryStatus.done;
    }

    if (completedCount > 0) {
      return HabitEntryStatus.incomplete;
    }

    return manualStatus ?? HabitEntryStatus.none;
  }
}
