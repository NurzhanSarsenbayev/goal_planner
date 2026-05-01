import '../../../models/goal.dart';

abstract class GoalRepository {
  Future<List<Goal>> loadGoals();

  Future<void> saveGoal(Goal goal);
}
