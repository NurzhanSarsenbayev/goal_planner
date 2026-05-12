// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Goal Planner';

  @override
  String get todayTab => 'Today';

  @override
  String get goalsTab => 'Goals';

  @override
  String get calendarTab => 'Calendar';

  @override
  String get habitsTab => 'Habits';

  @override
  String get moreTab => 'More';

  @override
  String get todayOneTimeTaskTitle => 'One-time task';

  @override
  String get todayOneTimeTaskSubtitle => 'Create a task for today';

  @override
  String get todayRecurringTaskTitle => 'Recurring task';

  @override
  String get todayRecurringTaskSubtitle => 'Create a task that repeats';

  @override
  String get todayAddTaskButton => 'Add task';

  @override
  String get todayOverdueSection => 'Overdue';

  @override
  String get todayTodoSection => 'To do today';

  @override
  String get todayDoneSection => 'Done today';

  @override
  String get todayNoTasksLeft => 'No tasks left for today.';

  @override
  String get todaySummaryTodo => 'To do';

  @override
  String get todaySummaryOverdue => 'Overdue';

  @override
  String get todaySummaryDone => 'Done';

  @override
  String get todaySummaryNothingPlanned =>
      'Nothing planned yet. Add one small task to start the day.';

  @override
  String get todaySummaryAllDone => 'All planned tasks are done for today.';

  @override
  String get todaySummaryHandleOverdue =>
      'Handle overdue tasks first, then continue with today.';

  @override
  String get todaySummaryFocus => 'Focus on today’s planned tasks.';

  @override
  String get todayHabitsTitle => 'Habits today';

  @override
  String todayHabitsDoneOnly(int doneCount) {
    return 'Done: $doneCount';
  }

  @override
  String todayHabitsDoneProgress(int doneCount, int actionableCount) {
    return '$doneCount/$actionableCount done';
  }

  @override
  String todayHabitsMissedCount(int count) {
    return 'Missed: $count';
  }

  @override
  String todayHabitsSkippedCount(int count) {
    return 'Skipped: $count';
  }

  @override
  String todayHabitsPartialCount(int count) {
    return 'Partial: $count';
  }

  @override
  String todayHabitsNotMarkedCount(int count) {
    return 'Not marked: $count';
  }

  @override
  String get todayHabitsAllMarked => 'All habits are marked for today.';

  @override
  String get todayEmptyTitle => 'Plan today lightly';

  @override
  String get todayEmptyDescription =>
      'Add one task that would make today feel a little more under control.';

  @override
  String get todayPlanTodayButton => 'Plan today';

  @override
  String get todayEmptySectionFallback => 'Nothing here.';

  @override
  String get commonCancel => 'Cancel';

  @override
  String get commonAdd => 'Add';

  @override
  String get commonSave => 'Save';

  @override
  String get commonEdit => 'Edit';

  @override
  String get commonArchive => 'Archive';

  @override
  String get commonDelete => 'Delete';

  @override
  String get habitsTitle => 'Habits';

  @override
  String get habitsArchivedTooltip => 'Archived habits';

  @override
  String get habitFabLabel => 'Habit';

  @override
  String get habitsEmptyTitle => 'Start tracking a small routine';

  @override
  String get habitsEmptyDescription =>
      'Pick something simple that you want to notice every week.';

  @override
  String get habitsEmptyButton => 'Create first habit';

  @override
  String get habitsAllArchivedTitle => 'All habits are archived';

  @override
  String get habitsAllArchivedDescription =>
      'Create a new habit or restore an archived one.';

  @override
  String get habitsAllArchivedCreateButton => 'Create new habit';

  @override
  String get habitsAllArchivedViewArchivedButton => 'View archived habits';

  @override
  String get habitExampleDrinkWater => 'Drink water';

  @override
  String get habitExampleRead => 'Read 10 minutes';

  @override
  String get habitExampleWalk => 'Walk';

  @override
  String get habitExampleStretch => 'Stretch';

  @override
  String get habitExampleSleep => 'Sleep before midnight';

  @override
  String get habitAddDialogTitle => 'Add habit';

  @override
  String get habitEditDialogTitle => 'Edit habit';

  @override
  String get habitTitleFieldLabel => 'Title';

  @override
  String get habitTitleFieldHint => 'e.g. Drink water';

  @override
  String get habitDescriptionFieldLabel => 'Description';

  @override
  String get habitDescriptionFieldHint => 'Optional';

  @override
  String get habitArchiveDialogTitle => 'Archive habit?';

  @override
  String habitArchiveDialogMessage(String title) {
    return '“$title” will be hidden from the active habit list.';
  }

  @override
  String get habitDeleteDialogTitle => 'Delete habit?';

  @override
  String habitDeleteDialogMessage(String title) {
    return '“$title” and its tracked entries will be deleted.';
  }

  @override
  String get habitStatusSheetTitle => 'How did it go?';

  @override
  String get habitStatusDone => 'Done';

  @override
  String get habitStatusMissed => 'Missed';

  @override
  String get habitStatusSkip => 'Skip';

  @override
  String get habitStatusClear => 'Clear';

  @override
  String get habitActionsTooltip => 'Habit actions';

  @override
  String get habitCurrentWeek => 'Current week';

  @override
  String get habitWeekdayMon => 'Mon';

  @override
  String get habitWeekdayTue => 'Tue';

  @override
  String get habitWeekdayWed => 'Wed';

  @override
  String get habitWeekdayThu => 'Thu';

  @override
  String get habitWeekdayFri => 'Fri';

  @override
  String get habitWeekdaySat => 'Sat';

  @override
  String get habitWeekdaySun => 'Sun';

  @override
  String habitWeekSummaryDone(int doneCount, int totalDays) {
    return '$doneCount/$totalDays done';
  }

  @override
  String habitWeekSummaryMissed(int count) {
    return '$count missed';
  }

  @override
  String habitWeekSummarySkipped(int count) {
    return '$count skipped';
  }

  @override
  String habitWeekSummaryPartial(int count) {
    return '$count partial';
  }

  @override
  String get archivedHabitsTitle => 'Archived habits';

  @override
  String get archivedHabitsEmpty => 'No archived habits.';

  @override
  String get archivedHabitRestoreTooltip => 'Restore habit';

  @override
  String get archivedHabitDeleteTooltip => 'Delete habit';
}
