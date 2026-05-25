import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../domain/recurring_occurrence_lifecycle.dart';
import '../domain/recurring_rule_lifecycle.dart';
import '../domain/recurring_task_generator.dart';

class RecurringTaskApplicationService {
  RecurringTaskApplicationService({
    RecurringRuleLifecycle? ruleLifecycle,
    RecurringOccurrenceLifecycle? occurrenceLifecycle,
  }) : _ruleLifecycle = ruleLifecycle ?? RecurringRuleLifecycle(),
       _occurrenceLifecycle =
           occurrenceLifecycle ?? RecurringOccurrenceLifecycle();

  final RecurringRuleLifecycle _ruleLifecycle;
  final RecurringOccurrenceLifecycle _occurrenceLifecycle;

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

  RecurringOccurrenceLifecycleResult deleteOccurrence({
    required PlannerTask task,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    return _occurrenceLifecycle.deleteOccurrence(
      task: task,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );
  }

  RecurringOccurrenceLifecycleResult rescheduleOccurrence({
    required PlannerTask task,
    required DateTime scheduledDate,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    return _occurrenceLifecycle.rescheduleOccurrence(
      task: task,
      scheduledDate: scheduledDate,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );
  }

  RecurringOccurrenceLifecycleResult scheduleOccurrenceForDateAndTime({
    required PlannerTask task,
    required DateTime scheduledDate,
    required int? scheduledTimeMinutes,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    return _occurrenceLifecycle.scheduleOccurrenceForDateAndTime(
      task: task,
      scheduledDate: scheduledDate,
      scheduledTimeMinutes: scheduledTimeMinutes,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );
  }

  RecurringOccurrenceLifecycleResult updateOccurrenceReminder({
    required PlannerTask task,
    required int? reminderMinutesBefore,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    return _occurrenceLifecycle.updateOccurrenceReminder(
      task: task,
      reminderMinutesBefore: reminderMinutesBefore,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
    );
  }

  RecurringOccurrenceLifecycleResult unscheduleOccurrence({
    required PlannerTask task,
    required List<PlannerTask> tasks,
    required List<RecurringTaskException> exceptions,
    required DateTime now,
  }) {
    return _occurrenceLifecycle.unscheduleOccurrence(
      task: task,
      tasks: tasks,
      exceptions: exceptions,
      now: now,
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
