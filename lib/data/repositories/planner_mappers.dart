import '../../models/goal.dart' as domain;
import '../../models/milestone.dart' as domain;
import '../../models/planner_task.dart' as domain;
import '../local/app_database.dart' as local;

domain.Goal mapGoal(local.Goal row) {
  return domain.Goal(
    id: row.id,
    title: row.title,
    description: row.description,
    status: mapGoalStatus(row.status),
    createdAt: row.createdAt,
  );
}

domain.Milestone mapMilestone(local.Milestone row) {
  return domain.Milestone(
    id: row.id,
    goalId: row.goalId,
    title: row.title,
    description: row.description,
    createdAt: row.createdAt,
  );
}

domain.PlannerTask mapTask(local.Task row) {
  return domain.PlannerTask(
    id: row.id,
    goalId: row.goalId,
    milestoneId: row.milestoneId,
    recurringRuleId: row.recurringRuleId,
    title: row.title,
    description: row.description,
    scheduledDate: row.scheduledDate,
    isCompleted: row.isCompleted,
    completedAt: row.completedAt,
    createdAt: row.createdAt,
  );
}

domain.GoalStatus mapGoalStatus(String value) {
  for (final status in domain.GoalStatus.values) {
    if (status.name == value) {
      return status;
    }
  }

  return domain.GoalStatus.active;
}
