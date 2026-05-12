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
  String get habitFabLabel => 'Add habit';

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

  @override
  String get reportsTitle => 'Reports';

  @override
  String get reportsTasksSection => 'Tasks';

  @override
  String get reportsHabitBreakdownSection => 'Habit breakdown';

  @override
  String get reportsGoalContributionSection => 'Goal contribution';

  @override
  String get reportsByDaySection => 'By day';

  @override
  String get reportsNoCompletedTasks => 'No completed tasks in this period.';

  @override
  String reportsEmptyMessage(String periodTitle) {
    return 'No completed tasks or habit marks for $periodTitle yet.';
  }

  @override
  String get reportPeriodToday => 'Today';

  @override
  String get reportPeriodLast7Days => 'Last 7 days';

  @override
  String get reportPeriodLast14Days => 'Last 14 days';

  @override
  String get reportPeriod7DaysShort => '7 days';

  @override
  String get reportPeriod14DaysShort => '14 days';

  @override
  String get reportsCompletedLabel => 'completed';

  @override
  String reportsOutOfPlanned(int plannedCount) {
    return 'out of $plannedCount planned';
  }

  @override
  String get reportsPlanCompletionMetric => 'plan completion';

  @override
  String get reportsActiveDaysMetric => 'active days';

  @override
  String get reportsConsistencyMetric => 'consistency';

  @override
  String get reportsHabitStreakMetric => 'habit streak';

  @override
  String get reportsMissedMetric => 'missed';

  @override
  String get reportsSkippedMetric => 'skipped';

  @override
  String reportsHabitsDoneOnly(int doneCount) {
    return '$doneCount done';
  }

  @override
  String reportsHabitsDoneProgress(int doneCount, int actionableCount) {
    return '$doneCount/$actionableCount done';
  }

  @override
  String get reportsArchivedHabitHistory => 'History from archived habits.';

  @override
  String reportsActiveHabitsNoMarks(int activeHabitCount) {
    return '$activeHabitCount active habits, no marks yet.';
  }

  @override
  String reportsActiveHabitsTracked(int activeHabitCount) {
    return '$activeHabitCount active habits tracked.';
  }

  @override
  String get reportsOneDay => '1 day';

  @override
  String reportsDays(int dayCount) {
    return '$dayCount days';
  }

  @override
  String get reportsDateYesterday => 'Yesterday';

  @override
  String reportsCompletedCount(int count) {
    return '$count completed';
  }

  @override
  String get reportsCompletedTasksSubtitle => 'Completed tasks';

  @override
  String get reportsStandaloneTitle => 'Standalone';

  @override
  String get reportsStandaloneSubtitle =>
      'Completed tasks not linked to a goal';

  @override
  String get reportsNoHabitMarks => 'No habit marks in this period.';

  @override
  String reportsHabitMissedCount(int count) {
    return '$count missed';
  }

  @override
  String reportsHabitSkippedCount(int count) {
    return '$count skipped';
  }

  @override
  String reportsHabitPartialCount(int count) {
    return '$count partial';
  }

  @override
  String get calendarNoTasksForDay => 'No tasks scheduled for this day.';

  @override
  String get calendarAddButton => 'Add';

  @override
  String calendarSelectedDayTitle(String dateTitle) {
    return 'Selected day: $dateTitle';
  }

  @override
  String calendarPastDateWarning(String date) {
    return 'You are creating a task for a past date: $date.';
  }

  @override
  String get calendarOneTimeTaskTitle => 'One-time task';

  @override
  String calendarOneTimeTaskSubtitle(String date) {
    return 'Create a task for $date';
  }

  @override
  String get calendarRecurringTaskTitle => 'Recurring task';

  @override
  String calendarRecurringTaskSubtitle(String date) {
    return 'Create a repeating task starting $date';
  }

  @override
  String get calendarDateToday => 'Today';

  @override
  String get calendarDateTomorrow => 'Tomorrow';

  @override
  String get calendarDateYesterday => 'Yesterday';

  @override
  String get calendarWeekdayMonShort => 'Mon';

  @override
  String get calendarWeekdayTueShort => 'Tue';

  @override
  String get calendarWeekdayWedShort => 'Wed';

  @override
  String get calendarWeekdayThuShort => 'Thu';

  @override
  String get calendarWeekdayFriShort => 'Fri';

  @override
  String get calendarWeekdaySatShort => 'Sat';

  @override
  String get calendarWeekdaySunShort => 'Sun';

  @override
  String get taskCompletionPastTitle => 'When was it completed?';

  @override
  String get taskCompletionTodayOption => 'Today';

  @override
  String get taskCompletionYesterdayOption => 'Yesterday';

  @override
  String taskCompletionScheduledDateOption(String date) {
    return 'Scheduled date: $date';
  }

  @override
  String get taskCompletionFutureTitle => 'Complete early?';

  @override
  String taskCompletionFutureMessage(String date) {
    return 'This task is scheduled for $date.';
  }

  @override
  String get taskCompletionCompleteTodayButton => 'Complete today';

  @override
  String get allTasksTitle => 'All tasks';

  @override
  String get allTasksEmptyDescription => 'No tasks created yet.';

  @override
  String get allTasksTasksSection => 'Tasks';

  @override
  String get allTasksRecurringRulesSection => 'Recurring rules';

  @override
  String taskCardGoalLabel(String goalTitle) {
    return 'Goal: $goalTitle';
  }

  @override
  String get taskCardScheduledToday => 'Scheduled: Today';

  @override
  String taskCardScheduledDate(String date) {
    return 'Scheduled: $date';
  }

  @override
  String get taskCardPlanTodayButton => 'Plan today';

  @override
  String get taskActionRemoveFromToday => 'Remove from Today';

  @override
  String get taskActionAttachToGoal => 'Attach to goal';

  @override
  String get taskActionDetachFromGoal => 'Detach from goal';

  @override
  String get taskActionMoveToMilestone => 'Move to milestone';

  @override
  String get taskActionMoveToDirectGoal => 'Move to Direct tasks';

  @override
  String get taskActionScheduleDate => 'Schedule date';

  @override
  String get taskActionRemoveScheduledDate => 'Remove scheduled date';

  @override
  String get taskDialogAddTitle => 'Add task';

  @override
  String get taskDialogEditTitle => 'Edit task';

  @override
  String get taskDialogAddForTodayTitle => 'Add task for today';

  @override
  String get taskTitleFieldLabel => 'Title';

  @override
  String get taskTitleFieldHint => 'e.g. Write post outline';

  @override
  String get taskDescriptionFieldLabel => 'Description';

  @override
  String get taskDescriptionFieldHint => 'Optional';

  @override
  String get taskGoalFieldLabel => 'Goal';

  @override
  String get taskNoGoalOption => 'No goal';

  @override
  String get taskMilestoneFieldLabel => 'Milestone';

  @override
  String get taskNoMilestoneOption => 'No milestone';

  @override
  String get taskAttachToGoalTitle => 'Attach task to goal';

  @override
  String get taskAttachButton => 'Attach';

  @override
  String get moreToolsSection => 'Tools';

  @override
  String get moreAllTasksSubtitle => 'View all tasks in one place.';

  @override
  String get moreReportsSubtitle => 'Review completed work and goal progress.';

  @override
  String get moreRecurringTasksTitle => 'Recurring tasks';

  @override
  String get moreRecurringTasksSubtitle =>
      'Manage repeated weekday and monthly tasks.';

  @override
  String get goalsEmptyDescription =>
      'No goals yet. Create your first long-term goal.';

  @override
  String get goalDialogAddTitle => 'Add goal';

  @override
  String get goalDialogEditTitle => 'Edit goal';

  @override
  String get goalTitleFieldLabel => 'Title';

  @override
  String get goalTitleFieldHint => 'e.g. Build personal blog';

  @override
  String get goalDescriptionFieldLabel => 'Description';

  @override
  String get goalDescriptionFieldHint => 'Optional';

  @override
  String get goalCardNoTasksYet => 'No tasks yet';

  @override
  String goalCardTasksCompleted(int completedCount, int totalCount) {
    return '$completedCount / $totalCount tasks completed';
  }

  @override
  String get goalDetailsDirectTasksSection => 'Direct tasks';

  @override
  String get goalDetailsNoDirectTasks => 'No direct tasks.';

  @override
  String get goalDetailsDirectRecurringTasksSection => 'Direct recurring tasks';

  @override
  String get goalDetailsAddRecurringButton => 'Add recurring';

  @override
  String get goalDetailsNoDirectRecurringTasks => 'No direct recurring tasks.';

  @override
  String get goalDeleteDialogTitle => 'Delete goal?';

  @override
  String goalDeleteDialogMessage(String goalTitle) {
    return 'This will permanently delete “$goalTitle”.';
  }

  @override
  String goalDeleteDialogMilestonesCount(int count) {
    return 'Milestones: $count';
  }

  @override
  String goalDeleteDialogTasksCount(int count) {
    return 'Tasks: $count';
  }

  @override
  String get goalDeleteDialogTypeDeleteToConfirm => 'Type DELETE to confirm.';

  @override
  String get goalDeleteDialogConfirmationLabel => 'Confirmation';

  @override
  String get goalDeleteDialogDeleteButton => 'Delete goal';

  @override
  String get milestoneDeleteDialogTitle => 'Delete milestone?';

  @override
  String milestoneDeleteDialogEmptyMessage(String milestoneTitle) {
    return 'Delete “$milestoneTitle”?';
  }

  @override
  String milestoneDeleteDialogWithTasksMessage(
    int taskCount,
    String milestoneTitle,
  ) {
    String _temp0 = intl.Intl.pluralLogic(
      taskCount,
      locale: localeName,
      other:
          'This milestone contains $taskCount tasks. Choose what should happen to “$milestoneTitle”.',
      one:
          'This milestone contains 1 task. Choose what should happen to “$milestoneTitle”.',
    );
    return '$_temp0';
  }

  @override
  String get milestoneDeleteDialogMoveTasksToDirectButton =>
      'Move tasks to Direct tasks';

  @override
  String get milestoneDeleteDialogDeleteWithTasksButton =>
      'Delete milestone and tasks';

  @override
  String get milestoneDialogAddTitle => 'Add milestone';

  @override
  String get milestoneDialogEditTitle => 'Edit milestone';

  @override
  String get milestoneTitleFieldLabel => 'Title';

  @override
  String get milestoneTitleFieldHint => 'e.g. Content system';

  @override
  String get milestoneDescriptionFieldLabel => 'Description';

  @override
  String get milestoneDescriptionFieldHint => 'Optional';

  @override
  String get milestonesSectionTitle => 'Milestones';

  @override
  String get milestonesAddButton => 'Add milestone';

  @override
  String get milestonesEmptyTitle => 'No milestones yet';

  @override
  String get milestonesEmptyDescription =>
      'Add milestones to group tasks inside this goal.';

  @override
  String get milestoneCardNoTasksYet => 'No one-off tasks yet';

  @override
  String milestoneCardTasksCompleted(int completedCount, int totalCount) {
    return '$completedCount / $totalCount tasks completed';
  }

  @override
  String get milestoneCardRecurringTasksSection => 'Recurring tasks';

  @override
  String get milestoneCardNoTasksInMilestone =>
      'No tasks in this milestone yet.';

  @override
  String get milestoneCardAddTaskButton => 'Add task';

  @override
  String get milestoneCardAddRecurringButton => 'Add recurring';

  @override
  String get moveTaskToMilestoneDialogTitle => 'Move to milestone';

  @override
  String get moveTaskToMilestoneDialogEmptyMessage =>
      'No milestones available for this goal.';
}
