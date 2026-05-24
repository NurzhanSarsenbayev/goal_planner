import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/reminders/habit/application/habit_reminder_resync_service.dart';
import 'package:goal_planner/features/reminders/habit/application/habit_reminder_scheduler.dart';

void main() {
  group('HabitReminderResyncService', () {
    test('loads habits from repository', () async {
      final habits = [_habit(id: 'habit-1')];
      final service = HabitReminderResyncService(
        repository: _FakeHabitRepository(habits: habits),
        scheduler: _FakeHabitReminderScheduler(),
      );

      final loadedHabits = await service.loadHabits();

      expect(loadedHabits, habits);
    });

    test('syncs all current habits', () async {
      final scheduler = _FakeHabitReminderScheduler();
      final service = HabitReminderResyncService(
        repository: _FakeHabitRepository(
          habits: [
            _habit(id: 'habit-1'),
            _habit(id: 'habit-2'),
          ],
        ),
        scheduler: scheduler,
      );

      await service.syncHabitReminders();

      expect(scheduler.syncedHabitIds, ['habit-1', 'habit-2']);
      expect(scheduler.canceledHabitIds, isEmpty);
    });

    test(
      'cancels removed habits and syncs current habits after replacement',
      () async {
        final scheduler = _FakeHabitReminderScheduler();
        final service = HabitReminderResyncService(
          repository: const _FakeHabitRepository(),
          scheduler: scheduler,
        );

        await service.syncAfterHabitSetReplacement(
          previousHabits: [
            _habit(id: 'old'),
            _habit(id: 'kept'),
          ],
          currentHabits: [
            _habit(id: 'kept'),
            _habit(id: 'new'),
          ],
        );

        expect(scheduler.canceledHabitIds, ['old']);
        expect(scheduler.syncedHabitIds, ['kept', 'new']);
      },
    );
  });
}

Habit _habit({required String id}) {
  final now = DateTime(2026, 5, 24, 10);

  return Habit(
    id: id,
    title: 'Habit $id',
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: false,
    isReminderEnabled: true,
    reminderTimeMinutes: 20 * 60,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeHabitRepository implements HabitRepository {
  const _FakeHabitRepository({this.habits = const []});

  final List<Habit> habits;

  @override
  Future<List<Habit>> loadHabits() async {
    return habits;
  }

  @override
  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return const [];
  }

  @override
  Future<List<HabitEntry>> loadAllEntries() async {
    return const [];
  }

  @override
  Future<void> saveHabit(Habit habit) async {}

  @override
  Future<void> saveEntry(HabitEntry entry) async {}

  @override
  Future<void> deleteEntry(String entryId) async {}

  @override
  Future<void> deleteHabit(String habitId) async {}
}

class _FakeHabitReminderScheduler implements HabitReminderScheduler {
  final syncedHabitIds = <String>[];
  final canceledHabitIds = <String>[];

  @override
  Future<void> syncHabitReminder(Habit habit) async {
    syncedHabitIds.add(habit.id);
  }

  @override
  Future<void> cancelHabitReminder(String habitId) async {
    canceledHabitIds.add(habitId);
  }
}
