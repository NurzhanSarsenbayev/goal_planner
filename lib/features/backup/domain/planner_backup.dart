import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../habits/domain/habit.dart';
import '../../habits/domain/habit_entry.dart';
import '../../habits/domain/habit_entry_status.dart';
import '../../habits/domain/habit_tracking_type.dart';

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
  });

  const PlannerBackupData.empty()
    : goals = const [],
      milestones = const [],
      tasks = const [],
      recurringRules = const [],
      recurringExceptions = const [],
      habits = const [],
      habitEntries = const [];

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
  final List<Habit> habits;
  final List<HabitEntry> habitEntries;

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
    };
  }
}

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
    createdAt: _dateFromJson(json, 'createdAt'),
    updatedAt: _dateFromJson(json, 'updatedAt'),
  );
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
