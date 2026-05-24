import '../../../../shared/planner_time.dart';
import 'daily_review_pending_checker.dart';
import 'daily_review_reminder_settings_repository.dart';
import '../../common/application/reminder_notification_client.dart';
import '../../common/application/reminder_notification_texts.dart';

const dailyReviewReminderNotificationId = 73001;
const dailyReviewReminderPayload = 'daily_review_reminder';

class DailyReviewReminderScheduler {
  DailyReviewReminderScheduler({
    required DailyReviewReminderSettingsRepository settingsRepository,
    required DailyReviewPendingChecker pendingChecker,
    required ReminderNotificationClient notifications,
    DateTime Function()? now,
    ReminderNotificationTexts? notificationTexts,
  }) : _settingsRepository = settingsRepository,
       _pendingChecker = pendingChecker,
       _notifications = notifications,
       _now = now ?? DateTime.now,
       _notificationTexts = notificationTexts ?? ReminderNotificationTexts();

  final DailyReviewReminderSettingsRepository _settingsRepository;
  final DailyReviewPendingChecker _pendingChecker;
  final ReminderNotificationClient _notifications;
  final DateTime Function() _now;
  final ReminderNotificationTexts _notificationTexts;

  Future<void> syncDailyReviewReminder() async {
    await _notifications.cancelReminder(dailyReviewReminderNotificationId);

    final settings = await _settingsRepository.loadSettings();

    if (!settings.isEnabled) {
      return;
    }

    final summary = await _pendingChecker.loadPendingSummary();

    if (!summary.hasPendingItems) {
      return;
    }

    await _notifications.scheduleReminder(
      id: dailyReviewReminderNotificationId,
      title: _notificationTexts.dailyReviewTitle,
      body: _notificationTexts.dailyReviewBody(summary.pendingItemCount),
      scheduledAt: _nextReviewDateTime(settings.timeMinutes),
      payload: dailyReviewReminderPayload,
    );
  }

  Future<void> cancelDailyReviewReminder() {
    return _notifications.cancelReminder(dailyReviewReminderNotificationId);
  }

  DateTime _nextReviewDateTime(int timeMinutes) {
    assert(
      isValidPlannerTimeMinutes(timeMinutes),
      'timeMinutes must be between 0 and 1439.',
    );

    final currentTime = _now();
    final todayAtReviewTime = DateTime(
      currentTime.year,
      currentTime.month,
      currentTime.day,
    ).add(Duration(minutes: timeMinutes));

    if (todayAtReviewTime.isAfter(currentTime)) {
      return todayAtReviewTime;
    }

    return todayAtReviewTime.add(const Duration(days: 1));
  }
}
