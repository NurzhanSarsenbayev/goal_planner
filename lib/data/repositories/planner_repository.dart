import 'package:drift/drift.dart' as drift;

import '../../models/goal.dart' as domain;
import '../../models/milestone.dart' as domain;
import '../../models/planner_task.dart' as domain;
import '../../models/recurring_task_exception.dart' as domain;
import '../../models/recurring_task_rule.dart' as domain;
import '../local/app_database.dart' as local;
import 'planner_mappers.dart';

class PlannerRepository {
  const PlannerRepository(this._database);

  final local.AppDatabase _database;

  Future<List<domain.Goal>> loadGoals() async {
    final rows = await _database.select(_database.goals).get();

    return rows.map(mapGoal).toList();
  }

  Future<List<domain.Milestone>> loadMilestones() async {
    final rows = await _database.select(_database.milestones).get();

    return rows.map(mapMilestone).toList();
  }

  Future<List<domain.PlannerTask>> loadTasks() async {
    final rows = await _database.select(_database.tasks).get();

    return rows.map(mapTask).toList();
  }

  Future<List<domain.RecurringTaskRule>> loadRecurringTaskRules() async {
    final rows = await _database.select(_database.recurringTaskRules).get();

    return rows.map(mapRecurringTaskRule).toList();
  }

  Future<List<domain.RecurringTaskException>>
  loadRecurringTaskExceptions() async {
    final rows = await _database
        .select(_database.recurringTaskExceptions)
        .get();

    return rows.map(mapRecurringTaskException).toList();
  }

  Future<void> saveGoal(domain.Goal goal) async {
    await _database
        .into(_database.goals)
        .insertOnConflictUpdate(
          local.GoalsCompanion.insert(
            id: goal.id,
            title: goal.title,
            description: drift.Value(goal.description),
            status: goal.status.name,
            createdAt: goal.createdAt,
          ),
        );
  }

  Future<void> deleteGoalWithRelatedData(String goalId) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.tasks,
      )..where((table) => table.goalId.equals(goalId))).go();

      await (_database.delete(
        _database.milestones,
      )..where((table) => table.goalId.equals(goalId))).go();

      await (_database.delete(
        _database.goals,
      )..where((table) => table.id.equals(goalId))).go();
    });
  }

  Future<void> saveMilestone(domain.Milestone milestone) async {
    await _database
        .into(_database.milestones)
        .insertOnConflictUpdate(
          local.MilestonesCompanion.insert(
            id: milestone.id,
            goalId: milestone.goalId,
            title: milestone.title,
            description: drift.Value(milestone.description),
            createdAt: milestone.createdAt,
          ),
        );
  }

  Future<void> deleteMilestoneAndMoveTasksToDirect(String milestoneId) async {
    await _database.transaction(() async {
      await (_database.update(_database.tasks)
            ..where((table) => table.milestoneId.equals(milestoneId)))
          .write(const local.TasksCompanion(milestoneId: drift.Value(null)));

      await (_database.delete(
        _database.milestones,
      )..where((table) => table.id.equals(milestoneId))).go();
    });
  }

  Future<void> deleteMilestoneWithTasks(String milestoneId) async {
    await _database.transaction(() async {
      await (_database.delete(
        _database.tasks,
      )..where((table) => table.milestoneId.equals(milestoneId))).go();

      await (_database.delete(
        _database.milestones,
      )..where((table) => table.id.equals(milestoneId))).go();
    });
  }

  Future<void> saveTask(domain.PlannerTask task) async {
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

  Future<void> saveRecurringTaskRule(domain.RecurringTaskRule rule) async {
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

  Future<void> saveRecurringTaskException(
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

  Future<void> saveRecurringTaskRuleWithGeneratedTasks({
    required domain.RecurringTaskRule rule,
    required List<domain.PlannerTask> generatedTasks,
  }) async {
    await _database.transaction(() async {
      await saveRecurringTaskRule(rule);

      for (final task in generatedTasks) {
        await saveTask(task);
      }
    });
  }

  Future<void> deactivateRecurringTaskRule(
    domain.RecurringTaskRule rule,
  ) async {
    await _database.transaction(() async {
      await saveRecurringTaskRule(rule);

      await (_database.delete(_database.tasks)..where((table) {
            return table.recurringRuleId.equals(rule.id) &
                table.isCompleted.equals(false);
          }))
          .go();
    });
  }

  Future<void> deleteRecurringTaskRuleSeries(String ruleId) async {
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

  Future<void> updateRecurringTaskRuleAndRebuildOccurrences({
    required domain.RecurringTaskRule rule,
    required List<domain.PlannerTask> generatedTasks,
  }) async {
    await _database.transaction(() async {
      await (_database.delete(_database.tasks)..where((table) {
            return table.recurringRuleId.equals(rule.id) &
                table.isCompleted.equals(false);
          }))
          .go();

      await saveRecurringTaskRule(rule);

      for (final task in generatedTasks) {
        await saveTask(task);
      }
    });
  }

  Future<void> deleteTask(String taskId) async {
    await (_database.delete(
      _database.tasks,
    )..where((table) => table.id.equals(taskId))).go();
  }

  Future<void> deleteTaskWithRecurringException({
    required String taskId,
    required domain.RecurringTaskException exception,
  }) async {
    await _database.transaction(() async {
      await saveRecurringTaskException(exception);
      await deleteTask(taskId);
    });
  }

  Future<void> updateTaskWithRecurringException({
    required domain.PlannerTask task,
    required domain.RecurringTaskException exception,
  }) async {
    await _database.transaction(() async {
      await saveRecurringTaskException(exception);
      await updateTask(task);
    });
  }

  Future<void> updateTask(domain.PlannerTask task) async {
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

  Future<void> toggleTaskCompleted(String taskId) async {
    final task = await (_database.select(
      _database.tasks,
    )..where((table) => table.id.equals(taskId))).getSingleOrNull();

    if (task == null) {
      return;
    }

    final nextCompletedState = !task.isCompleted;

    await (_database.update(
      _database.tasks,
    )..where((table) => table.id.equals(taskId))).write(
      local.TasksCompanion(
        isCompleted: drift.Value(nextCompletedState),
        completedAt: drift.Value(nextCompletedState ? DateTime.now() : null),
      ),
    );
  }

  Future<void> scheduleTaskForToday(String taskId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await (_database.update(_database.tasks)
          ..where((table) => table.id.equals(taskId)))
        .write(local.TasksCompanion(scheduledDate: drift.Value(today)));
  }
}
