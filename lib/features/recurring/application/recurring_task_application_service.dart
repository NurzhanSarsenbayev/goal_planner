import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../../recurring/recurring_rule_lifecycle.dart';
import '../../../recurring/recurring_task_generator.dart';

class RecurringTaskApplicationService {
  RecurringTaskApplicationService({RecurringRuleLifecycle? ruleLifecycle})
    : _ruleLifecycle = ruleLifecycle ?? RecurringRuleLifecycle();

  final RecurringRuleLifecycle _ruleLifecycle;

  RecurringRuleLifecycleResult addRule({
    required RecurringTaskRule rule,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
    required DateTime today,
  }) {
    final updatedRules = [...rules, rule];

    final generatedTasks = generateUpcomingRecurringTaskOccurrences(
      rules: updatedRules,
      exceptions: exceptions,
      existingTasks: tasks,
      today: today,
    );

    return RecurringRuleLifecycleResult(
      rules: updatedRules,
      tasks: [...tasks, ...generatedTasks],
      exceptions: exceptions,
      generatedTasks: generatedTasks,
      ruleToPersist: rule,
    );
  }

  RecurringRuleLifecycleResult activateRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
    required DateTime today,
  }) {
    return _ruleLifecycle.activateRule(
      ruleId: ruleId,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
      today: today,
    );
  }

  RecurringRuleLifecycleResult deactivateRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
  }) {
    return _ruleLifecycle.deactivateRule(
      ruleId: ruleId,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
    );
  }

  RecurringRuleLifecycleResult deleteRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
  }) {
    return _ruleLifecycle.deleteRule(
      ruleId: ruleId,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
    );
  }

  RecurringRuleLifecycleResult updateRule({
    required RecurringTaskRule updatedRule,
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> tasks,
    required DateTime today,
  }) {
    return _ruleLifecycle.updateRuleAndRebuildOccurrences(
      updatedRule: updatedRule,
      rules: rules,
      tasks: tasks,
      exceptions: exceptions,
      today: today,
    );
  }

  List<PlannerTask> generateUpcomingOccurrences({
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> existingTasks,
    required DateTime today,
  }) {
    return generateUpcomingRecurringTaskOccurrences(
      rules: rules,
      exceptions: exceptions,
      existingTasks: existingTasks,
      today: today,
    );
  }

  List<PlannerTask> generateOccurrencesForRange({
    required List<RecurringTaskRule> rules,
    required List<RecurringTaskException> exceptions,
    required List<PlannerTask> existingTasks,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return generateRecurringTaskOccurrences(
      rules: rules,
      exceptions: exceptions,
      existingTasks: existingTasks,
      startDate: startDate,
      endDate: endDate,
    );
  }
}
