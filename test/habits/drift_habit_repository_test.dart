import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';

void main() {
  group('DriftHabitRepository', () {
    late local.AppDatabase database;
    late DriftHabitRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftHabitRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists and loads habit reminder fields', () async {
      final habit = _habit(
        isReminderEnabled: true,
        reminderTimeMinutes: 20 * 60 + 45,
      );

      await repository.saveHabit(habit);

      final habits = await repository.loadHabits();

      expect(habits, hasLength(1));
      expect(habits.single.id, 'habit-1');
      expect(habits.single.isReminderEnabled, isTrue);
      expect(habits.single.reminderTimeMinutes, 1245);
    });
  });
}

Habit _habit({bool isReminderEnabled = false, int? reminderTimeMinutes}) {
  final now = DateTime(2026, 5, 23, 10);

  return Habit(
    id: 'habit-1',
    title: 'Drink water',
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: false,
    isReminderEnabled: isReminderEnabled,
    reminderTimeMinutes: reminderTimeMinutes,
    createdAt: now,
    updatedAt: now,
  );
}
