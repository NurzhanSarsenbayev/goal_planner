import 'package:drift/drift.dart' as drift;

import '../../features/milestones/application/milestone_repository.dart';
import '../../models/milestone.dart' as domain;
import '../local/app_database.dart' as local;
import 'planner_mappers.dart';

class DriftMilestoneRepository implements MilestoneRepository {
  const DriftMilestoneRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.Milestone>> loadMilestones() async {
    final rows = await _database.select(_database.milestones).get();

    return rows.map(mapMilestone).toList();
  }

  @override
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
}
