import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';

class TaskStoreMutation {
  const TaskStoreMutation({
    required this.tasks,
    required this.recurringExceptions,
    required this.persistOperation,
  });

  final List<PlannerTask> tasks;
  final List<RecurringTaskException> recurringExceptions;
  final Future<void> Function() persistOperation;
}
