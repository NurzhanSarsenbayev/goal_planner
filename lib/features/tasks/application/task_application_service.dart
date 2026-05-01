import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';

class TaskApplicationService {
  const TaskApplicationService();

  PlannerTask createTask({
    required String title,
    required String description,
    String? goalId,
    String? milestoneId,
    DateTime? scheduledDate,
    DateTime? now,
  }) {
    final createdAt = now ?? DateTime.now();

    return PlannerTask(
      id: 'task_${createdAt.microsecondsSinceEpoch}',
      title: title,
      description: description,
      goalId: goalId,
      milestoneId: milestoneId,
      scheduledDate: scheduledDate == null ? null : dateOnly(scheduledDate),
      createdAt: createdAt,
    );
  }

  TaskMutationResult addTask({
    required List<PlannerTask> tasks,
    required PlannerTask task,
  }) {
    return TaskMutationResult(tasks: [...tasks, task], taskToPersist: task);
  }

  TaskMutationResult deleteTask({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    final taskExists = tasks.any((task) => task.id == taskId);

    if (!taskExists) {
      return TaskMutationResult(tasks: tasks);
    }

    return TaskMutationResult(
      tasks: tasks.where((task) => task.id != taskId).toList(),
      taskIdToDelete: taskId,
    );
  }

  TaskMutationResult updateTaskDetails({
    required List<PlannerTask> tasks,
    required String taskId,
    required String title,
    required String description,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.copyWith(title: title, description: description),
    );
  }

  TaskMutationResult attachTaskToGoal({
    required List<PlannerTask> tasks,
    required String taskId,
    required String goalId,
    String? milestoneId,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => milestoneId == null
          ? task.assignToGoal(goalId)
          : task.assignToGoalMilestone(
              goalId: goalId,
              milestoneId: milestoneId,
            ),
    );
  }

  TaskMutationResult detachTaskFromGoal({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.detachFromGoal(),
    );
  }

  TaskMutationResult toggleTaskCompleted({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.toggleCompleted(),
    );
  }

  TaskMutationResult completeTaskOnDate({
    required List<PlannerTask> tasks,
    required String taskId,
    required DateTime completedAt,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.completedOn(completedAt),
    );
  }

  TaskMutationResult scheduleTaskForDate({
    required List<PlannerTask> tasks,
    required String taskId,
    required DateTime scheduledDate,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.scheduleForDate(scheduledDate),
    );
  }

  TaskMutationResult unscheduleTask({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.unschedule(),
    );
  }

  TaskMutationResult moveTaskToDirectGoal({
    required List<PlannerTask> tasks,
    required String taskId,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.moveToDirectGoal(),
    );
  }

  TaskMutationResult assignTaskToMilestone({
    required List<PlannerTask> tasks,
    required String taskId,
    required String milestoneId,
  }) {
    return _updateTaskById(
      tasks: tasks,
      taskId: taskId,
      update: (task) => task.assignToMilestone(milestoneId),
    );
  }

  TaskMutationResult _updateTaskById({
    required List<PlannerTask> tasks,
    required String taskId,
    required PlannerTask Function(PlannerTask task) update,
  }) {
    PlannerTask? updatedTask;

    final updatedTasks = tasks.map((task) {
      if (task.id != taskId) {
        return task;
      }

      updatedTask = update(task);
      return updatedTask!;
    }).toList();

    if (updatedTask == null) {
      return TaskMutationResult(tasks: tasks);
    }

    return TaskMutationResult(tasks: updatedTasks, taskToPersist: updatedTask);
  }
}

class TaskMutationResult {
  const TaskMutationResult({
    required this.tasks,
    this.taskToPersist,
    this.taskIdToDelete,
  });

  final List<PlannerTask> tasks;
  final PlannerTask? taskToPersist;
  final String? taskIdToDelete;

  bool get hasChange => taskToPersist != null || taskIdToDelete != null;
}
