class ReminderNotificationTexts {
  ReminderNotificationTexts({
    this.taskReminderBody = 'Task reminder',
    this.standaloneReminderBody = 'Reminder',
    this.habitReminderBody = 'Habit reminder',
    this.dailyReviewTitle = 'Review your day',
    String Function(int pendingItemCount)? dailyReviewBody,
    this.testNotificationTitle = 'Goal Planner',
    this.testNotificationBody = 'Notifications are working.',
    this.reminderChannelName = 'Task reminders',
    this.reminderChannelDescription =
        'Notifications for scheduled Goal Planner tasks.',
    this.testChannelName = 'Goal Planner reminders',
    this.testChannelDescription = 'Notifications for tasks and time reminders.',
  }) : _dailyReviewBody =
           dailyReviewBody ??
           ((count) => 'You still have $count item(s) to review.');

  String taskReminderBody;
  String standaloneReminderBody;
  String habitReminderBody;
  String dailyReviewTitle;
  String testNotificationTitle;
  String testNotificationBody;
  String reminderChannelName;
  String reminderChannelDescription;
  String testChannelName;
  String testChannelDescription;

  String Function(int pendingItemCount) _dailyReviewBody;

  String dailyReviewBody(int pendingItemCount) {
    return _dailyReviewBody(pendingItemCount);
  }

  void update({
    required String taskReminderBody,
    required String standaloneReminderBody,
    required String habitReminderBody,
    required String dailyReviewTitle,
    required String Function(int pendingItemCount) dailyReviewBody,
    required String testNotificationTitle,
    required String testNotificationBody,
    required String reminderChannelName,
    required String reminderChannelDescription,
    required String testChannelName,
    required String testChannelDescription,
  }) {
    this.taskReminderBody = taskReminderBody;
    this.standaloneReminderBody = standaloneReminderBody;
    this.habitReminderBody = habitReminderBody;
    this.dailyReviewTitle = dailyReviewTitle;
    this.testNotificationTitle = testNotificationTitle;
    this.testNotificationBody = testNotificationBody;
    this.reminderChannelName = reminderChannelName;
    this.reminderChannelDescription = reminderChannelDescription;
    this.testChannelName = testChannelName;
    this.testChannelDescription = testChannelDescription;
    _dailyReviewBody = dailyReviewBody;
  }
}
