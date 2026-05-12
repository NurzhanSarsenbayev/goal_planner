import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ru.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ru'),
  ];

  /// Application title
  ///
  /// In en, this message translates to:
  /// **'Goal Planner'**
  String get appTitle;

  /// Bottom navigation label and app bar title for Today tab
  ///
  /// In en, this message translates to:
  /// **'Today'**
  String get todayTab;

  /// Bottom navigation label and app bar title for Goals tab
  ///
  /// In en, this message translates to:
  /// **'Goals'**
  String get goalsTab;

  /// Bottom navigation label and app bar title for Calendar tab
  ///
  /// In en, this message translates to:
  /// **'Calendar'**
  String get calendarTab;

  /// Bottom navigation label and app bar title for Habits tab
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTab;

  /// Bottom navigation label and app bar title for More tab
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get moreTab;

  /// Today add action sheet title for one-time task
  ///
  /// In en, this message translates to:
  /// **'One-time task'**
  String get todayOneTimeTaskTitle;

  /// Today add action sheet subtitle for one-time task
  ///
  /// In en, this message translates to:
  /// **'Create a task for today'**
  String get todayOneTimeTaskSubtitle;

  /// Today add action sheet title for recurring task
  ///
  /// In en, this message translates to:
  /// **'Recurring task'**
  String get todayRecurringTaskTitle;

  /// Today add action sheet subtitle for recurring task
  ///
  /// In en, this message translates to:
  /// **'Create a task that repeats'**
  String get todayRecurringTaskSubtitle;

  /// Today floating action button label
  ///
  /// In en, this message translates to:
  /// **'Add task'**
  String get todayAddTaskButton;

  /// Today overdue task section title
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get todayOverdueSection;

  /// Today pending tasks section title
  ///
  /// In en, this message translates to:
  /// **'To do today'**
  String get todayTodoSection;

  /// Today completed tasks section title
  ///
  /// In en, this message translates to:
  /// **'Done today'**
  String get todayDoneSection;

  /// Today empty text for pending tasks section
  ///
  /// In en, this message translates to:
  /// **'No tasks left for today.'**
  String get todayNoTasksLeft;

  /// Today summary metric label for pending tasks
  ///
  /// In en, this message translates to:
  /// **'To do'**
  String get todaySummaryTodo;

  /// Today summary metric label for overdue tasks
  ///
  /// In en, this message translates to:
  /// **'Overdue'**
  String get todaySummaryOverdue;

  /// Today summary metric label for completed tasks
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get todaySummaryDone;

  /// Today summary message when no tasks exist
  ///
  /// In en, this message translates to:
  /// **'Nothing planned yet. Add one small task to start the day.'**
  String get todaySummaryNothingPlanned;

  /// Today summary message when all planned tasks are done
  ///
  /// In en, this message translates to:
  /// **'All planned tasks are done for today.'**
  String get todaySummaryAllDone;

  /// Today summary message when there are overdue tasks
  ///
  /// In en, this message translates to:
  /// **'Handle overdue tasks first, then continue with today.'**
  String get todaySummaryHandleOverdue;

  /// Today summary message when there are pending tasks
  ///
  /// In en, this message translates to:
  /// **'Focus on today’s planned tasks.'**
  String get todaySummaryFocus;

  /// Today habit summary card title
  ///
  /// In en, this message translates to:
  /// **'Habits today'**
  String get todayHabitsTitle;

  /// Today habit summary when no actionable habits remain
  ///
  /// In en, this message translates to:
  /// **'Done: {doneCount}'**
  String todayHabitsDoneOnly(int doneCount);

  /// Today habit summary progress text
  ///
  /// In en, this message translates to:
  /// **'{doneCount}/{actionableCount} done'**
  String todayHabitsDoneProgress(int doneCount, int actionableCount);

  /// Today habit missed count
  ///
  /// In en, this message translates to:
  /// **'Missed: {count}'**
  String todayHabitsMissedCount(int count);

  /// Today habit skipped count
  ///
  /// In en, this message translates to:
  /// **'Skipped: {count}'**
  String todayHabitsSkippedCount(int count);

  /// Today habit partial count
  ///
  /// In en, this message translates to:
  /// **'Partial: {count}'**
  String todayHabitsPartialCount(int count);

  /// Today habit not marked count
  ///
  /// In en, this message translates to:
  /// **'Not marked: {count}'**
  String todayHabitsNotMarkedCount(int count);

  /// Today habit summary when all habits are marked
  ///
  /// In en, this message translates to:
  /// **'All habits are marked for today.'**
  String get todayHabitsAllMarked;

  /// Today empty panel title
  ///
  /// In en, this message translates to:
  /// **'Plan today lightly'**
  String get todayEmptyTitle;

  /// Today empty panel description
  ///
  /// In en, this message translates to:
  /// **'Add one task that would make today feel a little more under control.'**
  String get todayEmptyDescription;

  /// Today empty panel button label
  ///
  /// In en, this message translates to:
  /// **'Plan today'**
  String get todayPlanTodayButton;

  /// Fallback empty text for Today sections
  ///
  /// In en, this message translates to:
  /// **'Nothing here.'**
  String get todayEmptySectionFallback;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ru'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ru':
      return AppLocalizationsRu();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
