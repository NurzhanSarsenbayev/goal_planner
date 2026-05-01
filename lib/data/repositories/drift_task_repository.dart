import 'package:drift/drift.dart' as drift;

import '../../features/tasks/application/task_repository.dart';
import '../../models/planner_task.dart' as domain;
import '../local/app_database.dart' as local;
import 'planner_mappers.dart';

class DriftTaskRepository implements TaskRepository {
  const DriftTaskRepository(this._database);

  final local.AppDatabase _database;

  @override
  Future<List<domain.PlannerTask>> loadTasks() async {
    final rows = await _database.select(_database.tasks).get();

    return rows.map(mapTask).toList();
  }

  @override
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

  @override
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

  @override
  Future<void> deleteTask(String taskId) async {
    await (_database.delete(
      _database.tasks,
    )..where((table) => table.id.equals(taskId))).go();
  }
}
