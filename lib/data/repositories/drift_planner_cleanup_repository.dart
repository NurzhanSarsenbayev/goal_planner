import 'package:drift/drift.dart' as drift;

import '../local/app_database.dart' as local;
import '../../features/planner/application/planner_cleanup_repository.dart';

class DriftPlannerCleanupRepository implements PlannerCleanupRepository {
  const DriftPlannerCleanupRepository(this._database);

  final local.AppDatabase _database;

  @override
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

  @override
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

  @override
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
}
