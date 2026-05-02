import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';

class GoalDetailsViewBuilder {
  const GoalDetailsViewBuilder();

  GoalDetailsView build({
    required Goal goal,
    required List<Milestone> milestones,
    required List<PlannerTask> tasks,
  }) {
    final goalTasks = tasks.where((task) => task.goalId == goal.id).toList();

    final goalMilestones = milestones
        .where((milestone) => milestone.goalId == goal.id)
        .toList();

    final milestoneIds = goalMilestones
        .map((milestone) => milestone.id)
        .toSet();

    final directGoalTasks = goalTasks
        .where(
          (task) =>
              task.milestoneId == null ||
              !milestoneIds.contains(task.milestoneId),
        )
        .toList();

    final completedTasks = goalTasks.where((task) => task.isCompleted).length;

    final tasksByMilestoneId = <String, List<PlannerTask>>{};

    for (final milestone in goalMilestones) {
      tasksByMilestoneId[milestone.id] = goalTasks
          .where((task) => task.milestoneId == milestone.id)
          .toList();
    }

    return GoalDetailsView(
      goalTasks: goalTasks,
      goalMilestones: goalMilestones,
      directGoalTasks: directGoalTasks,
      completedTasks: completedTasks,
      tasksByMilestoneId: tasksByMilestoneId,
    );
  }
}

class GoalDetailsView {
  const GoalDetailsView({
    required this.goalTasks,
    required this.goalMilestones,
    required this.directGoalTasks,
    required this.completedTasks,
    required this.tasksByMilestoneId,
  });

  final List<PlannerTask> goalTasks;
  final List<Milestone> goalMilestones;
  final List<PlannerTask> directGoalTasks;
  final int completedTasks;
  final Map<String, List<PlannerTask>> tasksByMilestoneId;

  List<PlannerTask> tasksForMilestone(String milestoneId) {
    return tasksByMilestoneId[milestoneId] ?? const [];
  }
}
