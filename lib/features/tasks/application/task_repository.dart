import '../../../models/planner_task.dart';

abstract class TaskRepository {
  Future<List<PlannerTask>> loadTasks();

  Future<void> saveTask(PlannerTask task);

  Future<void> updateTask(PlannerTask task);

  Future<void> deleteTask(String taskId);
}
