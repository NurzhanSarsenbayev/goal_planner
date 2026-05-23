import '../../../../shared/planner_time.dart';

enum StandaloneReminderScheduleType { once, daily }

class StandaloneReminder {
  StandaloneReminder({
    required this.id,
    required this.title,
    this.scheduleType = StandaloneReminderScheduleType.daily,
    this.scheduledDate,
    required this.timeMinutes,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         isValidPlannerTimeMinutes(timeMinutes),
         'timeMinutes must be between 0 and 1439.',
       ),
       assert(
         scheduleType != StandaloneReminderScheduleType.once ||
             scheduledDate != null,
         'scheduledDate is required for one-time standalone reminders.',
       ),
       assert(
         scheduleType != StandaloneReminderScheduleType.daily ||
             scheduledDate == null,
         'scheduledDate must be null for daily standalone reminders.',
       );

  final String id;
  final String title;
  final StandaloneReminderScheduleType scheduleType;
  final DateTime? scheduledDate;
  final int timeMinutes;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  StandaloneReminder copyWith({
    String? id,
    String? title,
    StandaloneReminderScheduleType? scheduleType,
    DateTime? scheduledDate,
    bool clearScheduledDate = false,
    int? timeMinutes,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StandaloneReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      scheduleType: scheduleType ?? this.scheduleType,
      scheduledDate: clearScheduledDate
          ? null
          : scheduledDate ?? this.scheduledDate,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

DateTime? standaloneReminderDateTime(StandaloneReminder reminder) {
  if (reminder.scheduleType == StandaloneReminderScheduleType.daily) {
    return null;
  }

  final scheduledDate = reminder.scheduledDate;

  if (scheduledDate == null) {
    return null;
  }

  return DateTime(
    scheduledDate.year,
    scheduledDate.month,
    scheduledDate.day,
  ).add(Duration(minutes: reminder.timeMinutes));
}

bool isStandaloneReminderExpired(
  StandaloneReminder reminder,
  DateTime currentTime,
) {
  if (reminder.scheduleType == StandaloneReminderScheduleType.daily) {
    return false;
  }

  final scheduledAt = standaloneReminderDateTime(reminder);

  if (scheduledAt == null) {
    return false;
  }

  return !scheduledAt.isAfter(currentTime);
}
