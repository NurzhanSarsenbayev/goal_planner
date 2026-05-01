import '../../../models/milestone.dart';

abstract class MilestoneRepository {
  Future<List<Milestone>> loadMilestones();

  Future<void> saveMilestone(Milestone milestone);
}
