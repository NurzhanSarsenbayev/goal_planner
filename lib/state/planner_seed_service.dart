import '../features/tasks/application/task_repository.dart';
import '../data/repositories/planner_repository.dart';
import '../data/sample_data.dart';

class PlannerSeedService {
  const PlannerSeedService({
    required PlannerRepository repository,
    required TaskRepository taskRepository,
  }) : _repository = repository,
       _taskRepository = taskRepository;

  final PlannerRepository _repository;
  final TaskRepository _taskRepository;

  Future<void> seedInitialData() async {
    for (final goal in sampleGoals) {
      await _repository.saveGoal(goal);
    }

    for (final milestone in sampleMilestones) {
      await _repository.saveMilestone(milestone);
    }

    for (final task in sampleTasks) {
      await _taskRepository.saveTask(task);
    }
  }
}
