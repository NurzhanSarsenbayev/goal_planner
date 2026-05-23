import '../../../../shared/planner_time.dart';

const defaultDailyReviewReminderTimeMinutes = 21 * 60;

class DailyReviewReminderSettings {
  DailyReviewReminderSettings({
    required this.isEnabled,
    required this.timeMinutes,
  }) : assert(
         isValidPlannerTimeMinutes(timeMinutes),
         'timeMinutes must be between 0 and 1439.',
       );

  const DailyReviewReminderSettings.defaults()
    : isEnabled = true,
      timeMinutes = defaultDailyReviewReminderTimeMinutes;

  final bool isEnabled;
  final int timeMinutes;

  DailyReviewReminderSettings copyWith({bool? isEnabled, int? timeMinutes}) {
    return DailyReviewReminderSettings(
      isEnabled: isEnabled ?? this.isEnabled,
      timeMinutes: timeMinutes ?? this.timeMinutes,
    );
  }
}
