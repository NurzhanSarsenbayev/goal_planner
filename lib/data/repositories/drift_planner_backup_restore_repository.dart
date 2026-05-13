import 'package:drift/drift.dart' as drift;

import '../../features/backup/application/planner_backup_restore_repository.dart';
import '../../features/backup/domain/planner_backup.dart';
import '../local/app_database.dart' as local;
import 'habit_mappers.dart';
import 'planner_mappers.dart';

class DriftPlannerBackupRestoreRepository
    implements PlannerBackupRestoreRepository {
  const DriftPlannerBackupRestoreRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<void> replaceAll(PlannerBackupData data) async {
    await _database.transaction(() async {
      await _deleteExistingData();
      await _insertBackupData(data);
    });
  }

  Future<void> _deleteExistingData() async {
    await _database.delete(_database.habitEntries).go();
    await _database.delete(_database.tasks).go();
    await _database.delete(_database.recurringTaskExceptions).go();
    await _database.delete(_database.recurringTaskRules).go();
    await _database.delete(_database.milestones).go();
    await _database.delete(_database.goals).go();
    await _database.delete(_database.habits).go();
  }

  Future<void> _insertBackupData(PlannerBackupData data) async {
    for (final goal in data.goals) {
      await _database
          .into(_database.goals)
          .insert(
            local.GoalsCompanion.insert(
              id: goal.id,
              title: goal.title,
              description: drift.Value(goal.description),
              status: goal.status.name,
              createdAt: goal.createdAt,
            ),
          );
    }

    for (final milestone in data.milestones) {
      await _database
          .into(_database.milestones)
          .insert(
            local.MilestonesCompanion.insert(
              id: milestone.id,
              goalId: milestone.goalId,
              title: milestone.title,
              description: drift.Value(milestone.description),
              createdAt: milestone.createdAt,
            ),
          );
    }

    for (final rule in data.recurringRules) {
      await _database
          .into(_database.recurringTaskRules)
          .insert(
            local.RecurringTaskRulesCompanion.insert(
              id: rule.id,
              goalId: drift.Value(rule.goalId),
              milestoneId: drift.Value(rule.milestoneId),
              title: rule.title,
              description: drift.Value(rule.description),
              recurrenceType: recurrenceTypeToDatabaseValue(
                rule.recurrenceType,
              ),
              weekdays: drift.Value(weekdaysToDatabaseValue(rule.weekdays)),
              monthDay: drift.Value(rule.monthDay),
              startDate: rule.startDate,
              endDate: drift.Value(rule.endDate),
              isActive: drift.Value(rule.isActive),
              createdAt: rule.createdAt,
            ),
          );
    }

    for (final task in data.tasks) {
      await _database
          .into(_database.tasks)
          .insert(
            local.TasksCompanion.insert(
              id: task.id,
              goalId: drift.Value(task.goalId),
              milestoneId: drift.Value(task.milestoneId),
              recurringRuleId: drift.Value(task.recurringRuleId),
              title: task.title,
              description: drift.Value(task.description),
              scheduledDate: drift.Value(task.scheduledDate),
              isCompleted: drift.Value(task.isCompleted),
              completedAt: drift.Value(task.completedAt),
              createdAt: task.createdAt,
            ),
          );
    }

    for (final exception in data.recurringExceptions) {
      await _database
          .into(_database.recurringTaskExceptions)
          .insert(
            local.RecurringTaskExceptionsCompanion.insert(
              id: exception.id,
              ruleId: exception.ruleId,
              date: exception.date,
              createdAt: exception.createdAt,
            ),
          );
    }

    for (final habit in data.habits) {
      await _database
          .into(_database.habits)
          .insert(
            local.HabitsCompanion.insert(
              id: habit.id,
              title: habit.title,
              description: drift.Value(habit.description),
              trackingType: habitTrackingTypeToDatabaseValue(
                habit.trackingType,
              ),
              targetCount: drift.Value(habit.targetCount),
              sortOrder: habit.sortOrder,
              isArchived: drift.Value(habit.isArchived),
              createdAt: habit.createdAt,
              updatedAt: habit.updatedAt,
            ),
          );
    }

    for (final entry in data.habitEntries) {
      await _database
          .into(_database.habitEntries)
          .insert(
            local.HabitEntriesCompanion.insert(
              id: entry.id,
              habitId: entry.habitId,
              date: entry.date,
              status: habitEntryStatusToDatabaseValue(entry.status),
              completedCount: drift.Value(entry.completedCount),
              note: drift.Value(entry.note),
              createdAt: entry.createdAt,
              updatedAt: entry.updatedAt,
            ),
          );
    }
  }
}
