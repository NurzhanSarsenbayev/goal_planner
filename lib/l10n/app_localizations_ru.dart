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
  String get todaySummaryOverdue => 'Просроченно';

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
  String get habitFabLabel => 'Привычка';

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
}
