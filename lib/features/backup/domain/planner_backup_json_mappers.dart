part of 'planner_backup.dart';

Map<String, Object?> _goalToJson(Goal goal) {
  return {
    'id': goal.id,
    'title': goal.title,
    'description': goal.description,
    'status': goal.status.name,
    'createdAt': _dateToJson(goal.createdAt),
  };
}

Goal _goalFromJson(Map<String, dynamic> json) {
  return Goal(
    id: _stringFromJson(json, 'id'),
    title: _stringFromJson(json, 'title'),
    description: _stringFromJson(json, 'description'),
    status: _enumFromJson(GoalStatus.values, json, 'status'),
    createdAt: _dateFromJson(json, 'createdAt'),
  );
}

Map<String, Object?> _milestoneToJson(Milestone milestone) {
  return {
    'id': milestone.id,
    'goalId': milestone.goalId,
    'title': milestone.title,
    'description': milestone.description,
    'createdAt': _dateToJson(milestone.createdAt),
  };
}

Milestone _milestoneFromJson(Map<String, dynamic> json) {
  return Milestone(
    id: _stringFromJson(json, 'id'),
    goalId: _stringFromJson(json, 'goalId'),
    title: _stringFromJson(json, 'title'),
    description: _stringFromJson(json, 'description'),
    createdAt: _dateFromJson(json, 'createdAt'),
  );
}

Map<String, Object?> _taskToJson(PlannerTask task) {
  return {
    'id': task.id,
    'goalId': task.goalId,
    'milestoneId': task.milestoneId,
    'recurringRuleId': task.recurringRuleId,
    'title': task.title,
    'description': task.description,
    'scheduledDate': _nullableDateToJson(task.scheduledDate),
    'scheduledTimeMinutes': task.scheduledTimeMinutes,
    'reminderMinutesBefore': task.reminderMinutesBefore,
    'isCompleted': task.isCompleted,
    'completedAt': _nullableDateToJson(task.completedAt),
    'createdAt': _dateToJson(task.createdAt),
  };
}

PlannerTask _taskFromJson(Map<String, dynamic> json) {
  return PlannerTask(
    id: _stringFromJson(json, 'id'),
    goalId: _nullableStringFromJson(json, 'goalId'),
    milestoneId: _nullableStringFromJson(json, 'milestoneId'),
    recurringRuleId: _nullableStringFromJson(json, 'recurringRuleId'),
    title: _stringFromJson(json, 'title'),
    description: _stringFromJson(json, 'description'),
    scheduledDate: _nullableDateFromJson(json, 'scheduledDate'),
    scheduledTimeMinutes: _nullableIntFromJson(json, 'scheduledTimeMinutes'),
    reminderMinutesBefore: _nullableIntFromJson(json, 'reminderMinutesBefore'),
    isCompleted: _boolFromJson(json, 'isCompleted'),
    completedAt: _nullableDateFromJson(json, 'completedAt'),
    createdAt: _dateFromJson(json, 'createdAt'),
  );
}

Map<String, Object?> _recurringRuleToJson(RecurringTaskRule rule) {
  return {
    'id': rule.id,
    'goalId': rule.goalId,
    'milestoneId': rule.milestoneId,
    'title': rule.title,
    'description': rule.description,
    'recurrenceType': rule.recurrenceType.name,
    'weekdays': rule.weekdays,
    'monthDay': rule.monthDay,
    'startDate': _dateToJson(rule.startDate),
    'endDate': _nullableDateToJson(rule.endDate),
    'isActive': rule.isActive,
    'createdAt': _dateToJson(rule.createdAt),
  };
}

RecurringTaskRule _recurringRuleFromJson(Map<String, dynamic> json) {
  return RecurringTaskRule(
    id: _stringFromJson(json, 'id'),
    goalId: _nullableStringFromJson(json, 'goalId'),
    milestoneId: _nullableStringFromJson(json, 'milestoneId'),
    title: _stringFromJson(json, 'title'),
    description: _stringFromJson(json, 'description'),
    recurrenceType: _enumFromJson(
      RecurrenceType.values,
      json,
      'recurrenceType',
    ),
    weekdays: _intListFromJson(json, 'weekdays'),
    monthDay: _nullableIntFromJson(json, 'monthDay'),
    startDate: _dateFromJson(json, 'startDate'),
    endDate: _nullableDateFromJson(json, 'endDate'),
    isActive: _boolFromJson(json, 'isActive'),
    createdAt: _dateFromJson(json, 'createdAt'),
  );
}

Map<String, Object?> _recurringExceptionToJson(
  RecurringTaskException exception,
) {
  return {
    'id': exception.id,
    'ruleId': exception.ruleId,
    'date': _dateToJson(exception.date),
    'createdAt': _dateToJson(exception.createdAt),
  };
}

RecurringTaskException _recurringExceptionFromJson(Map<String, dynamic> json) {
  return RecurringTaskException(
    id: _stringFromJson(json, 'id'),
    ruleId: _stringFromJson(json, 'ruleId'),
    date: _dateFromJson(json, 'date'),
    createdAt: _dateFromJson(json, 'createdAt'),
  );
}

Map<String, Object?> _habitToJson(Habit habit) {
  return {
    'id': habit.id,
    'title': habit.title,
    'description': habit.description,
    'trackingType': habit.trackingType.name,
    'targetCount': habit.targetCount,
    'sortOrder': habit.sortOrder,
    'isArchived': habit.isArchived,
    'isReminderEnabled': habit.isReminderEnabled,
    'reminderTimeMinutes': habit.reminderTimeMinutes,
    'createdAt': _dateToJson(habit.createdAt),
    'updatedAt': _dateToJson(habit.updatedAt),
  };
}

Habit _habitFromJson(Map<String, dynamic> json) {
  return Habit(
    id: _stringFromJson(json, 'id'),
    title: _stringFromJson(json, 'title'),
    description: _stringFromJson(json, 'description'),
    trackingType: _enumFromJson(HabitTrackingType.values, json, 'trackingType'),
    targetCount: _nullableIntFromJson(json, 'targetCount'),
    sortOrder: _intFromJson(json, 'sortOrder'),
    isArchived: _boolFromJson(json, 'isArchived'),
    isReminderEnabled: _optionalBoolFromJson(
      json,
      'isReminderEnabled',
      defaultValue: false,
    ),
    reminderTimeMinutes: _nullableIntFromJson(json, 'reminderTimeMinutes'),
    createdAt: _dateFromJson(json, 'createdAt'),
    updatedAt: _dateFromJson(json, 'updatedAt'),
  );
}

bool _optionalBoolFromJson(
  Map<String, dynamic> json,
  String field, {
  required bool defaultValue,
}) {
  final value = json[field];

  if (value == null) {
    return defaultValue;
  }

  if (value is bool) {
    return value;
  }

  throw FormatException('$field must be a bool.');
}

Map<String, Object?> _habitEntryToJson(HabitEntry entry) {
  return {
    'id': entry.id,
    'habitId': entry.habitId,
    'date': _dateToJson(entry.date),
    'status': entry.status.name,
    'completedCount': entry.completedCount,
    'note': entry.note,
    'createdAt': _dateToJson(entry.createdAt),
    'updatedAt': _dateToJson(entry.updatedAt),
  };
}

HabitEntry _habitEntryFromJson(Map<String, dynamic> json) {
  return HabitEntry(
    id: _stringFromJson(json, 'id'),
    habitId: _stringFromJson(json, 'habitId'),
    date: _dateFromJson(json, 'date'),
    status: _enumFromJson(HabitEntryStatus.values, json, 'status'),
    completedCount: _intFromJson(json, 'completedCount'),
    note: _nullableStringFromJson(json, 'note'),
    createdAt: _dateFromJson(json, 'createdAt'),
    updatedAt: _dateFromJson(json, 'updatedAt'),
  );
}

Map<String, Object?> _standaloneReminderToJson(StandaloneReminder reminder) {
  return {
    'id': reminder.id,
    'title': reminder.title,
    'scheduleType': reminder.scheduleType.name,
    'scheduledDate': _nullableDateToJson(reminder.scheduledDate),
    'timeMinutes': reminder.timeMinutes,
    'isEnabled': reminder.isEnabled,
    'createdAt': _dateToJson(reminder.createdAt),
    'updatedAt': _dateToJson(reminder.updatedAt),
  };
}

StandaloneReminder _standaloneReminderFromJson(Map<String, dynamic> json) {
  return StandaloneReminder(
    id: _stringFromJson(json, 'id'),
    title: _stringFromJson(json, 'title'),
    scheduleType: _enumFromJson(
      StandaloneReminderScheduleType.values,
      json,
      'scheduleType',
    ),
    scheduledDate: _nullableDateFromJson(json, 'scheduledDate'),
    timeMinutes: _intFromJson(json, 'timeMinutes'),
    isEnabled: _boolFromJson(json, 'isEnabled'),
    createdAt: _dateFromJson(json, 'createdAt'),
    updatedAt: _dateFromJson(json, 'updatedAt'),
  );
}

Map<String, Object?> _dailyReviewReminderSettingsToJson(
  DailyReviewReminderSettings settings,
) {
  return {'isEnabled': settings.isEnabled, 'timeMinutes': settings.timeMinutes};
}

DailyReviewReminderSettings _dailyReviewReminderSettingsFromJson(
  Map<String, dynamic> json,
) {
  final value = json['dailyReviewReminderSettings'];

  if (value == null) {
    return const DailyReviewReminderSettings.defaults();
  }

  final settingsJson = value is Map<String, dynamic>
      ? value
      : Map<String, dynamic>.from(value as Map);

  return DailyReviewReminderSettings(
    isEnabled: _boolFromJson(settingsJson, 'isEnabled'),
    timeMinutes: _intFromJson(settingsJson, 'timeMinutes'),
  );
}

String _dateToJson(DateTime date) {
  return date.toIso8601String();
}

String? _nullableDateToJson(DateTime? date) {
  return date?.toIso8601String();
}

DateTime _dateFromJson(Map<String, dynamic> json, String field) {
  final value = _stringFromJson(json, field);

  return DateTime.parse(value);
}

DateTime? _nullableDateFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value == null) {
    return null;
  }

  if (value is! String) {
    throw FormatException('$field must be a date string or null.');
  }

  return DateTime.parse(value);
}

String _stringFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value is String) {
    return value;
  }

  throw FormatException('$field must be a string.');
}

String? _nullableStringFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value == null || value is String) {
    return value;
  }

  throw FormatException('$field must be a string or null.');
}

int _intFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value is int) {
    return value;
  }

  throw FormatException('$field must be an int.');
}

int? _nullableIntFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value == null || value is int) {
    return value;
  }

  throw FormatException('$field must be an int or null.');
}

bool _boolFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value is bool) {
    return value;
  }

  throw FormatException('$field must be a bool.');
}

Map<String, dynamic> _mapFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value is Map<String, dynamic>) {
    return value;
  }

  if (value is Map) {
    return Map<String, dynamic>.from(value);
  }

  throw FormatException('$field must be an object.');
}

List<Map<String, dynamic>> _mapListFromJson(
  Map<String, dynamic> json,
  String field,
) {
  final value = json[field];

  if (value == null) {
    return const [];
  }

  if (value is! List) {
    throw FormatException('$field must be a list.');
  }

  return value
      .map((item) {
        if (item is Map<String, dynamic>) {
          return item;
        }

        if (item is Map) {
          return Map<String, dynamic>.from(item);
        }

        throw FormatException('$field must contain objects.');
      })
      .toList(growable: false);
}

List<int> _intListFromJson(Map<String, dynamic> json, String field) {
  final value = json[field];

  if (value == null) {
    return const [];
  }

  if (value is! List) {
    throw FormatException('$field must be a list of ints.');
  }

  return value
      .map((item) {
        if (item is int) {
          return item;
        }

        throw FormatException('$field must contain only ints.');
      })
      .toList(growable: false);
}

T _enumFromJson<T extends Enum>(
  List<T> values,
  Map<String, dynamic> json,
  String field,
) {
  final value = _stringFromJson(json, field);

  for (final enumValue in values) {
    if (enumValue.name == value) {
      return enumValue;
    }
  }

  throw FormatException('$field has unsupported value: $value.');
}
