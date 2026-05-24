import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/habits/domain/habit_entry_status.dart';
import 'package:goal_planner/features/habits/domain/habit_tracking_type.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/habit/application/habit_reminder_pending_checker.dart';
import 'package:goal_planner/features/reminders/habit/application/habit_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_texts.dart';

void main() {
  group('HabitReminderScheduler', () {
    test('schedules pending habit reminder later today', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 24, 8),
      );

      await scheduler.syncHabitReminder(
        _habit(timeMinutes: 9 * 60, isReminderEnabled: true),
      );

      expect(notifications.canceledIds, [
        habitReminderNotificationId('habit-1'),
      ]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.id,
        [habitReminderNotificationId('habit-1')].single,
      );
      expect(notifications.scheduledReminders.single.title, 'Drink water');
      expect(notifications.scheduledReminders.single.body, 'Habit reminder');
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 24, 9),
      );
      expect(notifications.scheduledReminders.single.payload, 'habit-1');
      expect(
        notifications.scheduledReminders.single.repeat,
        ReminderRepeat.none,
      );
    });

    test('cancels disabled habit reminder without scheduling it', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(notifications: notifications);

      await scheduler.syncHabitReminder(
        _habit(isReminderEnabled: false, timeMinutes: null),
      );

      expect(notifications.canceledIds, [
        habitReminderNotificationId('habit-1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('does not schedule when habit is not pending today', () async {
      final notifications = _FakeReminderNotificationClient();
      final habit = _habit();
      final scheduler = _scheduler(
        notifications: notifications,
        entries: [
          _entry(
            habitId: habit.id,
            date: DateTime(2026, 5, 24),
            status: HabitEntryStatus.done,
          ),
        ],
      );

      await scheduler.syncHabitReminder(habit);

      expect(notifications.canceledIds, [
        habitReminderNotificationId('habit-1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('does not schedule when reminder time already passed today', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 24, 10),
      );

      await scheduler.syncHabitReminder(
        _habit(timeMinutes: 9 * 60, isReminderEnabled: true),
      );

      expect(notifications.canceledIds, [
        habitReminderNotificationId('habit-1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('does not schedule when reminder time is now', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 24, 9),
      );

      await scheduler.syncHabitReminder(
        _habit(timeMinutes: 9 * 60, isReminderEnabled: true),
      );

      expect(notifications.canceledIds, [
        habitReminderNotificationId('habit-1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('cancels habit reminder by id', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(notifications: notifications);

      await scheduler.cancelHabitReminder('habit-1');

      expect(notifications.canceledIds, [
        habitReminderNotificationId('habit-1'),
      ]);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('uses localized notification body', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(
        notifications: notifications,
        now: () => DateTime(2026, 5, 24, 8),
        notificationTexts: ReminderNotificationTexts(
          habitReminderBody: 'Напоминание о привычке',
        ),
      );

      await scheduler.syncHabitReminder(
        _habit(timeMinutes: 9 * 60, isReminderEnabled: true),
      );

      expect(
        notifications.scheduledReminders.single.body,
        'Напоминание о привычке',
      );
    });
  });
}

HabitReminderScheduler _scheduler({
  _FakeReminderNotificationClient? notifications,
  List<HabitEntry> entries = const [],
  DateTime Function()? now,
  ReminderNotificationTexts? notificationTexts,
}) {
  final todayProvider = now ?? () => DateTime(2026, 5, 24, 8);

  return HabitReminderScheduler(
    pendingChecker: HabitReminderPendingChecker(
      habitRepository: _FakeHabitRepository(entries: entries),
      todayProvider: todayProvider,
    ),
    notifications: notifications ?? _FakeReminderNotificationClient(),
    now: todayProvider,
    notificationTexts: notificationTexts,
  );
}

Habit _habit({
  String id = 'habit-1',
  bool isReminderEnabled = true,
  int? timeMinutes = 20 * 60,
}) {
  final now = DateTime(2026, 5, 24, 8);

  return Habit(
    id: id,
    title: 'Drink water',
    description: '',
    trackingType: HabitTrackingType.binary,
    targetCount: null,
    sortOrder: 0,
    isArchived: false,
    isReminderEnabled: isReminderEnabled,
    reminderTimeMinutes: timeMinutes,
    createdAt: now,
    updatedAt: now,
  );
}

HabitEntry _entry({
  required String habitId,
  required DateTime date,
  required HabitEntryStatus status,
}) {
  final now = DateTime(2026, 5, 24, 8);

  return HabitEntry(
    id: 'entry-$habitId-${date.toIso8601String()}',
    habitId: habitId,
    date: date,
    status: status,
    completedCount: status == HabitEntryStatus.done ? 1 : 0,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeHabitRepository implements HabitRepository {
  const _FakeHabitRepository({this.entries = const []});

  final List<HabitEntry> entries;

  @override
  Future<List<Habit>> loadHabits() async {
    return const [];
  }

  @override
  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    return entries
        .where((entry) => !entry.date.isBefore(startDate))
        .where((entry) => !entry.date.isAfter(endDate))
        .toList(growable: false);
  }

  @override
  Future<List<HabitEntry>> loadAllEntries() async {
    return entries;
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

class _FakeReminderNotificationClient implements ReminderNotificationClient {
  final scheduledReminders = <_ScheduledReminder>[];
  final canceledIds = <int>[];

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    ReminderRepeat repeat = ReminderRepeat.none,
  }) async {
    scheduledReminders.add(
      _ScheduledReminder(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
        repeat: repeat,
      ),
    );
  }

  @override
  Future<void> cancelReminder(int id) async {
    canceledIds.add(id);
  }
}

class _ScheduledReminder {
  const _ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
    required this.repeat,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? payload;
  final ReminderRepeat repeat;
}
