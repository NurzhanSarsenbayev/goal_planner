import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/habits/application/habit_repository.dart';
import 'package:goal_planner/features/habits/domain/habit.dart';
import 'package:goal_planner/features/habits/domain/habit_entry.dart';
import 'package:goal_planner/features/reminders/daily_review/application/daily_review_pending_checker.dart';
import 'package:goal_planner/features/reminders/daily_review/application/daily_review_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/daily_review/application/daily_review_reminder_settings_repository.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/daily_review/domain/daily_review_reminder_settings.dart';
import 'package:goal_planner/features/tasks/application/task_repository.dart';
import 'package:goal_planner/models/planner_task.dart';

void main() {
  group('DailyReviewReminderScheduler', () {
    test('cancels reminder when settings are disabled', () async {
      final notifications = _FakeReminderNotificationClient();
      final pendingChecker = _FakeDailyReviewPendingChecker(
        summary: const DailyReviewPendingSummary(
          unfinishedTodayTaskCount: 1,
          overdueTaskCount: 0,
          pendingHabitCount: 0,
        ),
      );
      final scheduler = _scheduler(
        notifications: notifications,
        pendingChecker: pendingChecker,
        settings: DailyReviewReminderSettings(
          isEnabled: false,
          timeMinutes: 21 * 60,
        ),
      );

      await scheduler.syncDailyReviewReminder();

      expect(notifications.canceledIds, [dailyReviewReminderNotificationId]);
      expect(notifications.scheduledReminders, isEmpty);
      expect(pendingChecker.loadCount, 0);
    });

    test('cancels reminder when there are no pending items', () async {
      final notifications = _FakeReminderNotificationClient();
      final pendingChecker = _FakeDailyReviewPendingChecker(
        summary: const DailyReviewPendingSummary(
          unfinishedTodayTaskCount: 0,
          overdueTaskCount: 0,
          pendingHabitCount: 0,
        ),
      );
      final scheduler = _scheduler(
        notifications: notifications,
        pendingChecker: pendingChecker,
        now: () => DateTime(2026, 5, 21, 18),
      );

      await scheduler.syncDailyReviewReminder();

      expect(notifications.canceledIds, [dailyReviewReminderNotificationId]);
      expect(notifications.scheduledReminders, isEmpty);
      expect(pendingChecker.loadCount, 1);
    });

    test('schedules reminder today when review time is still ahead', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(
        notifications: notifications,
        pendingChecker: _FakeDailyReviewPendingChecker(
          summary: const DailyReviewPendingSummary(
            unfinishedTodayTaskCount: 1,
            overdueTaskCount: 1,
            pendingHabitCount: 1,
          ),
        ),
        now: () => DateTime(2026, 5, 21, 18),
      );

      await scheduler.syncDailyReviewReminder();

      expect(notifications.canceledIds, [dailyReviewReminderNotificationId]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(notifications.scheduledReminders.single.id, 73001);
      expect(notifications.scheduledReminders.single.title, 'Review your day');
      expect(
        notifications.scheduledReminders.single.body,
        'You still have 3 item(s) to review.',
      );
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 21, 21),
      );
      expect(
        notifications.scheduledReminders.single.payload,
        dailyReviewReminderPayload,
      );
      expect(
        notifications.scheduledReminders.single.repeat,
        ReminderRepeat.none,
      );
    });

    test(
      'schedules reminder tomorrow when review time already passed',
      () async {
        final notifications = _FakeReminderNotificationClient();
        final scheduler = _scheduler(
          notifications: notifications,
          pendingChecker: _FakeDailyReviewPendingChecker(
            summary: const DailyReviewPendingSummary(
              unfinishedTodayTaskCount: 1,
              overdueTaskCount: 0,
              pendingHabitCount: 0,
            ),
          ),
          now: () => DateTime(2026, 5, 21, 22),
        );

        await scheduler.syncDailyReviewReminder();

        expect(notifications.scheduledReminders, hasLength(1));
        expect(
          notifications.scheduledReminders.single.scheduledAt,
          DateTime(2026, 5, 22, 21),
        );
      },
    );

    test('schedules reminder tomorrow when review time is now', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(
        notifications: notifications,
        pendingChecker: _FakeDailyReviewPendingChecker(
          summary: const DailyReviewPendingSummary(
            unfinishedTodayTaskCount: 1,
            overdueTaskCount: 0,
            pendingHabitCount: 0,
          ),
        ),
        now: () => DateTime(2026, 5, 21, 21),
      );

      await scheduler.syncDailyReviewReminder();

      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 22, 21),
      );
    });

    test('cancels daily review reminder by id', () async {
      final notifications = _FakeReminderNotificationClient();
      final scheduler = _scheduler(notifications: notifications);

      await scheduler.cancelDailyReviewReminder();

      expect(notifications.canceledIds, [dailyReviewReminderNotificationId]);
      expect(notifications.scheduledReminders, isEmpty);
    });
  });
}

DailyReviewReminderScheduler _scheduler({
  _FakeReminderNotificationClient? notifications,
  _FakeDailyReviewPendingChecker? pendingChecker,
  DailyReviewReminderSettings? settings,
  DateTime Function()? now,
}) {
  return DailyReviewReminderScheduler(
    settingsRepository: _FakeDailyReviewReminderSettingsRepository(
      settings ??
          DailyReviewReminderSettings(isEnabled: true, timeMinutes: 21 * 60),
    ),
    pendingChecker:
        pendingChecker ??
        _FakeDailyReviewPendingChecker(
          summary: const DailyReviewPendingSummary(
            unfinishedTodayTaskCount: 1,
            overdueTaskCount: 0,
            pendingHabitCount: 0,
          ),
        ),
    notifications: notifications ?? _FakeReminderNotificationClient(),
    now: now ?? () => DateTime(2026, 5, 21, 18),
  );
}

class _FakeDailyReviewReminderSettingsRepository
    implements DailyReviewReminderSettingsRepository {
  const _FakeDailyReviewReminderSettingsRepository(this.settings);

  final DailyReviewReminderSettings settings;

  @override
  Future<DailyReviewReminderSettings> loadSettings() async {
    return settings;
  }

  @override
  Future<void> saveSettings(DailyReviewReminderSettings settings) async {}
}

class _FakeDailyReviewPendingChecker extends DailyReviewPendingChecker {
  _FakeDailyReviewPendingChecker({required this.summary})
    : super(
        taskRepository: const _FakeTaskRepository(),
        habitRepository: const _FakeHabitRepository(),
      );

  final DailyReviewPendingSummary summary;
  int loadCount = 0;

  @override
  Future<DailyReviewPendingSummary> loadPendingSummary() async {
    loadCount++;

    return summary;
  }
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

class _FakeTaskRepository implements TaskRepository {
  const _FakeTaskRepository();

  @override
  Future<List<PlannerTask>> loadTasks() async {
    return const [];
  }

  @override
  Future<void> saveTask(PlannerTask task) async {}

  @override
  Future<void> updateTask(PlannerTask task) async {}

  @override
  Future<void> deleteTask(String taskId) async {}
}

class _FakeHabitRepository implements HabitRepository {
  const _FakeHabitRepository();

  @override
  Future<List<Habit>> loadHabits() async {
    return const [];
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
