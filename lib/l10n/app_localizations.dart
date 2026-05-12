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

  /// No description provided for @commonCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get commonCancel;

  /// No description provided for @commonAdd.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get commonAdd;

  /// No description provided for @commonSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get commonSave;

  /// No description provided for @commonEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get commonEdit;

  /// No description provided for @commonArchive.
  ///
  /// In en, this message translates to:
  /// **'Archive'**
  String get commonArchive;

  /// No description provided for @commonDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get commonDelete;

  /// No description provided for @habitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Habits'**
  String get habitsTitle;

  /// No description provided for @habitsArchivedTooltip.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get habitsArchivedTooltip;

  /// No description provided for @habitFabLabel.
  ///
  /// In en, this message translates to:
  /// **'Habit'**
  String get habitFabLabel;

  /// No description provided for @habitsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'Start tracking a small routine'**
  String get habitsEmptyTitle;

  /// No description provided for @habitsEmptyDescription.
  ///
  /// In en, this message translates to:
  /// **'Pick something simple that you want to notice every week.'**
  String get habitsEmptyDescription;

  /// No description provided for @habitsEmptyButton.
  ///
  /// In en, this message translates to:
  /// **'Create first habit'**
  String get habitsEmptyButton;

  /// No description provided for @habitsAllArchivedTitle.
  ///
  /// In en, this message translates to:
  /// **'All habits are archived'**
  String get habitsAllArchivedTitle;

  /// No description provided for @habitsAllArchivedDescription.
  ///
  /// In en, this message translates to:
  /// **'Create a new habit or restore an archived one.'**
  String get habitsAllArchivedDescription;

  /// No description provided for @habitsAllArchivedCreateButton.
  ///
  /// In en, this message translates to:
  /// **'Create new habit'**
  String get habitsAllArchivedCreateButton;

  /// No description provided for @habitsAllArchivedViewArchivedButton.
  ///
  /// In en, this message translates to:
  /// **'View archived habits'**
  String get habitsAllArchivedViewArchivedButton;

  /// No description provided for @habitExampleDrinkWater.
  ///
  /// In en, this message translates to:
  /// **'Drink water'**
  String get habitExampleDrinkWater;

  /// No description provided for @habitExampleRead.
  ///
  /// In en, this message translates to:
  /// **'Read 10 minutes'**
  String get habitExampleRead;

  /// No description provided for @habitExampleWalk.
  ///
  /// In en, this message translates to:
  /// **'Walk'**
  String get habitExampleWalk;

  /// No description provided for @habitExampleStretch.
  ///
  /// In en, this message translates to:
  /// **'Stretch'**
  String get habitExampleStretch;

  /// No description provided for @habitExampleSleep.
  ///
  /// In en, this message translates to:
  /// **'Sleep before midnight'**
  String get habitExampleSleep;

  /// No description provided for @habitAddDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Add habit'**
  String get habitAddDialogTitle;

  /// No description provided for @habitEditDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Edit habit'**
  String get habitEditDialogTitle;

  /// No description provided for @habitTitleFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get habitTitleFieldLabel;

  /// No description provided for @habitTitleFieldHint.
  ///
  /// In en, this message translates to:
  /// **'e.g. Drink water'**
  String get habitTitleFieldHint;

  /// No description provided for @habitDescriptionFieldLabel.
  ///
  /// In en, this message translates to:
  /// **'Description'**
  String get habitDescriptionFieldLabel;

  /// No description provided for @habitDescriptionFieldHint.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get habitDescriptionFieldHint;

  /// No description provided for @habitArchiveDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Archive habit?'**
  String get habitArchiveDialogTitle;

  /// No description provided for @habitArchiveDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'“{title}” will be hidden from the active habit list.'**
  String habitArchiveDialogMessage(String title);

  /// No description provided for @habitDeleteDialogTitle.
  ///
  /// In en, this message translates to:
  /// **'Delete habit?'**
  String get habitDeleteDialogTitle;

  /// No description provided for @habitDeleteDialogMessage.
  ///
  /// In en, this message translates to:
  /// **'“{title}” and its tracked entries will be deleted.'**
  String habitDeleteDialogMessage(String title);

  /// No description provided for @habitStatusSheetTitle.
  ///
  /// In en, this message translates to:
  /// **'How did it go?'**
  String get habitStatusSheetTitle;

  /// No description provided for @habitStatusDone.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get habitStatusDone;

  /// No description provided for @habitStatusMissed.
  ///
  /// In en, this message translates to:
  /// **'Missed'**
  String get habitStatusMissed;

  /// No description provided for @habitStatusSkip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get habitStatusSkip;

  /// No description provided for @habitStatusClear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get habitStatusClear;

  /// No description provided for @habitActionsTooltip.
  ///
  /// In en, this message translates to:
  /// **'Habit actions'**
  String get habitActionsTooltip;

  /// No description provided for @habitCurrentWeek.
  ///
  /// In en, this message translates to:
  /// **'Current week'**
  String get habitCurrentWeek;

  /// No description provided for @habitWeekdayMon.
  ///
  /// In en, this message translates to:
  /// **'Mon'**
  String get habitWeekdayMon;

  /// No description provided for @habitWeekdayTue.
  ///
  /// In en, this message translates to:
  /// **'Tue'**
  String get habitWeekdayTue;

  /// No description provided for @habitWeekdayWed.
  ///
  /// In en, this message translates to:
  /// **'Wed'**
  String get habitWeekdayWed;

  /// No description provided for @habitWeekdayThu.
  ///
  /// In en, this message translates to:
  /// **'Thu'**
  String get habitWeekdayThu;

  /// No description provided for @habitWeekdayFri.
  ///
  /// In en, this message translates to:
  /// **'Fri'**
  String get habitWeekdayFri;

  /// No description provided for @habitWeekdaySat.
  ///
  /// In en, this message translates to:
  /// **'Sat'**
  String get habitWeekdaySat;

  /// No description provided for @habitWeekdaySun.
  ///
  /// In en, this message translates to:
  /// **'Sun'**
  String get habitWeekdaySun;

  /// No description provided for @habitWeekSummaryDone.
  ///
  /// In en, this message translates to:
  /// **'{doneCount}/{totalDays} done'**
  String habitWeekSummaryDone(int doneCount, int totalDays);

  /// No description provided for @habitWeekSummaryMissed.
  ///
  /// In en, this message translates to:
  /// **'{count} missed'**
  String habitWeekSummaryMissed(int count);

  /// No description provided for @habitWeekSummarySkipped.
  ///
  /// In en, this message translates to:
  /// **'{count} skipped'**
  String habitWeekSummarySkipped(int count);

  /// No description provided for @habitWeekSummaryPartial.
  ///
  /// In en, this message translates to:
  /// **'{count} partial'**
  String habitWeekSummaryPartial(int count);

  /// No description provided for @archivedHabitsTitle.
  ///
  /// In en, this message translates to:
  /// **'Archived habits'**
  String get archivedHabitsTitle;

  /// No description provided for @archivedHabitsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No archived habits.'**
  String get archivedHabitsEmpty;

  /// No description provided for @archivedHabitRestoreTooltip.
  ///
  /// In en, this message translates to:
  /// **'Restore habit'**
  String get archivedHabitRestoreTooltip;

  /// No description provided for @archivedHabitDeleteTooltip.
  ///
  /// In en, this message translates to:
  /// **'Delete habit'**
  String get archivedHabitDeleteTooltip;
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
