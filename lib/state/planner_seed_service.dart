import '../data/repositories/planner_repository.dart';
import '../data/sample_data.dart';

class PlannerSeedService {
  const PlannerSeedService(this._repository);

  final PlannerRepository _repository;

  Future<void> seedInitialData() async {
    for (final goal in sampleGoals) {
      await _repository.saveGoal(goal);
    }

    for (final milestone in sampleMilestones) {
      await _repository.saveMilestone(milestone);
    }

    for (final task in sampleTasks) {
      await _repository.saveTask(task);
    }
  }
}
