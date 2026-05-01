import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';

abstract class RecurringTaskRepository {
  Future<List<RecurringTaskRule>> loadRecurringTaskRules();

  Future<List<RecurringTaskException>> loadRecurringTaskExceptions();

  Future<void> saveGeneratedOccurrences(List<PlannerTask> generatedTasks);

  Future<void> saveRecurringTaskRuleWithOccurrences({
    required RecurringTaskRule rule,
    required List<PlannerTask> generatedTasks,
  });

  Future<void> deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
    RecurringTaskRule rule,
  );

  Future<void> deleteRecurringTaskRuleAndCleanSeries(String ruleId);

  Future<void> updateRecurringTaskRuleAndReplaceUnfinishedOccurrences({
    required RecurringTaskRule rule,
    required List<PlannerTask> generatedTasks,
  });

  Future<void> deleteTaskWithRecurringException({
    required String taskId,
    required RecurringTaskException exception,
  });

  Future<void> updateTaskWithRecurringException({
    required PlannerTask task,
    required RecurringTaskException exception,
  });
}
