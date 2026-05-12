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
}
