// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Russian (`ru`).
class AppLocalizationsRu extends AppLocalizations {
  AppLocalizationsRu([String locale = 'ru']) : super(locale);

  @override
  String get appTitle => 'Планировщик целей';

  @override
  String get todayTab => 'Сегодня';

  @override
  String get goalsTab => 'Цели';

  @override
  String get calendarTab => 'Календарь';

  @override
  String get habitsTab => 'Привычки';

  @override
  String get moreTab => 'Ещё';

  @override
  String get todayOneTimeTaskTitle => 'Разовая задача';

  @override
  String get todayOneTimeTaskSubtitle => 'Создать задачу на сегодня';

  @override
  String get todayRecurringTaskTitle => 'Повторяющаяся задача';

  @override
  String get todayRecurringTaskSubtitle =>
      'Создать задачу, которая повторяется';

  @override
  String get todayAddTaskButton => 'Добавить задачу';

  @override
  String get todayOverdueSection => 'Просроченные задачи';

  @override
  String get todayTodoSection => 'На сегодня';

  @override
  String get todayDoneSection => 'Сделано сегодня';

  @override
  String get todayNoTasksLeft => 'На сегодня задач не осталось.';

  @override
  String get todaySummaryTodo => 'Сделать';

  @override
  String get todaySummaryOverdue => 'Просрочено';

  @override
  String get todaySummaryDone => 'Сделано';

  @override
  String get todaySummaryNothingPlanned =>
      'Пока ничего не запланировано. Добавьте одну небольшую задачу, чтобы начать день.';

  @override
  String get todaySummaryAllDone =>
      'Все запланированные задачи на сегодня выполнены.';

  @override
  String get todaySummaryHandleOverdue =>
      'Сначала разберите просроченные задачи, потом продолжайте сегодняшний план.';

  @override
  String get todaySummaryFocus =>
      'Сфокусируйтесь на задачах, запланированных на сегодня.';

  @override
  String get todayHabitsTitle => 'Привычки';

  @override
  String todayHabitsDoneOnly(int doneCount) {
    return 'Сделано: $doneCount';
  }

  @override
  String todayHabitsDoneProgress(int doneCount, int actionableCount) {
    return 'Сделано: $doneCount/$actionableCount';
  }

  @override
  String todayHabitsMissedCount(int count) {
    return 'Пропущено: $count';
  }

  @override
  String todayHabitsSkippedCount(int count) {
    return 'Осознанно пропущено: $count';
  }

  @override
  String todayHabitsPartialCount(int count) {
    return 'Частично: $count';
  }

  @override
  String todayHabitsNotMarkedCount(int count) {
    return 'Не отмечено: $count';
  }

  @override
  String get todayHabitsAllMarked => 'Все привычки на сегодня отмечены.';

  @override
  String get todayEmptyTitle => 'Спланируйте день спокойно';

  @override
  String get todayEmptyDescription =>
      'Добавьте одну задачу, которая поможет почувствовать, что день под контролем.';

  @override
  String get todayPlanTodayButton => 'Запланировать день';

  @override
  String get todayEmptySectionFallback => 'Здесь пока ничего нет.';

  @override
  String get commonCancel => 'Отмена';

  @override
  String get commonAdd => 'Добавить';

  @override
  String get commonSave => 'Сохранить';

  @override
  String get commonEdit => 'Изменить';

  @override
  String get commonArchive => 'В архив';

  @override
  String get commonDelete => 'Удалить';

  @override
  String get habitsTitle => 'Привычки';

  @override
  String get habitsArchivedTooltip => 'Архив привычек';

  @override
  String get habitFabLabel => 'Добавить привычку';

  @override
  String get habitsEmptyTitle => 'Начните с простой привычки';

  @override
  String get habitsEmptyDescription =>
      'Выберите что-то небольшое, что хотите отслеживать каждую неделю.';

  @override
  String get habitsEmptyButton => 'Создать первую привычку';

  @override
  String get habitsAllArchivedTitle => 'Все привычки в архиве';

  @override
  String get habitsAllArchivedDescription =>
      'Создайте новую привычку или восстановите одну из архива.';

  @override
  String get habitsAllArchivedCreateButton => 'Создать новую привычку';

  @override
  String get habitsAllArchivedViewArchivedButton => 'Показать архив';

  @override
  String get habitExampleDrinkWater => 'Пить воду';

  @override
  String get habitExampleRead => 'Читать 10 минут';

  @override
  String get habitExampleWalk => 'Гулять';

  @override
  String get habitExampleStretch => 'Растяжка';

  @override
  String get habitExampleSleep => 'Лечь до полуночи';

  @override
  String get habitAddDialogTitle => 'Добавить привычку';

  @override
  String get habitEditDialogTitle => 'Изменить привычку';

  @override
  String get habitTitleFieldLabel => 'Название';

  @override
  String get habitTitleFieldHint => 'Например: пить воду';

  @override
  String get habitDescriptionFieldLabel => 'Описание';

  @override
  String get habitDescriptionFieldHint => 'Необязательно';

  @override
  String get habitArchiveDialogTitle => 'Убрать привычку в архив?';

  @override
  String habitArchiveDialogMessage(String title) {
    return '«$title» будет скрыта из списка активных привычек.';
  }

  @override
  String get habitDeleteDialogTitle => 'Удалить привычку?';

  @override
  String habitDeleteDialogMessage(String title) {
    return '«$title» и все отметки по ней будут удалены.';
  }

  @override
  String get habitStatusSheetTitle => 'Как прошло?';

  @override
  String get habitStatusDone => 'Сделано';

  @override
  String get habitStatusMissed => 'Не сделано';

  @override
  String get habitStatusSkip => 'Пропустить';

  @override
  String get habitStatusClear => 'Очистить';

  @override
  String get habitActionsTooltip => 'Действия с привычкой';

  @override
  String get habitCurrentWeek => 'Текущая неделя';

  @override
  String get habitWeekdayMon => 'Пн';

  @override
  String get habitWeekdayTue => 'Вт';

  @override
  String get habitWeekdayWed => 'Ср';

  @override
  String get habitWeekdayThu => 'Чт';

  @override
  String get habitWeekdayFri => 'Пт';

  @override
  String get habitWeekdaySat => 'Сб';

  @override
  String get habitWeekdaySun => 'Вс';

  @override
  String habitWeekSummaryDone(int doneCount, int totalDays) {
    return '$doneCount/$totalDays сделано';
  }

  @override
  String habitWeekSummaryMissed(int count) {
    return '$count не сделано';
  }

  @override
  String habitWeekSummarySkipped(int count) {
    return '$count пропущено';
  }

  @override
  String habitWeekSummaryPartial(int count) {
    return '$count частично';
  }

  @override
  String get archivedHabitsTitle => 'Архив привычек';

  @override
  String get archivedHabitsEmpty => 'В архиве пока нет привычек.';

  @override
  String get archivedHabitRestoreTooltip => 'Восстановить привычку';

  @override
  String get archivedHabitDeleteTooltip => 'Удалить привычку';

  @override
  String get reportsTitle => 'Отчёты';

  @override
  String get reportsTasksSection => 'Задачи';

  @override
  String get reportsHabitBreakdownSection => 'Разбор привычек';

  @override
  String get reportsGoalContributionSection => 'Вклад в цели';

  @override
  String get reportsByDaySection => 'По дням';

  @override
  String get reportsNoCompletedTasks => 'За этот период выполненных задач нет.';

  @override
  String reportsEmptyMessage(String periodTitle) {
    return 'За период «$periodTitle» пока нет выполненных задач или отметок привычек.';
  }

  @override
  String get reportPeriodToday => 'Сегодня';

  @override
  String get reportPeriodLast7Days => 'Последние 7 дней';

  @override
  String get reportPeriodLast14Days => 'Последние 14 дней';

  @override
  String get reportPeriod7DaysShort => '7 дней';

  @override
  String get reportPeriod14DaysShort => '14 дней';

  @override
  String get reportsCompletedLabel => 'выполнено';

  @override
  String reportsOutOfPlanned(int plannedCount) {
    return 'из $plannedCount запланированных';
  }

  @override
  String get reportsPlanCompletionMetric => 'выполнение плана';

  @override
  String get reportsActiveDaysMetric => 'активные дни';

  @override
  String get reportsConsistencyMetric => 'регулярность';

  @override
  String get reportsHabitStreakMetric => 'серия привычек';

  @override
  String get reportsMissedMetric => 'не сделано';

  @override
  String get reportsSkippedMetric => 'пропущено';

  @override
  String reportsHabitsDoneOnly(int doneCount) {
    return '$doneCount сделано';
  }

  @override
  String reportsHabitsDoneProgress(int doneCount, int actionableCount) {
    return '$doneCount/$actionableCount сделано';
  }

  @override
  String get reportsArchivedHabitHistory => 'История из архивных привычек.';

  @override
  String reportsActiveHabitsNoMarks(int activeHabitCount) {
    return 'Активных привычек: $activeHabitCount, отметок пока нет.';
  }

  @override
  String reportsActiveHabitsTracked(int activeHabitCount) {
    return 'Активных привычек: $activeHabitCount.';
  }

  @override
  String get reportsOneDay => '1 день';

  @override
  String reportsDays(int dayCount) {
    return '$dayCount дней';
  }

  @override
  String get reportsDateYesterday => 'Вчера';

  @override
  String reportsCompletedCount(int count) {
    return '$count выполнено';
  }

  @override
  String get reportsCompletedTasksSubtitle => 'Выполненные задачи';

  @override
  String get reportsStandaloneTitle => 'Без цели';

  @override
  String get reportsStandaloneSubtitle =>
      'Выполненные задачи без привязки к цели';

  @override
  String get reportsNoHabitMarks => 'За этот период отметок привычек нет.';

  @override
  String reportsHabitMissedCount(int count) {
    return '$count не сделано';
  }

  @override
  String reportsHabitSkippedCount(int count) {
    return '$count пропущено';
  }

  @override
  String reportsHabitPartialCount(int count) {
    return '$count частично';
  }

  @override
  String get calendarNoTasksForDay => 'На этот день задач нет.';

  @override
  String get calendarAddButton => 'Добавить';

  @override
  String calendarSelectedDayTitle(String dateTitle) {
    return 'Выбранный день: $dateTitle';
  }

  @override
  String calendarPastDateWarning(String date) {
    return 'Вы создаёте задачу на прошедшую дату: $date.';
  }

  @override
  String get calendarOneTimeTaskTitle => 'Разовая задача';

  @override
  String calendarOneTimeTaskSubtitle(String date) {
    return 'Создать задачу на $date';
  }

  @override
  String get calendarRecurringTaskTitle => 'Повторяющаяся задача';

  @override
  String calendarRecurringTaskSubtitle(String date) {
    return 'Создать повторяющуюся задачу с $date';
  }

  @override
  String get calendarDateToday => 'Сегодня';

  @override
  String get calendarDateTomorrow => 'Завтра';

  @override
  String get calendarDateYesterday => 'Вчера';

  @override
  String get calendarWeekdayMonShort => 'Пн';

  @override
  String get calendarWeekdayTueShort => 'Вт';

  @override
  String get calendarWeekdayWedShort => 'Ср';

  @override
  String get calendarWeekdayThuShort => 'Чт';

  @override
  String get calendarWeekdayFriShort => 'Пт';

  @override
  String get calendarWeekdaySatShort => 'Сб';

  @override
  String get calendarWeekdaySunShort => 'Вс';

  @override
  String get taskCompletionPastTitle => 'Когда задача была выполнена?';

  @override
  String get taskCompletionTodayOption => 'Сегодня';

  @override
  String get taskCompletionYesterdayOption => 'Вчера';

  @override
  String taskCompletionScheduledDateOption(String date) {
    return 'Запланированная дата: $date';
  }

  @override
  String get taskCompletionFutureTitle => 'Выполнить заранее?';

  @override
  String taskCompletionFutureMessage(String date) {
    return 'Эта задача запланирована на $date.';
  }

  @override
  String get taskCompletionCompleteTodayButton => 'Выполнить сегодня';

  @override
  String get allTasksTitle => 'Все задачи';

  @override
  String get allTasksEmptyDescription => 'Задач пока нет.';

  @override
  String get allTasksTasksSection => 'Задачи';

  @override
  String get allTasksRecurringRulesSection => 'Повторяющиеся правила';

  @override
  String taskCardGoalLabel(String goalTitle) {
    return 'Цель: $goalTitle';
  }

  @override
  String get taskCardScheduledToday => 'Запланировано: сегодня';

  @override
  String taskCardScheduledDate(String date) {
    return 'Запланировано: $date';
  }

  @override
  String get taskCardPlanTodayButton => 'Запланировать на сегодня';

  @override
  String get taskActionRemoveFromToday => 'Убрать из Сегодня';

  @override
  String get taskActionAttachToGoal => 'Привязать к цели';

  @override
  String get taskActionDetachFromGoal => 'Отвязать от цели';

  @override
  String get taskActionMoveToMilestone => 'Переместить в этап';

  @override
  String get taskActionMoveToDirectGoal => 'Переместить в задачи цели';

  @override
  String get taskActionScheduleDate => 'Запланировать дату';

  @override
  String get taskActionRemoveScheduledDate => 'Убрать дату';

  @override
  String get taskDialogAddTitle => 'Добавить задачу';

  @override
  String get taskDialogEditTitle => 'Изменить задачу';

  @override
  String get taskDialogAddForTodayTitle => 'Добавить задачу на сегодня';

  @override
  String get taskTitleFieldLabel => 'Название';

  @override
  String get taskTitleFieldHint => 'например, набросать план статьи';

  @override
  String get taskDescriptionFieldLabel => 'Описание';

  @override
  String get taskDescriptionFieldHint => 'Необязательно';

  @override
  String get taskGoalFieldLabel => 'Цель';

  @override
  String get taskNoGoalOption => 'Без цели';

  @override
  String get taskMilestoneFieldLabel => 'Этап';

  @override
  String get taskNoMilestoneOption => 'Без этапа';

  @override
  String get taskAttachToGoalTitle => 'Привязать задачу к цели';

  @override
  String get taskAttachButton => 'Привязать';

  @override
  String get moreToolsSection => 'Инструменты';

  @override
  String get moreAllTasksSubtitle => 'Все задачи в одном месте.';

  @override
  String get moreReportsSubtitle => 'Прогресс по задачам, привычкам и целям.';

  @override
  String get moreRecurringTasksTitle => 'Повторяющиеся задачи';

  @override
  String get moreRecurringTasksSubtitle =>
      'Управление задачами по дням недели и месяцам.';

  @override
  String get goalsEmptyDescription =>
      'Целей пока нет. Создайте первую долгосрочную цель.';

  @override
  String get goalDialogAddTitle => 'Добавить цель';

  @override
  String get goalDialogEditTitle => 'Изменить цель';

  @override
  String get goalTitleFieldLabel => 'Название';

  @override
  String get goalTitleFieldHint => 'например, запустить личный блог';

  @override
  String get goalDescriptionFieldLabel => 'Описание';

  @override
  String get goalDescriptionFieldHint => 'Необязательно';

  @override
  String get goalCardNoTasksYet => 'Задач пока нет';

  @override
  String goalCardTasksCompleted(int completedCount, int totalCount) {
    return '$completedCount / $totalCount задач выполнено';
  }

  @override
  String get goalDetailsDirectTasksSection => 'Задачи цели';

  @override
  String get goalDetailsNoDirectTasks => 'Задач цели пока нет.';

  @override
  String get goalDetailsDirectRecurringTasksSection =>
      'Повторяющиеся задачи цели';

  @override
  String get goalDetailsAddRecurringButton => 'Добавить повтор';

  @override
  String get goalDetailsNoDirectRecurringTasks =>
      'Повторяющихся задач цели пока нет.';
}
