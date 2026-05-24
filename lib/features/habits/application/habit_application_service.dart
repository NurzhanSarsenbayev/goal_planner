import '../domain/habit.dart';
import '../domain/habit_entry.dart';
import '../domain/habit_entry_status.dart';
import '../domain/habit_progress_calculator.dart';
import '../domain/habit_tracking_type.dart';

class HabitMutationResult {
  const HabitMutationResult({
    required this.habits,
    this.habitToPersist,
    this.habitIdToDelete,
  });

  final List<Habit> habits;
  final Habit? habitToPersist;
  final String? habitIdToDelete;

  bool get hasChange => habitToPersist != null || habitIdToDelete != null;
}

class HabitEntryMutationResult {
  const HabitEntryMutationResult({
    required this.entries,
    this.entryToPersist,
    this.entryIdToDelete,
  });

  final List<HabitEntry> entries;
  final HabitEntry? entryToPersist;
  final String? entryIdToDelete;

  bool get hasChange => entryToPersist != null || entryIdToDelete != null;
}

class HabitApplicationService {
  const HabitApplicationService({
    HabitProgressCalculator progressCalculator =
        const HabitProgressCalculator(),
  }) : _progressCalculator = progressCalculator;

  final HabitProgressCalculator _progressCalculator;

  HabitMutationResult createHabit({
    required List<Habit> habits,
    required String title,
    required String description,
    HabitTrackingType trackingType = HabitTrackingType.binary,
    int? targetCount,
    DateTime? now,
  }) {
    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();

    if (normalizedTitle.isEmpty) {
      return HabitMutationResult(habits: habits);
    }

    final timestamp = now ?? DateTime.now();
    final nextSortOrder = _nextSortOrder(habits);

    final habit = Habit(
      id: _newId(),
      title: normalizedTitle,
      description: normalizedDescription,
      trackingType: trackingType,
      targetCount: _normalizedTargetCount(
        trackingType: trackingType,
        targetCount: targetCount,
      ),
      sortOrder: nextSortOrder,
      isArchived: false,
      createdAt: timestamp,
      updatedAt: timestamp,
    );

    return HabitMutationResult(
      habits: [...habits, habit],
      habitToPersist: habit,
    );
  }

  HabitMutationResult updateHabit({
    required List<Habit> habits,
    required String habitId,
    required String title,
    required String description,
    HabitTrackingType? trackingType,
    int? targetCount,
    DateTime? now,
  }) {
    final index = habits.indexWhere((habit) => habit.id == habitId);

    if (index == -1) {
      return HabitMutationResult(habits: habits);
    }

    final normalizedTitle = title.trim();
    final normalizedDescription = description.trim();

    if (normalizedTitle.isEmpty) {
      return HabitMutationResult(habits: habits);
    }

    final current = habits[index];
    final nextTrackingType = trackingType ?? current.trackingType;

    final updated = current.copyWith(
      title: normalizedTitle,
      description: normalizedDescription,
      trackingType: nextTrackingType,
      targetCount: _normalizedTargetCount(
        trackingType: nextTrackingType,
        targetCount: targetCount ?? current.targetCount,
      ),
      updatedAt: now ?? DateTime.now(),
    );

    final updatedHabits = [...habits];
    updatedHabits[index] = updated;

    return HabitMutationResult(habits: updatedHabits, habitToPersist: updated);
  }

  HabitMutationResult updateHabitReminder({
    required List<Habit> habits,
    required String habitId,
    required bool isReminderEnabled,
    required int? reminderTimeMinutes,
    DateTime? now,
  }) {
    final index = habits.indexWhere((habit) => habit.id == habitId);

    if (index == -1) {
      return HabitMutationResult(habits: habits);
    }

    if (isReminderEnabled && reminderTimeMinutes == null) {
      return HabitMutationResult(habits: habits);
    }

    if (!_isValidReminderTimeMinutes(reminderTimeMinutes)) {
      return HabitMutationResult(habits: habits);
    }

    final current = habits[index];
    final updated = current.copyWith(
      isReminderEnabled: isReminderEnabled,
      reminderTimeMinutes: isReminderEnabled ? reminderTimeMinutes : null,
      updatedAt: now ?? DateTime.now(),
    );

    final updatedHabits = [...habits];
    updatedHabits[index] = updated;

    return HabitMutationResult(habits: updatedHabits, habitToPersist: updated);
  }

  HabitMutationResult archiveHabit({
    required List<Habit> habits,
    required String habitId,
    DateTime? now,
  }) {
    final index = habits.indexWhere((habit) => habit.id == habitId);

    if (index == -1) {
      return HabitMutationResult(habits: habits);
    }

    final current = habits[index];

    if (current.isArchived) {
      return HabitMutationResult(habits: habits);
    }

    final archived = current.copyWith(
      isArchived: true,
      updatedAt: now ?? DateTime.now(),
    );

    final updatedHabits = [...habits];
    updatedHabits[index] = archived;

    return HabitMutationResult(habits: updatedHabits, habitToPersist: archived);
  }

  HabitMutationResult unarchiveHabit({
    required List<Habit> habits,
    required String habitId,
    DateTime? now,
  }) {
    final index = habits.indexWhere((habit) => habit.id == habitId);

    if (index == -1) {
      return HabitMutationResult(habits: habits);
    }

    final current = habits[index];

    if (!current.isArchived) {
      return HabitMutationResult(habits: habits);
    }

    final unarchived = current.copyWith(
      isArchived: false,
      updatedAt: now ?? DateTime.now(),
    );

    final updatedHabits = [...habits];
    updatedHabits[index] = unarchived;

    return HabitMutationResult(
      habits: updatedHabits,
      habitToPersist: unarchived,
    );
  }

  HabitMutationResult deleteHabit({
    required List<Habit> habits,
    required String habitId,
  }) {
    final exists = habits.any((habit) => habit.id == habitId);

    if (!exists) {
      return HabitMutationResult(habits: habits);
    }

    return HabitMutationResult(
      habits: [
        for (final habit in habits)
          if (habit.id != habitId) habit,
      ],
      habitIdToDelete: habitId,
    );
  }

  HabitEntryMutationResult markEntry({
    required List<HabitEntry> entries,
    required Habit habit,
    required DateTime date,
    required HabitEntryStatus status,
    int completedCount = 0,
    DateTime? now,
  }) {
    final effectiveCompletedCount = _completedCountForStatus(
      habit: habit,
      status: status,
      completedCount: completedCount,
    );

    final effectiveStatus = _progressCalculator.statusForProgress(
      habit: habit,
      completedCount: effectiveCompletedCount,
      explicitStatus: status,
    );

    final timestamp = now ?? DateTime.now();
    final index = entries.indexWhere(
      (entry) => entry.habitId == habit.id && _isSameDate(entry.date, date),
    );

    if (index == -1) {
      final entry = HabitEntry(
        id: _newId(),
        habitId: habit.id,
        date: date,
        status: effectiveStatus,
        completedCount: effectiveCompletedCount,
        createdAt: timestamp,
        updatedAt: timestamp,
      );

      return HabitEntryMutationResult(
        entries: [...entries, entry],
        entryToPersist: entry,
      );
    }

    final current = entries[index];
    final updated = current.copyWith(
      status: effectiveStatus,
      completedCount: effectiveCompletedCount,
      updatedAt: timestamp,
    );

    final updatedEntries = [...entries];
    updatedEntries[index] = updated;

    return HabitEntryMutationResult(
      entries: updatedEntries,
      entryToPersist: updated,
    );
  }

  HabitEntryMutationResult clearEntry({
    required List<HabitEntry> entries,
    required String habitId,
    required DateTime date,
  }) {
    final index = entries.indexWhere(
      (entry) => entry.habitId == habitId && _isSameDate(entry.date, date),
    );

    if (index == -1) {
      return HabitEntryMutationResult(entries: entries);
    }

    final entryId = entries[index].id;

    return HabitEntryMutationResult(
      entries: [
        for (final entry in entries)
          if (entry.id != entryId) entry,
      ],
      entryIdToDelete: entryId,
    );
  }

  int _nextSortOrder(List<Habit> habits) {
    if (habits.isEmpty) {
      return 0;
    }

    final maxSortOrder = habits
        .map((habit) => habit.sortOrder)
        .reduce((max, value) => value > max ? value : max);

    return maxSortOrder + 1;
  }

  int? _normalizedTargetCount({
    required HabitTrackingType trackingType,
    required int? targetCount,
  }) {
    if (trackingType == HabitTrackingType.binary) {
      return null;
    }

    if (targetCount == null || targetCount <= 0) {
      return 1;
    }

    return targetCount;
  }

  int _completedCountForStatus({
    required Habit habit,
    required HabitEntryStatus status,
    required int completedCount,
  }) {
    if (status == HabitEntryStatus.done) {
      return habit.targetCount ?? 1;
    }

    if (status == HabitEntryStatus.failed ||
        status == HabitEntryStatus.skipped ||
        status == HabitEntryStatus.none) {
      return 0;
    }

    return completedCount < 0 ? 0 : completedCount;
  }

  bool _isValidReminderTimeMinutes(int? reminderTimeMinutes) {
    return reminderTimeMinutes == null ||
        reminderTimeMinutes >= 0 && reminderTimeMinutes < 24 * 60;
  }

  bool _isSameDate(DateTime left, DateTime right) {
    return left.year == right.year &&
        left.month == right.month &&
        left.day == right.day;
  }

  String _newId() {
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
