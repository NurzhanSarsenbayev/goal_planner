import '../../models/goal.dart' as domain;
import '../../models/milestone.dart' as domain;
import '../../models/planner_task.dart' as domain;
import '../../models/recurring_task_exception.dart' as domain;
import '../../models/recurring_task_rule.dart' as domain;
import '../local/app_database.dart' as local;

domain.Goal mapGoal(local.Goal row) {
  return domain.Goal(
    id: row.id,
    title: row.title,
    description: row.description,
    status: mapGoalStatus(row.status),
    createdAt: row.createdAt,
  );
}

domain.Milestone mapMilestone(local.Milestone row) {
  return domain.Milestone(
    id: row.id,
    goalId: row.goalId,
    title: row.title,
    description: row.description,
    createdAt: row.createdAt,
  );
}

domain.PlannerTask mapTask(local.Task row) {
  return domain.PlannerTask(
    id: row.id,
    goalId: row.goalId,
    milestoneId: row.milestoneId,
    recurringRuleId: row.recurringRuleId,
    title: row.title,
    description: row.description,
    scheduledDate: row.scheduledDate,
    isCompleted: row.isCompleted,
    completedAt: row.completedAt,
    createdAt: row.createdAt,
  );
}

domain.RecurringTaskRule mapRecurringTaskRule(local.RecurringTaskRule row) {
  return domain.RecurringTaskRule(
    id: row.id,
    goalId: row.goalId,
    milestoneId: row.milestoneId,
    title: row.title,
    description: row.description,
    recurrenceType: mapRecurrenceType(row.recurrenceType),
    weekdays: parseWeekdays(row.weekdays),
    monthDay: row.monthDay,
    startDate: row.startDate,
    endDate: row.endDate,
    isActive: row.isActive,
    createdAt: row.createdAt,
  );
}

domain.RecurringTaskException mapRecurringTaskException(
  local.RecurringTaskException row,
) {
  return domain.RecurringTaskException(
    id: row.id,
    ruleId: row.ruleId,
    date: row.date,
    createdAt: row.createdAt,
  );
}

domain.GoalStatus mapGoalStatus(String value) {
  for (final status in domain.GoalStatus.values) {
    if (status.name == value) {
      return status;
    }
  }

  return domain.GoalStatus.active;
}

domain.RecurrenceType mapRecurrenceType(String value) {
  for (final type in domain.RecurrenceType.values) {
    if (type.name == value) {
      return type;
    }
  }

  return domain.RecurrenceType.weekly;
}

String recurrenceTypeToDatabaseValue(domain.RecurrenceType type) {
  return type.name;
}

List<int> parseWeekdays(String? value) {
  if (value == null || value.trim().isEmpty) {
    return const [];
  }

  return value
      .split(',')
      .where((item) => item.trim().isNotEmpty)
      .map((item) => int.parse(item.trim()))
      .toList();
}

String? weekdaysToDatabaseValue(List<int> weekdays) {
  if (weekdays.isEmpty) {
    return null;
  }

  return weekdays.join(',');
}
