import '../models/planner_task.dart';
import '../models/recurring_task_exception.dart';
import '../models/recurring_task_rule.dart';
import '../shared/planner_dates.dart';

const defaultUpcomingRecurringGenerationDays = 14;

List<PlannerTask> generateRecurringTaskOccurrences({
  required List<RecurringTaskRule> rules,
  required List<RecurringTaskException> exceptions,
  required List<PlannerTask> existingTasks,
  required DateTime startDate,
  required DateTime endDate,
}) {
  final normalizedStartDate = dateOnly(startDate);
  final normalizedEndDate = dateOnly(endDate);

  if (normalizedEndDate.isBefore(normalizedStartDate)) {
    return const [];
  }

  final generatedTasks = <PlannerTask>[];

  for (final rule in rules) {
    if (!rule.isActive) {
      continue;
    }

    var date = normalizedStartDate;

    while (!date.isAfter(normalizedEndDate)) {
      if (rule.matchesDate(date) &&
          !_hasExceptionForDate(
            ruleId: rule.id,
            date: date,
            exceptions: exceptions,
          ) &&
          !_hasExistingOccurrenceForDate(
            ruleId: rule.id,
            date: date,
            existingTasks: [...existingTasks, ...generatedTasks],
          )) {
        generatedTasks.add(_createOccurrenceTask(rule: rule, date: date));
      }

      date = date.add(const Duration(days: 1));
    }
  }

  return generatedTasks;
}

List<PlannerTask> generateUpcomingRecurringTaskOccurrences({
  required List<RecurringTaskRule> rules,
  required List<RecurringTaskException> exceptions,
  required List<PlannerTask> existingTasks,
  required DateTime today,
  int days = defaultUpcomingRecurringGenerationDays,
}) {
  final normalizedToday = dateOnly(today);

  return generateRecurringTaskOccurrences(
    rules: rules,
    exceptions: exceptions,
    existingTasks: existingTasks,
    startDate: normalizedToday,
    endDate: normalizedToday.add(Duration(days: days - 1)),
  );
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
