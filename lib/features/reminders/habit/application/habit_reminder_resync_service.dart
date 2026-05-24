import '../../../habits/application/habit_repository.dart';
import '../../../habits/domain/habit.dart';
import 'habit_reminder_scheduler.dart';

class HabitReminderResyncService {
  const HabitReminderResyncService({
    required HabitRepository repository,
    required HabitReminderScheduler scheduler,
  }) : _repository = repository,
       _scheduler = scheduler;

  final HabitRepository _repository;
  final HabitReminderScheduler _scheduler;

  Future<List<Habit>> loadHabits() {
    return _repository.loadHabits();
  }

  Future<void> syncHabitReminders() async {
    final habits = await _repository.loadHabits();

    for (final habit in habits) {
      await _scheduler.syncHabitReminder(habit);
    }
  }

  Future<void> syncAfterHabitSetReplacement({
    required Iterable<Habit> previousHabits,
    required Iterable<Habit> currentHabits,
  }) async {
    final currentHabitIds = currentHabits.map((habit) => habit.id).toSet();

    for (final previousHabit in previousHabits) {
      if (!currentHabitIds.contains(previousHabit.id)) {
        await _scheduler.cancelHabitReminder(previousHabit.id);
      }
    }

    for (final currentHabit in currentHabits) {
      await _scheduler.syncHabitReminder(currentHabit);
    }
  }
}
