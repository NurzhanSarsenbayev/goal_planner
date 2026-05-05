import '../../../shared/planner_dates.dart';
import '../domain/habit.dart';
import '../domain/habit_entry.dart';
import '../domain/habit_entry_status.dart';

class HabitWeekView {
  const HabitWeekView({
    required this.weekStart,
    required this.dates,
    required this.rows,
  });

  final DateTime weekStart;
  final List<DateTime> dates;
  final List<HabitWeekRow> rows;
}

class HabitWeekRow {
  const HabitWeekRow({required this.habit, required this.cells});

  final Habit habit;
  final List<HabitWeekCell> cells;
}

class HabitWeekCell {
  const HabitWeekCell({required this.date, required this.status, this.entry});

  final DateTime date;
  final HabitEntryStatus status;
  final HabitEntry? entry;

  bool get hasEntry => entry != null;
}

class HabitWeekViewBuilder {
  const HabitWeekViewBuilder();

  HabitWeekView build({
    required List<Habit> habits,
    required List<HabitEntry> entries,
    required DateTime weekStart,
  }) {
    final normalizedWeekStart = dateOnly(weekStart);
    final dates = List.generate(
      7,
      (index) => normalizedWeekStart.add(Duration(days: index)),
    );

    final activeHabits = [
      for (final habit in habits)
        if (!habit.isArchived) habit,
    ]..sort(_compareHabits);

    final entriesByHabitAndDate = _indexEntries(entries);

    final rows = [
      for (final habit in activeHabits)
        HabitWeekRow(
          habit: habit,
          cells: [
            for (final date in dates)
              _buildCell(
                habitId: habit.id,
                date: date,
                entriesByHabitAndDate: entriesByHabitAndDate,
              ),
          ],
        ),
    ];

    return HabitWeekView(
      weekStart: normalizedWeekStart,
      dates: dates,
      rows: rows,
    );
  }

  HabitWeekCell _buildCell({
    required String habitId,
    required DateTime date,
    required Map<String, HabitEntry> entriesByHabitAndDate,
  }) {
    final entry =
        entriesByHabitAndDate[_entryKey(habitId: habitId, date: date)];

    return HabitWeekCell(
      date: date,
      status: entry?.status ?? HabitEntryStatus.none,
      entry: entry,
    );
  }

  Map<String, HabitEntry> _indexEntries(List<HabitEntry> entries) {
    final result = <String, HabitEntry>{};

    for (final entry in entries) {
      result[_entryKey(habitId: entry.habitId, date: entry.date)] = entry;
    }

    return result;
  }

  String _entryKey({required String habitId, required DateTime date}) {
    final normalizedDate = dateOnly(date);

    return '$habitId:${normalizedDate.toIso8601String()}';
  }

  int _compareHabits(Habit left, Habit right) {
    final sortOrderComparison = left.sortOrder.compareTo(right.sortOrder);

    if (sortOrderComparison != 0) {
      return sortOrderComparison;
    }

    return left.createdAt.compareTo(right.createdAt);
  }
}
