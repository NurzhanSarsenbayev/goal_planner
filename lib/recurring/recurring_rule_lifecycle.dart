import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../recurring/recurring_task_generator.dart';

class RecurringRuleLifecycleResult {
  const RecurringRuleLifecycleResult({
    required this.rules,
    required this.tasks,
    required this.exceptions,
    this.generatedTasks = const [],
    this.ruleToPersist,
    this.ruleIdToDelete,
  });

  final List<RecurringTaskRule> rules;
  final List<PlannerTask> tasks;
  final List<RecurringTaskException> exceptions;
  final List<PlannerTask> generatedTasks;
  final RecurringTaskRule? ruleToPersist;
  final String? ruleIdToDelete;
}

class RecurringRuleLifecycle {
  RecurringRuleLifecycleResult activateRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime today,
  }) {
    final rule = _findRuleById(rules: rules, ruleId: ruleId);

    if (rule == null || rule.isActive) {
      return RecurringRuleLifecycleResult(
        rules: rules,
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final updatedRule = rule.copyWith(isActive: true);
    final updatedRules = _replaceRule(rules: rules, updatedRule: updatedRule);

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
      ruleToPersist: updatedRule,
    );
  }

  RecurringRuleLifecycleResult deactivateRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
  }) {
    final rule = _findRuleById(rules: rules, ruleId: ruleId);

    if (rule == null || !rule.isActive) {
      return RecurringRuleLifecycleResult(
        rules: rules,
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final updatedRule = rule.copyWith(isActive: false);

    return RecurringRuleLifecycleResult(
      rules: _replaceRule(rules: rules, updatedRule: updatedRule),
      tasks: _removeUnfinishedOccurrencesFromRule(tasks: tasks, ruleId: ruleId),
      exceptions: exceptions,
      ruleToPersist: updatedRule,
    );
  }

  RecurringRuleLifecycleResult deleteRule({
    required String ruleId,
    required List<RecurringTaskRule> rules,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
  }) {
    final rule = _findRuleById(rules: rules, ruleId: ruleId);

    if (rule == null) {
      return RecurringRuleLifecycleResult(
        rules: rules,
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    return RecurringRuleLifecycleResult(
      rules: rules.where((rule) => rule.id != ruleId).toList(),
      tasks: _deleteSeriesTasks(tasks: tasks, ruleId: ruleId),
      exceptions: exceptions
          .where((exception) => exception.ruleId != ruleId)
          .toList(),
      ruleIdToDelete: ruleId,
    );
  }

  RecurringRuleLifecycleResult updateRuleAndRebuildOccurrences({
    required RecurringTaskRule updatedRule,
    required List<RecurringTaskRule> rules,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime today,
  }) {
    final existingRule = _findRuleById(rules: rules, ruleId: updatedRule.id);

    if (existingRule == null) {
      return RecurringRuleLifecycleResult(
        rules: rules,
        tasks: tasks,
        exceptions: exceptions,
      );
    }

    final updatedRules = _replaceRule(rules: rules, updatedRule: updatedRule);

    final tasksWithoutUnfinishedOccurrences =
        _removeUnfinishedOccurrencesFromRule(
          tasks: tasks,
          ruleId: updatedRule.id,
        );

    final generatedTasks = generateUpcomingRecurringTaskOccurrences(
      rules: updatedRules,
      exceptions: exceptions,
      existingTasks: tasksWithoutUnfinishedOccurrences,
      today: today,
    );

    return RecurringRuleLifecycleResult(
      rules: updatedRules,
      tasks: [...tasksWithoutUnfinishedOccurrences, ...generatedTasks],
      exceptions: exceptions,
      generatedTasks: generatedTasks,
      ruleToPersist: updatedRule,
    );
  }

  RecurringTaskRule? _findRuleById({
    required List<RecurringTaskRule> rules,
    required String ruleId,
  }) {
    for (final rule in rules) {
      if (rule.id == ruleId) {
        return rule;
      }
    }

    return null;
  }

  List<RecurringTaskRule> _replaceRule({
    required List<RecurringTaskRule> rules,
    required RecurringTaskRule updatedRule,
  }) {
    return rules.map((rule) {
      if (rule.id != updatedRule.id) {
        return rule;
      }

      return updatedRule;
    }).toList();
  }

  List<PlannerTask> _removeUnfinishedOccurrencesFromRule({
    required List<PlannerTask> tasks,
    required String ruleId,
  }) {
    return tasks.where((task) {
      return !_isUnfinishedOccurrenceFromRule(task: task, ruleId: ruleId);
    }).toList();
  }

  List<PlannerTask> _deleteSeriesTasks({
    required List<PlannerTask> tasks,
    required String ruleId,
  }) {
    return tasks
        .where((task) {
          return !_isUnfinishedOccurrenceFromRule(task: task, ruleId: ruleId);
        })
        .map((task) {
          if (task.recurringRuleId == ruleId && task.isCompleted) {
            return task.copyWith(recurringRuleId: null);
          }

          return task;
        })
        .toList();
  }

  bool _isUnfinishedOccurrenceFromRule({
    required PlannerTask task,
    required String ruleId,
  }) {
    return task.recurringRuleId == ruleId && !task.isCompleted;
  }
}
