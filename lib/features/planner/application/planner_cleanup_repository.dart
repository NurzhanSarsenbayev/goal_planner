abstract class PlannerCleanupRepository {
  Future<void> deleteGoalWithRelatedData(String goalId);

  Future<void> deleteMilestoneAndMoveTasksToDirect(String milestoneId);

  Future<void> deleteMilestoneWithTasks(String milestoneId);
}
