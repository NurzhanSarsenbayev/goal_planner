import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_recurring_task_repository.dart';
import 'package:goal_planner/data/repositories/drift_task_repository.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('DriftRecurringTaskRepository', () {
    late local.AppDatabase database;
    late DriftRecurringTaskRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftRecurringTaskRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test(
      'persists recurring rule reminder settings and generated occurrence reminder fields',
      () async {
        final now = DateTime(2026, 5, 25);
        final scheduledDate = DateTime(2026, 5, 26);

        final rule = RecurringTaskRule(
          id: 'rule-1',
          title: 'Workout',
          description: '',
          recurrenceType: RecurrenceType.weekly,
          weekdays: const [DateTime.tuesday],
          monthDay: null,
          startDate: now,
          scheduledTimeMinutes: 9 * 60 + 30,
          reminderMinutesBefore: 15,
          createdAt: now,
        );

        final occurrence = PlannerTask(
          id: 'task-recurring-1',
          title: 'Workout',
          description: '',
          recurringRuleId: rule.id,
          scheduledDate: scheduledDate,
          scheduledTimeMinutes: 9 * 60 + 30,
          reminderMinutesBefore: 15,
          createdAt: now,
        );

        await repository.saveRecurringTaskRuleWithOccurrences(
          rule: rule,
          generatedTasks: [occurrence],
        );

        final loadedRules = await repository.loadRecurringTaskRules();
        final loadedTasks = await DriftTaskRepository(database).loadTasks();

        expect(loadedRules.single.scheduledTimeMinutes, 570);
        expect(loadedRules.single.reminderMinutesBefore, 15);
        expect(loadedTasks.single.scheduledTimeMinutes, 570);
        expect(loadedTasks.single.reminderMinutesBefore, 15);
      },
    );
  });
}
