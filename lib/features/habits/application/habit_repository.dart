import '../domain/habit.dart';
import '../domain/habit_entry.dart';

abstract interface class HabitRepository {
  Future<List<Habit>> loadHabits();

  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  });

  Future<void> saveHabit(Habit habit);

  Future<void> saveEntry(HabitEntry entry);

  Future<void> deleteEntry(String entryId);

  Future<void> deleteHabit(String habitId);
}
