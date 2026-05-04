import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import 'recurring_task_application_service.dart';
import 'recurring_task_repository.dart';

class RecurringRuleStoreMutation {
  const RecurringRuleStoreMutation({
    required this.rules,
    required this.tasks,
    required this.exceptions,
    required this.persistOperation,
  });

  final List<RecurringTaskRule> rules;
  final List<PlannerTask> tasks;
  final List<RecurringTaskException> exceptions;
  final Future<void> Function() persistOperation;
}

class RecurringRuleStoreCoordinator {
  RecurringRuleStoreCoordinator({
    required RecurringTaskRepository recurringTaskRepository,
    RecurringTaskApplicationService? recurringTaskApplicationService,
  }) : _recurringTaskRepository = recurringTaskRepository,
       _recurringTaskApplicationService =
           recurringTaskApplicationService ?? RecurringTaskApplicationService();

  final RecurringTaskRepository _recurringTaskRepository;
  final RecurringTaskApplicationService _recurringTaskApplicationService;

  RecurringRuleStoreMutation? addRule({
    required RecurringTaskRule rule,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
    required DateTime today,
  }) {
    final result = _recurringTaskApplicationService.addRule(
      rule: rule,
      rules: rules,
      exceptions: exceptions,
      tasks: tasks,
      today: today,
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return null;
    }

    return RecurringRuleStoreMutation(
      rules: result.rules,
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () =>
          _recurringTaskRepository.saveRecurringTaskRuleWithOccurrences(
            rule: ruleToPersist,
            generatedTasks: result.generatedTasks,
          ),
    );
  }

  RecurringRuleStoreMutation? updateRule({
    required RecurringTaskRule updatedRule,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
    required DateTime today,
  }) {
    final result = _recurringTaskApplicationService.updateRule(
      updatedRule: updatedRule,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
      today: today,
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return null;
    }

    return RecurringRuleStoreMutation(
      rules: result.rules,
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () => _recurringTaskRepository
          .updateRecurringTaskRuleAndReplaceUnfinishedOccurrences(
            rule: ruleToPersist,
            generatedTasks: result.generatedTasks,
          ),
    );
  }

  RecurringRuleStoreMutation? deleteRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
  }) {
    final result = _recurringTaskApplicationService.deleteRule(
      ruleId: ruleId,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
    );

    final ruleIdToDelete = result.ruleIdToDelete;

    if (ruleIdToDelete == null) {
      return null;
    }

    return RecurringRuleStoreMutation(
      rules: result.rules,
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () => _recurringTaskRepository
          .deleteRecurringTaskRuleAndCleanSeries(ruleIdToDelete),
    );
  }

  RecurringRuleStoreMutation? activateRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
    required DateTime today,
  }) {
    final result = _recurringTaskApplicationService.activateRule(
      ruleId: ruleId,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
      today: today,
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return null;
    }

    return RecurringRuleStoreMutation(
      rules: result.rules,
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () =>
          _recurringTaskRepository.saveRecurringTaskRuleWithOccurrences(
            rule: ruleToPersist,
            generatedTasks: result.generatedTasks,
          ),
    );
  }

  RecurringRuleStoreMutation? deactivateRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
  }) {
    final result = _recurringTaskApplicationService.deactivateRule(
      ruleId: ruleId,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
    );

    final ruleToPersist = result.ruleToPersist;

    if (ruleToPersist == null) {
      return null;
    }

    return RecurringRuleStoreMutation(
      rules: result.rules,
      tasks: result.tasks,
      exceptions: result.exceptions,
      persistOperation: () => _recurringTaskRepository
          .deactivateRecurringTaskRuleAndDeleteUnfinishedOccurrences(
            ruleToPersist,
          ),
    );
  }
}
