import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_application_service.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_repository.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_store.dart';
import 'package:goal_planner/features/reminders/domain/standalone_reminder.dart';

void main() {
  group('StandaloneReminderStore', () {
    test('initializes standalone reminders', () async {
      final morning = _reminder(id: 'morning', timeMinutes: 9 * 60);
      final evening = _reminder(id: 'evening', timeMinutes: 21 * 60);
      final store = _store(
        repository: _FakeStandaloneReminderRepository(
          reminders: [evening, morning],
        ),
      );

      await store.initialize();

      expect(store.isInitialized, isTrue);
      expect(store.isLoading, isFalse);
      expect(store.reminders.map((reminder) => reminder.id), [
        'morning',
        'evening',
      ]);
    });

    test('does not initialize twice', () async {
      final repository = _FakeStandaloneReminderRepository();
      final store = _store(repository: repository);

      await store.initialize();
      await store.initialize();

      expect(repository.loadCount, 1);
    });

    test('creates standalone reminder and keeps list sorted', () async {
      final repository = _FakeStandaloneReminderRepository(
        reminders: [_reminder(id: 'evening', timeMinutes: 21 * 60)],
      );
      final notifications = _FakeReminderNotificationClient();
      final store = _store(
        repository: repository,
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 8),
      );

      await store.initialize();
      await store.createStandaloneReminder(
        title: '  Plan your day  ',
        timeMinutes: 9 * 60,
      );

      expect(store.reminders.map((reminder) => reminder.title), [
        'Plan your day',
        'Reminder evening',
      ]);
      expect(repository.savedReminders, hasLength(1));
      expect(notifications.scheduledReminders, hasLength(1));
    });

    test('does not create reminder with empty title', () async {
      final repository = _FakeStandaloneReminderRepository();
      final notifications = _FakeReminderNotificationClient();
      final store = _store(
        repository: repository,
        notifications: notifications,
      );

      await store.initialize();
      await store.createStandaloneReminder(title: '   ', timeMinutes: 9 * 60);

      expect(store.reminders, isEmpty);
      expect(repository.savedReminders, isEmpty);
      expect(notifications.scheduledReminders, isEmpty);
    });

    test('updates standalone reminder', () async {
      final reminder = _reminder(title: 'Old', timeMinutes: 9 * 60);
      final repository = _FakeStandaloneReminderRepository(
        reminders: [reminder],
      );
      final store = _store(repository: repository);

      await store.initialize();
      await store.updateStandaloneReminder(
        reminderId: reminder.id,
        title: 'Review today',
        timeMinutes: 21 * 60 + 30,
      );

      expect(store.reminders.single.title, 'Review today');
      expect(store.reminders.single.timeMinutes, 1290);
      expect(repository.updatedReminders, [store.reminders.single]);
    });

    test('enables and disables standalone reminder', () async {
      final reminder = _reminder(isEnabled: true);
      final repository = _FakeStandaloneReminderRepository(
        reminders: [reminder],
      );
      final store = _store(repository: repository);

      await store.initialize();
      await store.setStandaloneReminderEnabled(
        reminderId: reminder.id,
        isEnabled: false,
      );

      expect(store.reminders.single.isEnabled, isFalse);
      expect(repository.updatedReminders, [store.reminders.single]);
    });

    test('deletes standalone reminder', () async {
      final reminder = _reminder();
      final repository = _FakeStandaloneReminderRepository(
        reminders: [reminder],
      );
      final store = _store(repository: repository);

      await store.initialize();
      await store.deleteStandaloneReminder(reminder.id);

      expect(store.reminders, isEmpty);
      expect(repository.deletedIds, [reminder.id]);
    });

    test('ignores update, toggle and delete for unknown reminder id', () async {
      final repository = _FakeStandaloneReminderRepository();
      final store = _store(repository: repository);

      await store.initialize();

      await store.updateStandaloneReminder(
        reminderId: 'missing',
        title: 'Missing',
        timeMinutes: 9 * 60,
      );
      await store.setStandaloneReminderEnabled(
        reminderId: 'missing',
        isEnabled: false,
      );
      await store.deleteStandaloneReminder('missing');

      expect(repository.updatedReminders, isEmpty);
      expect(repository.deletedIds, isEmpty);
    });
  });
}

StandaloneReminderStore _store({
  required _FakeStandaloneReminderRepository repository,
  _FakeReminderNotificationClient? notifications,
  DateTime Function()? now,
}) {
  final notificationClient = notifications ?? _FakeReminderNotificationClient();
  final currentTime = now ?? () => DateTime(2026, 5, 21, 8);

  return StandaloneReminderStore(
    applicationService: StandaloneReminderApplicationService(
      repository: repository,
      scheduler: StandaloneReminderScheduler(
        notifications: notificationClient,
        now: currentTime,
      ),
      now: currentTime,
    ),
  );
}

StandaloneReminder _reminder({
  String id = 'reminder_1',
  String? title,
  int timeMinutes = 9 * 60,
  bool isEnabled = true,
}) {
  final now = DateTime(2026, 5, 21, 8);

  return StandaloneReminder(
    id: id,
    title: title ?? 'Reminder $id',
    timeMinutes: timeMinutes,
    isEnabled: isEnabled,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeStandaloneReminderRepository
    implements StandaloneReminderRepository {
  _FakeStandaloneReminderRepository({List<StandaloneReminder>? reminders})
    : reminders = [...?reminders];

  final List<StandaloneReminder> reminders;
  final savedReminders = <StandaloneReminder>[];
  final updatedReminders = <StandaloneReminder>[];
  final deletedIds = <String>[];
  int loadCount = 0;

  @override
  Future<List<StandaloneReminder>> loadStandaloneReminders() async {
    loadCount++;
    return reminders;
  }

  @override
  Future<void> saveStandaloneReminder(StandaloneReminder reminder) async {
    savedReminders.add(reminder);
    reminders.add(reminder);
  }

  @override
  Future<void> updateStandaloneReminder(StandaloneReminder reminder) async {
    updatedReminders.add(reminder);

    for (var index = 0; index < reminders.length; index++) {
      if (reminders[index].id == reminder.id) {
        reminders[index] = reminder;
        return;
      }
    }
  }

  @override
  Future<void> deleteStandaloneReminder(String reminderId) async {
    deletedIds.add(reminderId);
    reminders.removeWhere((reminder) => reminder.id == reminderId);
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
  }) async {
    scheduledReminders.add(
      _ScheduledReminder(
        id: id,
        title: title,
        body: body,
        scheduledAt: scheduledAt,
        payload: payload,
      ),
    );
  }

  @override
  Future<void> cancelReminder(int id) async {
    canceledIds.add(id);
  }
}

class _ScheduledReminder {
  _ScheduledReminder({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledAt,
    required this.payload,
  });

  final int id;
  final String title;
  final String body;
  final DateTime scheduledAt;
  final String? payload;
}
