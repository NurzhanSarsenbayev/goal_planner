import 'package:drift/drift.dart' as drift;

import '../../features/recurring/application/recurring_task_repository.dart';
import '../../models/planner_task.dart' as domain;
import '../../models/recurring_task_exception.dart' as domain;
import '../../models/recurring_task_rule.dart' as domain;
import '../local/app_database.dart' as local;
import 'planner_mappers.dart';

class DriftRecurringTaskRepository implements RecurringTaskRepository {
  const DriftRecurringTaskRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.RecurringTaskRule>> loadRecurringTaskRules() async {
    final rows = await _database.select(_database.recurringTaskRules).get();

    return rows.map(mapRecurringTaskRule).toList();
  }

  @override
  Future<List<domain.RecurringTaskException>>
  loadRecurringTaskExceptions() async {
    final rows = await _database
        .select(_database.recurringTaskExceptions)
        .get();

    return rows.map(mapRecurringTaskException).toList();
  }

  @override
  Future<void> saveGeneratedOccurrences(
    List<domain.PlannerTask> generatedTasks,
  ) async {
    await _database.transaction(() async {
      for (final task in generatedTasks) {
        await _saveTask(task);
      }
    });
  }

  @override
  Future<void> saveRecurringTaskRuleWithOccurrences({
    required domain.RecurringTaskRule rule,
    required List<domain.PlannerTask> generatedTasks,
  }) async {
    await _database.transaction(() async {
      await _saveRecurringTaskRule(rule);

      for (final task in generatedTasks) {
        await _saveTask(task);
      }
    });
  }

  @override
  Future<void> deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
    domain.RecurringTaskRule rule,
  ) async {
    await _database.transaction(() async {
      await _saveRecurringTaskRule(rule);

      await (_database.delete(_database.tasks)..where((table) {
            return table.recurringRuleId.equals(rule.id) &
                table.isCompleted.equals(false);
          }))
          .go();
    });
  }

  @override
  Future<void> deleteRecurringTaskRuleAndCleanSeries(String ruleId) async {
    await _database.transaction(() async {
      await (_database.delete(_database.tasks)..where((table) {
            return table.recurringRuleId.equals(ruleId) &
                table.isCompleted.equals(false);
          }))
          .go();

      await (_database.update(_database.tasks)..where((table) {
            return table.recurringRuleId.equals(ruleId) &
                table.isCompleted.equals(true);
          }))
          .write(
            const local.TasksCompanion(recurringRuleId: drift.Value(null)),
          );

      await (_database.delete(
        _database.recurringTaskExceptions,
      )..where((table) => table.ruleId.equals(ruleId))).go();

      await (_database.delete(
        _database.recurringTaskRules,
      )..where((table) => table.id.equals(ruleId))).go();
    });
  }

  @override
  Future<void> updateRecurringTaskRuleAndReplaceUnfinishedOccurrences({
    required domain.RecurringTaskRule rule,
    required List<domain.PlannerTask> generatedTasks,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.tasks)..where((table) {
            return table.recurringRuleId.equals(rule.id) &
                table.isCompleted.equals(false);
          }))
          .go();

      await _saveRecurringTaskRule(rule);

      for (final task in generatedTasks) {
        await _saveTask(task);
      }
    });
  }

  @override
  Future<void> deleteTaskWithRecurringException({
    required String taskId,
    required domain.RecurringTaskException exception,
  }) async {
    await _database.transaction(() async {
      await _saveRecurringTaskException(exception);
      await _deleteTask(taskId);
    });
  }

  @override
  Future<void> updateTaskWithRecurringException({
    required domain.PlannerTask task,
    required domain.RecurringTaskException exception,
  }) async {
    await _database.transaction(() async {
      await _saveRecurringTaskException(exception);
      await _updateTask(task);
    });
  }

  Future<void> _saveRecurringTaskRule(domain.RecurringTaskRule rule) async {
    await _database
        .into(_database.recurringTaskRules)
        .insertOnConflictUpdate(
          local.RecurringTaskRulesCompanion.insert(
            id: rule.id,
            goalId: drift.Value(rule.goalId),
            milestoneId: drift.Value(rule.milestoneId),
            title: rule.title,
            description: drift.Value(rule.description),
            recurrenceType: recurrenceTypeToDatabaseValue(rule.recurrenceType),
            weekdays: drift.Value(weekdaysToDatabaseValue(rule.weekdays)),
            monthDay: drift.Value(rule.monthDay),
            startDate: rule.startDate,
            endDate: drift.Value(rule.endDate),
            isActive: drift.Value(rule.isActive),
            createdAt: rule.createdAt,
          ),
        );
  }

  Future<void> _saveRecurringTaskException(
    domain.RecurringTaskException exception,
  ) async {
    await _database
        .into(_database.recurringTaskExceptions)
        .insertOnConflictUpdate(
          local.RecurringTaskExceptionsCompanion.insert(
            id: exception.id,
            ruleId: exception.ruleId,
            date: exception.date,
            createdAt: exception.createdAt,
          ),
        );
  }

  Future<void> _saveTask(domain.PlannerTask task) async {
    await _database
        .into(_database.tasks)
        .insertOnConflictUpdate(
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

  Future<void> _updateTask(domain.PlannerTask task) async {
    await (_database.update(
      _database.tasks,
    )..where((table) => table.id.equals(task.id))).write(
      local.TasksCompanion(
        goalId: drift.Value(task.goalId),
        milestoneId: drift.Value(task.milestoneId),
        recurringRuleId: drift.Value(task.recurringRuleId),
        title: drift.Value(task.title),
        description: drift.Value(task.description),
        scheduledDate: drift.Value(task.scheduledDate),
        isCompleted: drift.Value(task.isCompleted),
        completedAt: drift.Value(task.completedAt),
        createdAt: drift.Value(task.createdAt),
      ),
    );
  }

  Future<void> _deleteTask(String taskId) async {
    await (_database.delete(
      _database.tasks,
    )..where((table) => table.id.equals(taskId))).go();
  }
}
