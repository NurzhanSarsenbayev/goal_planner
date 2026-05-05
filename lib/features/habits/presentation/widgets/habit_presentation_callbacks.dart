import '../../domain/habit.dart';
import '../../domain/habit_entry_status.dart';

typedef HabitCellTapCallback =
    Future<void> Function({
      required String habitId,
      required DateTime date,
      required HabitEntryStatus status,
    });

typedef HabitActionCallback = Future<void> Function(Habit habit);
