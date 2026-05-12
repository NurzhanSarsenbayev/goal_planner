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
}
