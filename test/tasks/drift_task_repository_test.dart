import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_task_repository.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('DriftTaskRepository', () {
    late local.AppDatabase database;
    late DriftTaskRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftTaskRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists optional scheduled time', () async {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 9 * 60 + 30,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      await repository.saveTask(task);

      final tasks = await repository.loadTasks();

      expect(tasks.single.scheduledDate, DateTime(2026, 5, 20));
      expect(tasks.single.scheduledTimeMinutes, 570);
      expect(tasks.single.reminderMinutesBefore, 15);
    });

    test('clearing scheduled time also clears reminder', () async {
      final task = PlannerTask(
        id: 'task_1',
        title: 'Plan day',
        description: '',
        scheduledDate: DateTime(2026, 5, 20),
        scheduledTimeMinutes: 570,
        reminderMinutesBefore: 15,
        createdAt: DateTime(2026, 5, 20),
      );

      await repository.saveTask(task);
      await repository.updateTask(
        task.scheduleForDateAndTime(
          date: DateTime(2026, 5, 20),
          timeMinutes: null,
        ),
      );

      final tasks = await repository.loadTasks();

      expect(tasks.single.scheduledDate, DateTime(2026, 5, 20));
      expect(tasks.single.scheduledTimeMinutes, isNull);
      expect(tasks.single.reminderMinutesBefore, isNull);
    });
  });
}
