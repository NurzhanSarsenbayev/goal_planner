import '../../../../shared/planner_dates.dart';
import '../../../habits/application/habit_repository.dart';
import '../../../habits/domain/habit.dart';
import '../../../habits/domain/habit_entry.dart';
import '../../../habits/domain/habit_entry_status.dart';

class HabitReminderPendingChecker {
  const HabitReminderPendingChecker({
    required HabitRepository habitRepository,
    DateTime Function()? todayProvider,
  }) : _habitRepository = habitRepository,
       _todayProvider = todayProvider ?? todayDate;

  final HabitRepository _habitRepository;
  final DateTime Function() _todayProvider;

  Future<bool> shouldNotifyHabitToday(Habit habit) async {
    final today = dateOnly(_todayProvider());

    if (!_canHaveReminder(habit)) {
      return false;
    }

    final entries = await _habitRepository.loadEntriesForRange(
      startDate: today,
      endDate: today,
    );

    return isHabitPendingToday(
      habit: habit,
      habitEntries: entries,
      today: today,
    );
  }

  bool isHabitPendingToday({
    required Habit habit,
    required List<HabitEntry> habitEntries,
    required DateTime today,
  }) {
    if (!_canHaveReminder(habit)) {
      return false;
    }

    final normalizedToday = dateOnly(today);
    final entry = _entryForHabitAndDate(
      habitId: habit.id,
      habitEntries: habitEntries,
      date: normalizedToday,
    );

    if (entry == null) {
      return true;
    }

    return switch (entry.status) {
      HabitEntryStatus.none || HabitEntryStatus.incomplete => true,
      HabitEntryStatus.done ||
      HabitEntryStatus.skipped ||
      HabitEntryStatus.failed => false,
    };
  }

  bool _canHaveReminder(Habit habit) {
    return !habit.isArchived &&
        habit.isReminderEnabled &&
        habit.reminderTimeMinutes != null;
  }

  HabitEntry? _entryForHabitAndDate({
    required String habitId,
    required List<HabitEntry> habitEntries,
    required DateTime date,
  }) {
    for (final entry in habitEntries) {
      if (entry.habitId == habitId && dateOnly(entry.date) == date) {
        return entry;
      }
    }

    return null;
  }
}
