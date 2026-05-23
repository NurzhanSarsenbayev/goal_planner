import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../habits/domain/habit.dart';
import '../../habits/domain/habit_entry.dart';
import '../../habits/domain/habit_entry_status.dart';
import '../../habits/domain/habit_tracking_type.dart';
import '../../reminders/standalone/domain/standalone_reminder.dart';
import '../../reminders/daily_review/domain/daily_review_reminder_settings.dart';

part 'planner_backup_json_mappers.dart';

class PlannerBackup {
  const PlannerBackup({
    required this.schemaVersion,
    required this.exportedAt,
    required this.data,
  });

  static const currentSchemaVersion = 1;

  final int schemaVersion;
  final DateTime exportedAt;
  final PlannerBackupData data;

  factory PlannerBackup.create({
    required PlannerBackupData data,
    DateTime? exportedAt,
  }) {
    return PlannerBackup(
      schemaVersion: currentSchemaVersion,
      exportedAt: exportedAt ?? DateTime.now(),
      data: data,
    );
  }

  factory PlannerBackup.fromJson(Map<String, dynamic> json) {
    final schemaVersion = _intFromJson(json, 'schemaVersion');

    if (schemaVersion != currentSchemaVersion) {
      throw FormatException(
        'Unsupported backup schema version: $schemaVersion.',
      );
    }

    return PlannerBackup(
      schemaVersion: schemaVersion,
      exportedAt: _dateFromJson(json, 'exportedAt'),
      data: PlannerBackupData.fromJson(_mapFromJson(json, 'data')),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'schemaVersion': schemaVersion,
      'exportedAt': _dateToJson(exportedAt),
      'data': data.toJson(),
    };
  }
}

class PlannerBackupData {
  const PlannerBackupData({
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.recurringExceptions,
    required this.habits,
    required this.habitEntries,
    this.standaloneReminders = const [],
    this.dailyReviewReminderSettings =
        const DailyReviewReminderSettings.defaults(),
  });

  const PlannerBackupData.empty()
    : goals = const [],
      milestones = const [],
      tasks = const [],
      recurringRules = const [],
      recurringExceptions = const [],
      habits = const [],
      habitEntries = const [],
      standaloneReminders = const [],
      dailyReviewReminderSettings =
          const DailyReviewReminderSettings.defaults();

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
  final List<Habit> habits;
  final List<HabitEntry> habitEntries;
  final List<StandaloneReminder> standaloneReminders;
  final DailyReviewReminderSettings dailyReviewReminderSettings;

  factory PlannerBackupData.fromJson(Map<String, dynamic> json) {
    return PlannerBackupData(
      goals: _mapListFromJson(
        json,
        'goals',
      ).map(_goalFromJson).toList(growable: false),
      milestones: _mapListFromJson(
        json,
        'milestones',
      ).map(_milestoneFromJson).toList(growable: false),
      tasks: _mapListFromJson(
        json,
        'tasks',
      ).map(_taskFromJson).toList(growable: false),
      recurringRules: _mapListFromJson(
        json,
        'recurringRules',
      ).map(_recurringRuleFromJson).toList(growable: false),
      recurringExceptions: _mapListFromJson(
        json,
        'recurringExceptions',
      ).map(_recurringExceptionFromJson).toList(growable: false),
      habits: _mapListFromJson(
        json,
        'habits',
      ).map(_habitFromJson).toList(growable: false),
      habitEntries: _mapListFromJson(
        json,
        'habitEntries',
      ).map(_habitEntryFromJson).toList(growable: false),
      standaloneReminders: _mapListFromJson(
        json,
        'standaloneReminders',
      ).map(_standaloneReminderFromJson).toList(growable: false),
      dailyReviewReminderSettings: _dailyReviewReminderSettingsFromJson(json),
    );
  }

  Map<String, Object?> toJson() {
    return {
      'goals': goals.map(_goalToJson).toList(growable: false),
      'milestones': milestones.map(_milestoneToJson).toList(growable: false),
      'tasks': tasks.map(_taskToJson).toList(growable: false),
      'recurringRules': recurringRules
          .map(_recurringRuleToJson)
          .toList(growable: false),
      'recurringExceptions': recurringExceptions
          .map(_recurringExceptionToJson)
          .toList(growable: false),
      'habits': habits.map(_habitToJson).toList(growable: false),
      'habitEntries': habitEntries
          .map(_habitEntryToJson)
          .toList(growable: false),
      'standaloneReminders': standaloneReminders
          .map(_standaloneReminderToJson)
          .toList(growable: false),
      'dailyReviewReminderSettings': _dailyReviewReminderSettingsToJson(
        dailyReviewReminderSettings,
      ),
    };
  }
}
