import 'package:drift/drift.dart' as drift;

import '../../models/goal.dart' as domain;
import '../../models/milestone.dart' as domain;
import '../../models/planner_task.dart' as domain;
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
      final recurringRules = await (_database.select(
        _database.recurringTaskRules,
      )..where((table) => table.goalId.equals(goalId))).get();

      final recurringRuleIds = recurringRules.map((rule) => rule.id).toList();

      await (_database.delete(
        _database.tasks,
      )..where((table) => table.goalId.equals(goalId))).go();

      for (final ruleId in recurringRuleIds) {
        await (_database.delete(
          _database.recurringTaskExceptions,
        )..where((table) => table.ruleId.equals(ruleId))).go();
      }

      await (_database.delete(
        _database.recurringTaskRules,
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

      await (_database.update(
        _database.recurringTaskRules,
      )..where((table) => table.milestoneId.equals(milestoneId))).write(
        const local.RecurringTaskRulesCompanion(milestoneId: drift.Value(null)),
      );

      await (_database.delete(
        _database.milestones,
      )..where((table) => table.id.equals(milestoneId))).go();
    });
  }

  Future<void> deleteMilestoneWithTasks(String milestoneId) async {
    await _database.transaction(() async {
      final recurringRules = await (_database.select(
        _database.recurringTaskRules,
      )..where((table) => table.milestoneId.equals(milestoneId))).get();

      final recurringRuleIds = recurringRules.map((rule) => rule.id).toList();

      await (_database.delete(
        _database.tasks,
      )..where((table) => table.milestoneId.equals(milestoneId))).go();

      for (final ruleId in recurringRuleIds) {
        await (_database.delete(
          _database.recurringTaskExceptions,
        )..where((table) => table.ruleId.equals(ruleId))).go();
      }

      await (_database.delete(
        _database.recurringTaskRules,
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

  Future<void> deleteTask(String taskId) async {
    await (_database.delete(
      _database.tasks,
    )..where((table) => table.id.equals(taskId))).go();
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
