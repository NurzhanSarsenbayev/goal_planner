import '../features/tasks/application/task_repository.dart';
import '../features/goals/application/goal_repository.dart';
import '../features/milestones/application/milestone_repository.dart';
import '../data/sample_data.dart';

class PlannerSeedService {
  const PlannerSeedService({
    required GoalRepository goalRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
  }) : _goalRepository = goalRepository,
       _milestoneRepository = milestoneRepository,
       _taskRepository = taskRepository;

  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;

  Future<void> seedInitialData() async {
    for (final goal in sampleGoals) {
      await _goalRepository.saveGoal(goal);
    }

    for (final milestone in sampleMilestones) {
      await _milestoneRepository.saveMilestone(milestone);
    }

    for (final task in sampleTasks) {
      await _taskRepository.saveTask(task);
    }
  }
}
