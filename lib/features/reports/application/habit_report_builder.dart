import '../../../shared/planner_dates.dart';
import '../../habits/domain/habit.dart';
import '../../habits/domain/habit_entry.dart';
import '../domain/habit_report_summary.dart';
import '../domain/report_period.dart';

HabitReportSummary buildHabitReportSummary({
  required List<Habit> habits,
  required List<HabitEntry> entries,
  required ReportPeriod period,
  required DateTime today,
}) {
  final endDate = dateOnly(today);
  final startDate = period.startDate(endDate);
  final habitsById = {for (final habit in habits) habit.id: habit};

  final trackedEntries =
      entries.where((entry) {
        return entry.status.isExplicitMark &&
            habitsById.containsKey(entry.habitId) &&
            _isInsidePeriod(
              date: entry.date,
              startDate: startDate,
              endDate: endDate,
            );
      }).toList()..sort((first, second) {
        return second.date.compareTo(first.date);
      });

  final activeHabits = [
    for (final habit in habits)
      if (!habit.isArchived) habit,
  ];

  final includedHabitIds = <String>{
    for (final habit in activeHabits) habit.id,
    for (final entry in trackedEntries) entry.habitId,
  };

  final sortedHabits =
      [
        for (final habit in habits)
          if (includedHabitIds.contains(habit.id)) habit,
      ]..sort((first, second) {
        final sortOrderComparison = first.sortOrder.compareTo(second.sortOrder);

        if (sortOrderComparison != 0) {
          return sortOrderComparison;
        }

        return first.title.compareTo(second.title);
      });

  return HabitReportSummary(
    period: period,
    startDate: startDate,
    endDate: endDate,
    activeHabitCount: activeHabits.length,
    habitGroups: [
      for (final habit in sortedHabits)
        HabitReportGroup(
          habit: habit,
          entries: [
            for (final entry in trackedEntries)
              if (entry.habitId == habit.id) entry,
          ],
          expectedMarkCount: _expectedMarkCountForHabit(
            habit: habit,
            startDate: startDate,
            endDate: endDate,
          ),
        ),
    ],
    dayGroups: _groupEntriesByDay(trackedEntries),
  );
}

bool _isInsidePeriod({
  required DateTime date,
  required DateTime startDate,
  required DateTime endDate,
}) {
  return !date.isBefore(startDate) && !date.isAfter(endDate);
}

int _expectedMarkCountForHabit({
  required Habit habit,
  required DateTime startDate,
  required DateTime endDate,
}) {
  if (habit.isArchived) {
    return 0;
  }

  final createdDate = dateOnly(habit.createdAt);
  final firstExpectedDate = createdDate.isAfter(startDate)
      ? createdDate
      : startDate;

  if (firstExpectedDate.isAfter(endDate)) {
    return 0;
  }

  return endDate.difference(firstExpectedDate).inDays + 1;
}

List<HabitDayReportGroup> _groupEntriesByDay(List<HabitEntry> entries) {
  final groups = <HabitDayReportGroup>[];

  for (final entry in entries) {
    if (groups.isEmpty || groups.last.date != entry.date) {
      groups.add(HabitDayReportGroup(date: entry.date, entries: [entry]));
    } else {
      groups.last.entries.add(entry);
    }
  }

  return groups;
}
