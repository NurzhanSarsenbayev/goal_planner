import '../../../models/planner_task.dart';
import '../../../models/recurring_task_rule.dart';
import '../domain/planner_backup.dart';
import 'planner_backup_validation_result.dart';
import '../../reminders/standalone/domain/standalone_reminder.dart';

export 'planner_backup_validation_result.dart';

class PlannerBackupValidator {
  const PlannerBackupValidator();

  PlannerBackupValidationResult validate(PlannerBackup backup) {
    return validateData(backup.data);
  }

  PlannerBackupValidationResult validateData(PlannerBackupData data) {
    final errors = <PlannerBackupValidationError>[];

    _validateUniqueIds(
      collectionName: 'goals',
      ids: data.goals.map((goal) => goal.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'milestones',
      ids: data.milestones.map((milestone) => milestone.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'tasks',
      ids: data.tasks.map((task) => task.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'recurringRules',
      ids: data.recurringRules.map((rule) => rule.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'recurringExceptions',
      ids: data.recurringExceptions.map((exception) => exception.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'habits',
      ids: data.habits.map((habit) => habit.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'habitEntries',
      ids: data.habitEntries.map((entry) => entry.id),
      errors: errors,
    );
    _validateUniqueIds(
      collectionName: 'standaloneReminders',
      ids: data.standaloneReminders.map((reminder) => reminder.id),
      errors: errors,
    );

    final goalIds = data.goals.map((goal) => goal.id).toSet();
    final milestonesById = {
      for (final milestone in data.milestones) milestone.id: milestone,
    };
    final recurringRuleIds = data.recurringRules.map((rule) => rule.id).toSet();
    final habitIds = data.habits.map((habit) => habit.id).toSet();

    for (final milestone in data.milestones) {
      if (!goalIds.contains(milestone.goalId)) {
        errors.add(
          PlannerBackupValidationError(
            code: 'milestone_missing_goal',
            message:
                'Milestone "${milestone.id}" references missing goal '
                '"${milestone.goalId}".',
          ),
        );
      }
    }

    for (final task in data.tasks) {
      _validateTaskReferences(
        task: task,
        goalIds: goalIds,
        milestonesById: milestonesById,
        recurringRuleIds: recurringRuleIds,
        errors: errors,
      );
    }

    for (final rule in data.recurringRules) {
      _validateRecurringRuleReferences(
        rule: rule,
        goalIds: goalIds,
        milestonesById: milestonesById,
        errors: errors,
      );
      _validateRecurringRuleSchedule(rule: rule, errors: errors);
    }

    for (final exception in data.recurringExceptions) {
      if (!recurringRuleIds.contains(exception.ruleId)) {
        errors.add(
          PlannerBackupValidationError(
            code: 'recurring_exception_missing_rule',
            message:
                'Recurring exception "${exception.id}" references missing '
                'rule "${exception.ruleId}".',
          ),
        );
      }
    }

    for (final entry in data.habitEntries) {
      if (!habitIds.contains(entry.habitId)) {
        errors.add(
          PlannerBackupValidationError(
            code: 'habit_entry_missing_habit',
            message:
                'Habit entry "${entry.id}" references missing habit '
                '"${entry.habitId}".',
          ),
        );
      }
    }

    for (final reminder in data.standaloneReminders) {
      _validateStandaloneReminderSchedule(reminder: reminder, errors: errors);
    }

    return PlannerBackupValidationResult(List.unmodifiable(errors));
  }

  void _validateUniqueIds({
    required String collectionName,
    required Iterable<String> ids,
    required List<PlannerBackupValidationError> errors,
  }) {
    final seen = <String>{};

    for (final id in ids) {
      if (id.trim().isEmpty) {
        errors.add(
          PlannerBackupValidationError(
            code: 'empty_id',
            message: '$collectionName contains an empty id.',
          ),
        );
      }

      if (!seen.add(id)) {
        errors.add(
          PlannerBackupValidationError(
            code: 'duplicate_id',
            message: '$collectionName contains duplicate id "$id".',
          ),
        );
      }
    }
  }

  void _validateTaskReferences({
    required PlannerTask task,
    required Set<String> goalIds,
    required Map<String, dynamic> milestonesById,
    required Set<String> recurringRuleIds,
    required List<PlannerBackupValidationError> errors,
  }) {
    final goalId = task.goalId;
    final milestoneId = task.milestoneId;
    final recurringRuleId = task.recurringRuleId;

    if (goalId != null && !goalIds.contains(goalId)) {
      errors.add(
        PlannerBackupValidationError(
          code: 'task_missing_goal',
          message: 'Task "${task.id}" references missing goal "$goalId".',
        ),
      );
    }

    if (milestoneId != null) {
      final milestone = milestonesById[milestoneId];

      if (milestone == null) {
        errors.add(
          PlannerBackupValidationError(
            code: 'task_missing_milestone',
            message:
                'Task "${task.id}" references missing milestone '
                '"$milestoneId".',
          ),
        );
      } else if (goalId == null) {
        errors.add(
          PlannerBackupValidationError(
            code: 'task_milestone_without_goal',
            message:
                'Task "${task.id}" references milestone "$milestoneId" '
                'without goalId.',
          ),
        );
      } else if (milestone.goalId != goalId) {
        errors.add(
          PlannerBackupValidationError(
            code: 'task_milestone_goal_mismatch',
            message:
                'Task "${task.id}" references milestone "$milestoneId" '
                'that belongs to goal "${milestone.goalId}", not "$goalId".',
          ),
        );
      }
    }

    if (recurringRuleId != null &&
        !recurringRuleIds.contains(recurringRuleId)) {
      errors.add(
        PlannerBackupValidationError(
          code: 'task_missing_recurring_rule',
          message:
              'Task "${task.id}" references missing recurring rule '
              '"$recurringRuleId".',
        ),
      );
    }
  }

  void _validateRecurringRuleReferences({
    required RecurringTaskRule rule,
    required Set<String> goalIds,
    required Map<String, dynamic> milestonesById,
    required List<PlannerBackupValidationError> errors,
  }) {
    final goalId = rule.goalId;
    final milestoneId = rule.milestoneId;

    if (goalId != null && !goalIds.contains(goalId)) {
      errors.add(
        PlannerBackupValidationError(
          code: 'recurring_rule_missing_goal',
          message:
              'Recurring rule "${rule.id}" references missing goal "$goalId".',
        ),
      );
    }

    if (milestoneId != null) {
      final milestone = milestonesById[milestoneId];

      if (milestone == null) {
        errors.add(
          PlannerBackupValidationError(
            code: 'recurring_rule_missing_milestone',
            message:
                'Recurring rule "${rule.id}" references missing milestone '
                '"$milestoneId".',
          ),
        );
      } else if (goalId == null) {
        errors.add(
          PlannerBackupValidationError(
            code: 'recurring_rule_milestone_without_goal',
            message:
                'Recurring rule "${rule.id}" references milestone '
                '"$milestoneId" without goalId.',
          ),
        );
      } else if (milestone.goalId != goalId) {
        errors.add(
          PlannerBackupValidationError(
            code: 'recurring_rule_milestone_goal_mismatch',
            message:
                'Recurring rule "${rule.id}" references milestone '
                '"$milestoneId" that belongs to goal "${milestone.goalId}", '
                'not "$goalId".',
          ),
        );
      }
    }
  }

  void _validateRecurringRuleSchedule({
    required RecurringTaskRule rule,
    required List<PlannerBackupValidationError> errors,
  }) {
    switch (rule.recurrenceType) {
      case RecurrenceType.weekly:
        if (rule.weekdays.isEmpty) {
          errors.add(
            PlannerBackupValidationError(
              code: 'weekly_recurring_rule_without_weekdays',
              message: 'Weekly recurring rule "${rule.id}" must have weekdays.',
            ),
          );
        }

        final seenWeekdays = <int>{};

        for (final weekday in rule.weekdays) {
          if (weekday < DateTime.monday || weekday > DateTime.sunday) {
            errors.add(
              PlannerBackupValidationError(
                code: 'invalid_recurring_rule_weekday',
                message:
                    'Recurring rule "${rule.id}" has invalid weekday '
                    '"$weekday".',
              ),
            );
          }

          if (!seenWeekdays.add(weekday)) {
            errors.add(
              PlannerBackupValidationError(
                code: 'duplicate_recurring_rule_weekday',
                message:
                    'Recurring rule "${rule.id}" has duplicate weekday '
                    '"$weekday".',
              ),
            );
          }
        }

      case RecurrenceType.monthly:
        final monthDay = rule.monthDay;

        if (monthDay == null) {
          errors.add(
            PlannerBackupValidationError(
              code: 'monthly_recurring_rule_without_month_day',
              message:
                  'Monthly recurring rule "${rule.id}" must have monthDay.',
            ),
          );

          return;
        }

        if (monthDay < 1 || monthDay > 31) {
          errors.add(
            PlannerBackupValidationError(
              code: 'invalid_recurring_rule_month_day',
              message:
                  'Recurring rule "${rule.id}" has invalid monthDay '
                  '"$monthDay".',
            ),
          );
        }
    }
  }

  void _validateStandaloneReminderSchedule({
    required StandaloneReminder reminder,
    required List<PlannerBackupValidationError> errors,
  }) {
    if (reminder.timeMinutes < 0 || reminder.timeMinutes > 1439) {
      errors.add(
        PlannerBackupValidationError(
          code: 'invalid_standalone_reminder_time',
          message:
              'Standalone reminder "${reminder.id}" has invalid timeMinutes '
              '"${reminder.timeMinutes}".',
        ),
      );
    }

    switch (reminder.scheduleType) {
      case StandaloneReminderScheduleType.once:
        if (reminder.scheduledDate == null) {
          errors.add(
            PlannerBackupValidationError(
              code: 'one_time_standalone_reminder_without_date',
              message:
                  'One-time standalone reminder "${reminder.id}" must have '
                  'scheduledDate.',
            ),
          );
        }

      case StandaloneReminderScheduleType.daily:
        if (reminder.scheduledDate != null) {
          errors.add(
            PlannerBackupValidationError(
              code: 'daily_standalone_reminder_with_date',
              message:
                  'Daily standalone reminder "${reminder.id}" must not have '
                  'scheduledDate.',
            ),
          );
        }
    }
  }
}
