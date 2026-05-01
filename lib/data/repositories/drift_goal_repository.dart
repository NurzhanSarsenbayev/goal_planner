import 'package:drift/drift.dart' as drift;

import '../../features/goals/application/goal_repository.dart';
import '../../models/goal.dart' as domain;
import '../local/app_database.dart' as local;
import 'planner_mappers.dart';

class DriftGoalRepository implements GoalRepository {
  const DriftGoalRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.Goal>> loadGoals() async {
    final rows = await _database.select(_database.goals).get();

    return rows.map(mapGoal).toList();
  }

  @override
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
}
