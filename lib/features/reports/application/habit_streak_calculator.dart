import '../../../shared/planner_dates.dart';
import '../../habits/domain/habit.dart';
import '../../habits/domain/habit_entry.dart';
import '../../habits/domain/habit_entry_status.dart';

int calculateCurrentHabitStreakDays({
  required List<Habit> habits,
  required List<HabitEntry> entries,
  required DateTime startDate,
  required DateTime endDate,
}) {
  final normalizedStartDate = dateOnly(startDate);
  final normalizedEndDate = dateOnly(endDate);

  if (normalizedEndDate.isBefore(normalizedStartDate)) {
    return 0;
  }

  final entriesByHabitAndDate = <String, HabitEntry>{
    for (final entry in entries) _entryKey(entry.habitId, entry.date): entry,
  };

  var streakDays = 0;
  var cursorDate = normalizedEndDate;

  while (!cursorDate.isBefore(normalizedStartDate)) {
    final dayState = _habitStreakDayState(
      habits: habits,
      entriesByHabitAndDate: entriesByHabitAndDate,
      date: cursorDate,
      isToday: cursorDate == normalizedEndDate,
    );

    switch (dayState) {
      case _HabitStreakDayState.success:
        streakDays += 1;
      case _HabitStreakDayState.neutral:
      case _HabitStreakDayState.pending:
        break;
      case _HabitStreakDayState.failed:
        return streakDays;
    }

    cursorDate = cursorDate.subtract(const Duration(days: 1));
  }

  return streakDays;
}

_HabitStreakDayState _habitStreakDayState({
  required List<Habit> habits,
  required Map<String, HabitEntry> entriesByHabitAndDate,
  required DateTime date,
  required bool isToday,
}) {
  final expectedHabits = [
    for (final habit in habits)
      if (_isHabitExpectedOnDate(habit: habit, date: date)) habit,
  ];

  if (expectedHabits.isEmpty) {
    return _HabitStreakDayState.neutral;
  }

  var hasCompletion = false;
  var hasPendingMark = false;

  for (final habit in expectedHabits) {
    final entry = entriesByHabitAndDate[_entryKey(habit.id, date)];
    final status = entry?.status ?? HabitEntryStatus.none;

    if (status.countsAsFailure) {
      return _HabitStreakDayState.failed;
    }

    if (status.countsAsCompletion) {
      hasCompletion = true;
      continue;
    }

    if (status.isSkipped) {
      continue;
    }

    if (isToday) {
      hasPendingMark = true;
      continue;
    }

    return _HabitStreakDayState.failed;
  }

  if (hasPendingMark) {
    return _HabitStreakDayState.pending;
  }

  if (hasCompletion) {
    return _HabitStreakDayState.success;
  }

  return _HabitStreakDayState.neutral;
}

bool _isHabitExpectedOnDate({required Habit habit, required DateTime date}) {
  if (habit.isArchived) {
    return false;
  }

  return !date.isBefore(dateOnly(habit.createdAt));
}

String _entryKey(String habitId, DateTime date) {
  return '$habitId|${dateOnly(date).toIso8601String()}';
}

enum _HabitStreakDayState { success, failed, neutral, pending }
