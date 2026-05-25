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
  String get habitReminderNotificationBody => 'Напоминание о привычке';

  @override
  String get habitReminderEnabledTitle => 'Напоминание';

  @override
  String get habitReminderDisabledSubtitle =>
      'Для этой привычки напоминание выключено.';

  @override
  String habitReminderTimeSubtitle(String time) {
    return 'Напомнить в $time';
  }

  @override
  String habitReminderTimeButton(String time) {
    return 'Время: $time';
  }

  @override
  String get taskReminderNotificationBody => 'Напоминание о задаче';

  @override
  String get standaloneReminderNotificationBody => 'Напоминание';

  @override
  String get dailyReviewReminderNotificationTitle => 'Закройте день';

  @override
  String dailyReviewReminderNotificationBody(int count) {
    return 'Осталось пунктов для проверки: $count.';
  }

  @override
  String get notificationTestTitle => 'Goal Planner';

  @override
  String get notificationTestBody => 'Уведомления работают.';

  @override
  String get notificationReminderChannelName => 'Напоминания';

  @override
  String get notificationReminderChannelDescription =>
      'Уведомления о задачах, привычках и напоминаниях.';

  @override
  String get notificationTestChannelName => 'Уведомления Goal Planner';

  @override
  String get notificationTestChannelDescription =>
      'Проверка локальных уведомлений.';

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
  String get taskActionSetTime => 'Задать время';

  @override
  String get taskActionChangeTime => 'Изменить время';

  @override
  String get taskActionClearTime => 'Убрать время';

  @override
  String get taskEditActionsSheetTitle => 'Изменить задачу';

  @override
  String get taskEditActionsRecurringSheetTitle =>
      'Изменить повторяющуюся задачу';

  @override
  String get taskEditActionsOnlyThisTaskSection => 'Только эта задача';

  @override
  String get taskEditActionTitleAndDescription => 'Название и описание';

  @override
  String get taskEditActionsWholeSeriesSection => 'Вся серия';

  @override
  String get taskEditActionEditSeries => 'Изменить правило повторения';

  @override
  String get taskEditActionDeleteThisTask => 'Удалить эту задачу';

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
  String get taskTimeNotSetButton => 'Добавить время';

  @override
  String taskTimeSelectedButton(String time) {
    return 'Время: $time';
  }

  @override
  String get taskTimeClearButton => 'Убрать время';

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
  String get moreSettingsSection => 'Настройки';

  @override
  String get moreLanguageTitle => 'Язык';

  @override
  String get moreLanguageSystemOption => 'Системный язык';

  @override
  String get moreLanguageEnglishOption => 'English';

  @override
  String get moreLanguageRussianOption => 'Русский';

  @override
  String get moreBackupSection => 'Бэкап';

  @override
  String get moreCreateBackupTitle => 'Создать бэкап';

  @override
  String get moreCreateBackupSubtitle =>
      'Сохранить локальный JSON-бэкап данных планера.';

  @override
  String backupCreateSuccessMessage(String filePath) {
    return 'Бэкап создан: $filePath';
  }

  @override
  String get backupCreateFailureMessage =>
      'Не удалось создать бэкап. Попробуйте ещё раз.';

  @override
  String get moreBackupNeverCreated => 'Последний бэкап: никогда';

  @override
  String moreBackupLastCreated(String dateTime) {
    return 'Последний бэкап: $dateTime';
  }

  @override
  String get moreRestoreBackupTitle => 'Восстановить последний бэкап';

  @override
  String get moreRestoreBackupSubtitle =>
      'Заменить локальные данные последним локальным бэкапом.';

  @override
  String get backupRestoreNoLocalBackupMessage => 'Локальный бэкап не найден.';

  @override
  String get backupRestoreConfirmTitle => 'Восстановить бэкап?';

  @override
  String get backupRestoreConfirmMessage =>
      'Текущие цели, задачи, повторяющиеся задачи и привычки будут заменены данными из последнего локального бэкапа. Это действие нельзя отменить.';

  @override
  String get backupRestoreConfirmAction => 'Восстановить';

  @override
  String get backupRestoreSuccessMessage =>
      'Бэкап восстановлен. Локальные данные заменены.';

  @override
  String get backupRestoreFailureMessage =>
      'Не удалось восстановить бэкап. Проверьте файл и попробуйте ещё раз.';

  @override
  String get moreExportBackupTitle => 'Экспортировать бэкап';

  @override
  String get moreExportBackupSubtitle =>
      'Сохранить или отправить бэкап вне приложения.';

  @override
  String get backupExportShareTitle => 'Бэкап Goal Planner';

  @override
  String get backupExportShareText => 'Файл бэкапа Goal Planner.';

  @override
  String get backupExportSuccessMessage => 'Окно экспорта бэкапа открыто.';

  @override
  String get backupExportDismissedMessage => 'Экспорт бэкапа отменён.';

  @override
  String get backupExportFailureMessage =>
      'Не удалось экспортировать бэкап. Попробуйте ещё раз.';

  @override
  String get moreRestoreExternalBackupTitle => 'Восстановить из файла';

  @override
  String get moreRestoreExternalBackupSubtitle =>
      'Выбрать экспортированный бэкап и заменить локальные данные.';

  @override
  String get backupRestorePickCancelledMessage => 'Выбор файла бэкапа отменён.';

  @override
  String get backupRestoreExternalConfirmMessage =>
      'Текущие цели, задачи, повторяющиеся задачи и привычки будут заменены данными из выбранного файла бэкапа. Это действие нельзя отменить.';

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
  String get moreStandaloneRemindersTitle => 'Напоминания';

  @override
  String get moreDailyReviewReminderTitle => 'Вечернее напоминание';

  @override
  String get moreDailyReviewReminderSubtitle =>
      'Напоминать закрыть день, если остались незавершённые пункты.';

  @override
  String get dailyReviewReminderSettingsTitle => 'Вечернее напоминание';

  @override
  String get dailyReviewReminderSettingsDescription =>
      'Goal Planner напомнит ближе к концу дня только если остались незавершённые задачи или незаполненные привычки.';

  @override
  String get dailyReviewReminderEnabledTitle => 'Вечернее напоминание';

  @override
  String get dailyReviewReminderEnabledSubtitle =>
      'Присылать напоминание, если день ещё не закрыт.';

  @override
  String get dailyReviewReminderTimeTitle => 'Время напоминания';

  @override
  String dailyReviewReminderTimeSubtitle(String time) {
    return 'В $time';
  }

  @override
  String get moreStandaloneRemindersSubtitle =>
      'Разовые и ежедневные напоминания по времени.';

  @override
  String get standaloneRemindersScreenTitle => 'Напоминания';

  @override
  String get standaloneRemindersEmptyDescription =>
      'Напоминаний по времени пока нет.';

  @override
  String standaloneReminderDailySubtitle(String time) {
    return 'Каждый день в $time';
  }

  @override
  String standaloneReminderOnceSubtitle(String date, String time) {
    return '$date в $time';
  }

  @override
  String standaloneReminderOnceMissingDateSubtitle(String time) {
    return 'Разовое напоминание в $time';
  }

  @override
  String get standaloneReminderEnabledStatus => 'Вкл';

  @override
  String get standaloneReminderDisabledStatus => 'Выкл';

  @override
  String get standaloneReminderExpiredStatus => 'Просрочено';

  @override
  String standaloneReminderExpiredSubtitle(String date, String time) {
    return 'Просрочено · $date в $time';
  }

  @override
  String get standaloneReminderAddButton => 'Добавить';

  @override
  String get standaloneReminderDialogAddTitle => 'Добавить напоминание';

  @override
  String get standaloneReminderDialogEditTitle => 'Редактировать напоминание';

  @override
  String get standaloneReminderDeleteDialogTitle => 'Удалить напоминание?';

  @override
  String get standaloneReminderDeleteDialogMessage =>
      'Это напоминание будет удалено.';

  @override
  String get standaloneReminderTitleFieldLabel => 'Название';

  @override
  String get standaloneReminderTitleFieldHint => 'Например: Спланировать день';

  @override
  String get standaloneReminderScheduleTypeFieldLabel => 'Повтор';

  @override
  String get standaloneReminderScheduleDailyOption => 'Каждый день';

  @override
  String get standaloneReminderScheduleOnceOption => 'Один раз';

  @override
  String standaloneReminderDateButton(String date) {
    return 'Дата: $date';
  }

  @override
  String standaloneReminderTimeButton(String time) {
    return 'Время: $time';
  }

  @override
  String get standaloneReminderTitleRequiredError =>
      'Введите название напоминания.';

  @override
  String get standaloneReminderPastDateTimeError =>
      'Выберите будущие дату и время.';

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

  @override
  String get goalDeleteDialogTitle => 'Удалить цель?';

  @override
  String goalDeleteDialogMessage(String goalTitle) {
    return 'Цель «$goalTitle» будет удалена навсегда.';
  }

  @override
  String goalDeleteDialogMilestonesCount(int count) {
    return 'Этапы: $count';
  }

  @override
  String goalDeleteDialogTasksCount(int count) {
    return 'Задачи: $count';
  }

  @override
  String get goalDeleteDialogTypeDeleteToConfirm =>
      'Введите DELETE для подтверждения.';

  @override
  String get goalDeleteDialogConfirmationLabel => 'Подтверждение';

  @override
  String get goalDeleteDialogDeleteButton => 'Удалить цель';

  @override
  String get milestoneDeleteDialogTitle => 'Удалить этап?';

  @override
  String milestoneDeleteDialogEmptyMessage(String milestoneTitle) {
    return 'Удалить этап «$milestoneTitle»?';
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
          'В этом этапе $taskCount задачи. Выберите, что сделать с «$milestoneTitle».',
      many:
          'В этом этапе $taskCount задач. Выберите, что сделать с «$milestoneTitle».',
      few:
          'В этом этапе $taskCount задачи. Выберите, что сделать с «$milestoneTitle».',
      one: 'В этом этапе 1 задача. Выберите, что сделать с «$milestoneTitle».',
    );
    return '$_temp0';
  }

  @override
  String get milestoneDeleteDialogMoveTasksToDirectButton =>
      'Переместить в задачи цели';

  @override
  String get milestoneDeleteDialogDeleteWithTasksButton =>
      'Удалить этап и задачи';

  @override
  String get milestoneDialogAddTitle => 'Добавить этап';

  @override
  String get milestoneDialogEditTitle => 'Изменить этап';

  @override
  String get milestoneTitleFieldLabel => 'Название';

  @override
  String get milestoneTitleFieldHint => 'например, система контента';

  @override
  String get milestoneDescriptionFieldLabel => 'Описание';

  @override
  String get milestoneDescriptionFieldHint => 'Необязательно';

  @override
  String get milestonesSectionTitle => 'Этапы';

  @override
  String get milestonesAddButton => 'Добавить этап';

  @override
  String get milestonesEmptyTitle => 'Этапов пока нет';

  @override
  String get milestonesEmptyDescription =>
      'Добавьте этапы, чтобы группировать задачи внутри цели.';

  @override
  String get milestoneCardNoTasksYet => 'Разовых задач пока нет';

  @override
  String milestoneCardTasksCompleted(int completedCount, int totalCount) {
    return '$completedCount / $totalCount задач выполнено';
  }

  @override
  String get milestoneCardRecurringTasksSection => 'Повторяющиеся задачи';

  @override
  String get milestoneCardNoTasksInMilestone => 'Задач в этом этапе пока нет.';

  @override
  String get milestoneCardAddTaskButton => 'Добавить задачу';

  @override
  String get milestoneCardAddRecurringButton => 'Добавить повтор';

  @override
  String get moveTaskToMilestoneDialogTitle => 'Переместить в этап';

  @override
  String get moveTaskToMilestoneDialogEmptyMessage =>
      'У этой цели пока нет этапов.';

  @override
  String get recurringTasksScreenTitle => 'Повторяющиеся задачи';

  @override
  String get recurringTasksEmptyDescription => 'Повторяющихся правил пока нет.';

  @override
  String get recurringTasksAddRuleButton => 'Добавить правило';

  @override
  String get recurringRuleActionActivate => 'Включить';

  @override
  String get recurringRuleActionDeactivate => 'Отключить';

  @override
  String recurringRuleSubtitleWithPlacement(
    String recurrence,
    String placement,
  ) {
    return '$recurrence · $placement';
  }

  @override
  String recurringRuleInactiveSubtitle(String subtitle) {
    return 'Отключено · $subtitle';
  }

  @override
  String get recurringRuleMilestoneTaskLabel => 'Задача этапа';

  @override
  String get recurringRuleGoalTaskLabel => 'Задача цели';

  @override
  String get recurringRuleWeeklyLabel => 'Еженедельно';

  @override
  String recurringRuleWeeklyWithDays(String days) {
    return 'Еженедельно · $days';
  }

  @override
  String get recurringRuleMonthlyLabel => 'Ежемесячно';

  @override
  String recurringRuleMonthlyDay(int day) {
    return 'Ежемесячно · день $day';
  }

  @override
  String get recurringWeekdayMonShort => 'Пн';

  @override
  String get recurringWeekdayTueShort => 'Вт';

  @override
  String get recurringWeekdayWedShort => 'Ср';

  @override
  String get recurringWeekdayThuShort => 'Чт';

  @override
  String get recurringWeekdayFriShort => 'Пт';

  @override
  String get recurringWeekdaySatShort => 'Сб';

  @override
  String get recurringWeekdaySunShort => 'Вс';

  @override
  String get recurringRuleDeleteDialogTitle => 'Удалить повторяющееся правило?';

  @override
  String recurringRuleDeleteDialogMessage(String ruleTitle) {
    return 'Все незавершённые созданные задачи из «$ruleTitle» будут удалены. Выполненные задачи останутся в истории.';
  }

  @override
  String get recurringRuleDialogAddTitle => 'Добавить повторяющуюся задачу';

  @override
  String get recurringRuleDialogEditTitle => 'Изменить повторяющуюся задачу';

  @override
  String get recurringRuleTitleFieldLabel => 'Название';

  @override
  String get recurringRuleDescriptionFieldLabel => 'Описание';

  @override
  String get recurringRuleGoalFieldLabel => 'Цель';

  @override
  String get recurringRuleNoGoalOption => 'Без цели';

  @override
  String get recurringRuleMilestoneFieldLabel => 'Этап';

  @override
  String get recurringRuleDirectGoalTaskOption => 'Задача цели';

  @override
  String get recurringRuleMonthDayFieldLabel => 'День месяца';

  @override
  String recurringRuleMonthDayOption(int day) {
    return 'День $day';
  }

  @override
  String get recurringRuleShortMonthFallbackNote =>
      'Если в месяце нет выбранного дня, задача будет создана в последний день этого месяца.';

  @override
  String get moreNotificationsSection => 'Уведомления';

  @override
  String get moreTestNotificationTitle => 'Отправить тестовое уведомление';

  @override
  String get moreTestNotificationSubtitle =>
      'Проверяет, что локальные уведомления работают на этом устройстве.';

  @override
  String get notificationPermissionDeniedMessage =>
      'Разрешение на уведомления не выдано.';

  @override
  String get notificationTestSentMessage => 'Тестовое уведомление отправлено.';

  @override
  String get notificationTestFailureMessage =>
      'Не удалось отправить тестовое уведомление.';

  @override
  String get taskReminderFieldLabel => 'Напоминание';

  @override
  String get taskReminderNoneOption => 'Без напоминания';

  @override
  String get taskReminderAtTimeOption => 'В момент задачи';

  @override
  String taskReminderMinutesBeforeOption(int minutes) {
    return 'За $minutes мин';
  }

  @override
  String taskReminderHoursBeforeOption(int hours) {
    return 'За $hours ч';
  }
}
