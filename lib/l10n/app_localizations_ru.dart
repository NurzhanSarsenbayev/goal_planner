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
}
