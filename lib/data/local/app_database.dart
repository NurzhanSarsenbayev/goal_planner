import 'dart:io';

import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';

part 'app_database.g.dart';

class Goals extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get status => text()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Milestones extends Table {
  TextColumn get id => text()();

  TextColumn get goalId => text().references(Goals, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurringTaskRules extends Table {
  TextColumn get id => text()();

  TextColumn get goalId => text().nullable().references(Goals, #id)();

  TextColumn get milestoneId => text().nullable().references(Milestones, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get recurrenceType => text()();

  TextColumn get weekdays => text().nullable()();

  IntColumn get monthDay => integer().nullable()();

  DateTimeColumn get startDate => dateTime()();

  DateTimeColumn get endDate => dateTime().nullable()();

  BoolColumn get isActive => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  IntColumn get scheduledTimeMinutes => integer().nullable()();

  IntColumn get reminderMinutesBefore => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class RecurringTaskExceptions extends Table {
  TextColumn get id => text()();

  TextColumn get ruleId => text().references(RecurringTaskRules, #id)();

  DateTimeColumn get date => dateTime()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Tasks extends Table {
  TextColumn get id => text()();

  TextColumn get goalId => text().nullable().references(Goals, #id)();

  TextColumn get milestoneId => text().nullable().references(Milestones, #id)();

  TextColumn get recurringRuleId =>
      text().nullable().references(RecurringTaskRules, #id)();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  DateTimeColumn get scheduledDate => dateTime().nullable()();

  IntColumn get scheduledTimeMinutes => integer().nullable()();

  IntColumn get reminderMinutesBefore => integer().nullable()();

  BoolColumn get isCompleted => boolean().withDefault(const Constant(false))();

  DateTimeColumn get completedAt => dateTime().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class Habits extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get description => text().withDefault(const Constant(''))();

  TextColumn get trackingType => text()();

  IntColumn get targetCount => integer().nullable()();

  IntColumn get sortOrder => integer()();

  BoolColumn get isArchived => boolean().withDefault(const Constant(false))();

  BoolColumn get isReminderEnabled =>
      boolean().withDefault(const Constant(false))();

  IntColumn get reminderTimeMinutes => integer().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class HabitEntries extends Table {
  TextColumn get id => text()();

  TextColumn get habitId =>
      text().references(Habits, #id, onDelete: KeyAction.cascade)();

  DateTimeColumn get date => dateTime()();

  TextColumn get status => text()();

  IntColumn get completedCount => integer().withDefault(const Constant(0))();

  TextColumn get note => text().nullable()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class StandaloneReminders extends Table {
  TextColumn get id => text()();

  TextColumn get title => text()();

  TextColumn get scheduleType => text().withDefault(const Constant('daily'))();

  DateTimeColumn get scheduledDate => dateTime().nullable()();

  IntColumn get timeMinutes => integer()();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class DailyReviewReminderSettingsTable extends Table {
  @override
  String get tableName => 'daily_review_reminder_settings';

  TextColumn get id => text()();

  BoolColumn get isEnabled => boolean().withDefault(const Constant(true))();

  IntColumn get timeMinutes => integer().withDefault(const Constant(21 * 60))();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyWeightEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get weightKg => real().nullable()();

  BoolColumn get isSkipped => boolean().withDefault(const Constant(false))();

  TextColumn get note => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyMeasurementEntries extends Table {
  TextColumn get id => text()();

  DateTimeColumn get date => dateTime()();

  RealColumn get neckCm => real().nullable()();

  RealColumn get waistCm => real().nullable()();

  RealColumn get hipsCm => real().nullable()();

  TextColumn get note => text().withDefault(const Constant(''))();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

class BodyProfiles extends Table {
  TextColumn get id => text()();

  RealColumn get heightCm => real()();

  TextColumn get bodyFatFormula => text()();

  DateTimeColumn get createdAt => dateTime()();

  DateTimeColumn get updatedAt => dateTime()();

  @override
  Set<Column> get primaryKey => {id};
}

@DriftDatabase(
  tables: [
    Goals,
    Milestones,
    RecurringTaskRules,
    RecurringTaskExceptions,
    Tasks,
    Habits,
    HabitEntries,
    StandaloneReminders,
    DailyReviewReminderSettingsTable,
    BodyWeightEntries,
    BodyMeasurementEntries,
    BodyProfiles,
  ],
)
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 13;

  @override
  MigrationStrategy get migration {
    return MigrationStrategy(
      onUpgrade: (migrator, from, to) async {
        if (from < 2) {
          await migrator.createTable(recurringTaskRules);
          await migrator.createTable(recurringTaskExceptions);
          await migrator.addColumn(tasks, tasks.recurringRuleId);
        }

        if (from < 3) {
          await migrator.createTable(habits);
          await migrator.createTable(habitEntries);
        }

        if (from < 4) {
          await migrator.addColumn(tasks, tasks.scheduledTimeMinutes);
        }

        if (from < 5) {
          await migrator.addColumn(tasks, tasks.reminderMinutesBefore);
        }

        if (from < 6) {
          await migrator.createTable(standaloneReminders);
        }

        if (from < 7) {
          if (!await _columnExists('standalone_reminders', 'schedule_type')) {
            await migrator.addColumn(
              standaloneReminders,
              standaloneReminders.scheduleType,
            );
          }

          if (!await _columnExists('standalone_reminders', 'scheduled_date')) {
            await migrator.addColumn(
              standaloneReminders,
              standaloneReminders.scheduledDate,
            );
          }
        }

        if (from < 8) {
          await migrator.createTable(dailyReviewReminderSettingsTable);
        }

        if (from < 9) {
          if (!await _columnExists('habits', 'is_reminder_enabled')) {
            await migrator.addColumn(habits, habits.isReminderEnabled);
          }

          if (!await _columnExists('habits', 'reminder_time_minutes')) {
            await migrator.addColumn(habits, habits.reminderTimeMinutes);
          }
        }

        if (from < 10) {
          if (!await _columnExists(
            'recurring_task_rules',
            'scheduled_time_minutes',
          )) {
            await migrator.addColumn(
              recurringTaskRules,
              recurringTaskRules.scheduledTimeMinutes,
            );
          }

          if (!await _columnExists(
            'recurring_task_rules',
            'reminder_minutes_before',
          )) {
            await migrator.addColumn(
              recurringTaskRules,
              recurringTaskRules.reminderMinutesBefore,
            );
          }
        }

        if (from < 11) {
          await migrator.createTable(bodyWeightEntries);
        }

        if (from < 12) {
          await migrator.createTable(bodyMeasurementEntries);
        }

        if (from < 13) {
          await migrator.createTable(bodyProfiles);
        }
      },
    );
  }

  Future<bool> _columnExists(String tableName, String columnName) async {
    final rows = await customSelect('PRAGMA table_info($tableName)').get();

    return rows.any((row) => row.data['name'] == columnName);
  }
}

LazyDatabase _openConnection() {
  return LazyDatabase(() async {
    final dbFolder = await getApplicationDocumentsDirectory();
    final file = File(path.join(dbFolder.path, 'goal_planner.sqlite'));

    return NativeDatabase.createInBackground(file);
  });
}
