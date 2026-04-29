import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../shared/planner_dates.dart';

const defaultRecurringGenerationHorizonDays = 14;

List<PlannerTask> generateRecurringTaskOccurrences({
  required List<RecurringTaskRule> rules,
  required List<RecurringTaskException> exceptions,
  required List<PlannerTask> existingTasks,
  required DateTime today,
  int horizonDays = defaultRecurringGenerationHorizonDays,
}) {
  final normalizedToday = dateOnly(today);
  final generatedTasks = <PlannerTask>[];

  for (final rule in rules) {
    if (!rule.isActive) {
      continue;
    }

    for (var offset = 0; offset < horizonDays; offset++) {
      final date = normalizedToday.add(Duration(days: offset));

      if (!rule.matchesDate(date)) {
        continue;
      }

      if (_hasExceptionForDate(
        ruleId: rule.id,
        date: date,
        exceptions: exceptions,
      )) {
        continue;
      }

      if (_hasExistingOccurrenceForDate(
        ruleId: rule.id,
        date: date,
        existingTasks: existingTasks,
      )) {
        continue;
      }

      generatedTasks.add(_createOccurrenceTask(rule: rule, date: date));
    }
  }

  return generatedTasks;
}

PlannerTask _createOccurrenceTask({
  required RecurringTaskRule rule,
  required DateTime date,
}) {
  final scheduledDate = dateOnly(date);

  return PlannerTask(
    id: recurringOccurrenceTaskId(ruleId: rule.id, date: scheduledDate),
    title: rule.title,
    description: rule.description,
    goalId: rule.goalId,
    milestoneId: rule.milestoneId,
    recurringRuleId: rule.id,
    scheduledDate: scheduledDate,
    createdAt: scheduledDate,
  );
}

bool _hasExceptionForDate({
  required String ruleId,
  required DateTime date,
  required List<RecurringTaskException> exceptions,
}) {
  return exceptions.any(
    (exception) => exception.matches(ruleId: ruleId, date: date),
  );
}

bool _hasExistingOccurrenceForDate({
  required String ruleId,
  required DateTime date,
  required List<PlannerTask> existingTasks,
}) {
  final normalizedDate = dateOnly(date);

  return existingTasks.any((task) {
    if (task.recurringRuleId != ruleId) {
      return false;
    }

    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return false;
    }

    return dateOnly(scheduledDate) == normalizedDate;
  });
}

String recurringOccurrenceTaskId({
  required String ruleId,
  required DateTime date,
}) {
  final normalizedDate = dateOnly(date);
  final year = normalizedDate.year.toString().padLeft(4, '0');
  final month = normalizedDate.month.toString().padLeft(2, '0');
  final day = normalizedDate.day.toString().padLeft(2, '0');

  return 'task_recurring_${ruleId}_$year$month$day';
}
