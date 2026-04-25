import 'package:drift/drift.dart' as drift;

import '../../models/goal.dart' as domain;
import '../../models/milestone.dart' as domain;
import '../../models/planner_task.dart' as domain;
import '../local/app_database.dart' as local;

class PlannerRepository {
  const PlannerRepository(this._database);

  final local.AppDatabase _database;

  Future<List<domain.Goal>> loadGoals() async {
    final rows = await _database.select(_database.goals).get();

    return rows.map(_mapGoal).toList();
  }

  Future<List<domain.Milestone>> loadMilestones() async {
    final rows = await _database.select(_database.milestones).get();

    return rows.map(_mapMilestone).toList();
  }

  Future<List<domain.PlannerTask>> loadTasks() async {
    final rows = await _database.select(_database.tasks).get();

    return rows.map(_mapTask).toList();
  }

  Future<void> saveGoal(domain.Goal goal) async {
    await _database.into(_database.goals).insertOnConflictUpdate(
          local.GoalsCompanion.insert(
            id: goal.id,
            title: goal.title,
            description: drift.Value(goal.description),
            status: goal.status.name,
            createdAt: goal.createdAt,
          ),
        );
  }

  Future<void> saveMilestone(domain.Milestone milestone) async {
    await _database.into(_database.milestones).insertOnConflictUpdate(
          local.MilestonesCompanion.insert(
            id: milestone.id,
            goalId: milestone.goalId,
            title: milestone.title,
            description: drift.Value(milestone.description),
            createdAt: milestone.createdAt,
          ),
        );
  }

  Future<void> saveTask(domain.PlannerTask task) async {
    await _database.into(_database.tasks).insertOnConflictUpdate(
          local.TasksCompanion.insert(
            id: task.id,
            goalId: drift.Value(task.goalId),
            milestoneId: drift.Value(task.milestoneId),
            title: task.title,
            description: drift.Value(task.description),
            scheduledDate: drift.Value(task.scheduledDate),
            isCompleted: drift.Value(task.isCompleted),
            completedAt: drift.Value(task.completedAt),
            createdAt: task.createdAt,
          ),
        );
  }

  Future<void> updateTask(domain.PlannerTask task) async {
    await (_database.update(_database.tasks)
          ..where((table) => table.id.equals(task.id)))
        .write(
      local.TasksCompanion(
        goalId: drift.Value(task.goalId),
        milestoneId: drift.Value(task.milestoneId),
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
    final task = await (_database.select(_database.tasks)
          ..where((table) => table.id.equals(taskId)))
        .getSingleOrNull();

    if (task == null) {
      return;
    }

    final nextCompletedState = !task.isCompleted;

    await (_database.update(_database.tasks)
          ..where((table) => table.id.equals(taskId)))
        .write(
      local.TasksCompanion(
        isCompleted: drift.Value(nextCompletedState),
        completedAt: drift.Value(
          nextCompletedState ? DateTime.now() : null,
        ),
      ),
    );
  }

  Future<void> scheduleTaskForToday(String taskId) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    await (_database.update(_database.tasks)
          ..where((table) => table.id.equals(taskId)))
        .write(
      local.TasksCompanion(
        scheduledDate: drift.Value(today),
      ),
    );
  }

  domain.Goal _mapGoal(local.Goal row) {
    return domain.Goal(
      id: row.id,
      title: row.title,
      description: row.description,
      status: _mapGoalStatus(row.status),
      createdAt: row.createdAt,
    );
  }

  domain.Milestone _mapMilestone(local.Milestone row) {
    return domain.Milestone(
      id: row.id,
      goalId: row.goalId,
      title: row.title,
      description: row.description,
      createdAt: row.createdAt,
    );
  }

  domain.PlannerTask _mapTask(local.Task row) {
    return domain.PlannerTask(
      id: row.id,
      goalId: row.goalId,
      milestoneId: row.milestoneId,
      title: row.title,
      description: row.description,
      scheduledDate: row.scheduledDate,
      isCompleted: row.isCompleted,
      completedAt: row.completedAt,
      createdAt: row.createdAt,
    );
  }

  domain.GoalStatus _mapGoalStatus(String value) {
    for (final status in domain.GoalStatus.values) {
      if (status.name == value) {
        return status;
      }
    }

    return domain.GoalStatus.active;
  }
}