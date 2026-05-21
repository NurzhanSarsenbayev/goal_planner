import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_application_service.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_repository.dart';
import 'package:goal_planner/features/reminders/application/standalone_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/domain/standalone_reminder.dart';

void main() {
  group('StandaloneReminderApplicationService', () {
    test('loads standalone reminders from repository', () async {
      final repository = FakeStandaloneReminderRepository(
        reminders: [_reminder()],
      );
      final service = _service(repository: repository);

      final reminders = await service.loadStandaloneReminders();

      expect(reminders, hasLength(1));
      expect(reminders.single.id, 'reminder_1');
    });

    test('creates enabled reminder and schedules it', () async {
      final repository = FakeStandaloneReminderRepository();
      final notifications = FakeReminderNotificationClient();
      final service = _service(
        repository: repository,
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 8),
      );

      final reminder = await service.createStandaloneReminder(
        title: '  Plan your day  ',
        scheduleType: StandaloneReminderScheduleType.daily,
        scheduledDate: null,
        timeMinutes: 9 * 60,
      );

      expect(reminder, isNotNull);
      expect(reminder!.title, 'Plan your day');
      expect(reminder.timeMinutes, 540);
      expect(reminder.isEnabled, isTrue);
      expect(repository.savedReminders, [reminder]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.id,
        standaloneReminderNotificationId(reminder.id),
      );
    });

    test('does not create reminder with empty title', () async {
      final repository = FakeStandaloneReminderRepository();
      final notifications = FakeReminderNotificationClient();
      final service = _service(
        repository: repository,
        notifications: notifications,
      );

      final reminder = await service.createStandaloneReminder(
        title: '   ',
        scheduleType: StandaloneReminderScheduleType.daily,
        scheduledDate: null,
        timeMinutes: 9 * 60,
      );

      expect(reminder, isNull);
      expect(repository.savedReminders, isEmpty);
      expect(notifications.scheduledReminders, isEmpty);
      expect(notifications.canceledIds, isEmpty);
    });

    test('updates reminder and reschedules it', () async {
      final repository = FakeStandaloneReminderRepository();
      final notifications = FakeReminderNotificationClient();
      final service = _service(
        repository: repository,
        notifications: notifications,
        now: () => DateTime(2026, 5, 21, 10),
      );

      final updated = await service.updateStandaloneReminder(
        reminder: _reminder(),
        title: '  Review today  ',
        scheduleType: StandaloneReminderScheduleType.daily,
        scheduledDate: null,
        timeMinutes: 21 * 60 + 30,
      );

      expect(updated.title, 'Review today');
      expect(updated.timeMinutes, 1290);
      expect(repository.updatedReminders, [updated]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.scheduledAt,
        DateTime(2026, 5, 21, 21, 30),
      );
    });

    test(
      'disables reminder and cancels notification without scheduling',
      () async {
        final repository = FakeStandaloneReminderRepository();
        final notifications = FakeReminderNotificationClient();
        final service = _service(
          repository: repository,
          notifications: notifications,
        );

        final updated = await service.setStandaloneReminderEnabled(
          reminder: _reminder(),
          isEnabled: false,
        );

        expect(updated.isEnabled, isFalse);
        expect(repository.updatedReminders, [updated]);
        expect(notifications.canceledIds, [
          standaloneReminderNotificationId('reminder_1'),
        ]);
        expect(notifications.scheduledReminders, isEmpty);
      },
    );

    test('deletes reminder and cancels notification', () async {
      final repository = FakeStandaloneReminderRepository();
      final notifications = FakeReminderNotificationClient();
      final service = _service(
        repository: repository,
        notifications: notifications,
      );

      await service.deleteStandaloneReminder('reminder_1');

      expect(repository.deletedIds, ['reminder_1']);
      expect(notifications.canceledIds, [
        standaloneReminderNotificationId('reminder_1'),
      ]);
    });
  });
}

StandaloneReminderApplicationService _service({
  required FakeStandaloneReminderRepository repository,
  FakeReminderNotificationClient? notifications,
  DateTime Function()? now,
}) {
  final notificationClient = notifications ?? FakeReminderNotificationClient();

  return StandaloneReminderApplicationService(
    repository: repository,
    scheduler: StandaloneReminderScheduler(
      notifications: notificationClient,
      now: now ?? () => DateTime(2026, 5, 21, 8),
    ),
    now: now ?? () => DateTime(2026, 5, 21, 8),
  );
}

StandaloneReminder _reminder({
  String id = 'reminder_1',
  String title = 'Plan your day',
  StandaloneReminderScheduleType scheduleType =
      StandaloneReminderScheduleType.daily,
  DateTime? scheduledDate,
  int timeMinutes = 9 * 60,
  bool isEnabled = true,
}) {
  final now = DateTime(2026, 5, 21, 8);

  return StandaloneReminder(
    id: id,
    title: title,
    scheduleType: scheduleType,
    scheduledDate: scheduledDate,
    timeMinutes: timeMinutes,
    isEnabled: isEnabled,
    createdAt: now,
    updatedAt: now,
  );
}

class FakeStandaloneReminderRepository implements StandaloneReminderRepository {
  FakeStandaloneReminderRepository({List<StandaloneReminder>? reminders})
    : reminders = reminders ?? [];

  final List<StandaloneReminder> reminders;
  final savedReminders = <StandaloneReminder>[];
  final updatedReminders = <StandaloneReminder>[];
  final deletedIds = <String>[];

  @override
  Future<List<StandaloneReminder>> loadStandaloneReminders() async {
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
  }

  @override
  Future<void> deleteStandaloneReminder(String reminderId) async {
    deletedIds.add(reminderId);
  }
}

class FakeReminderNotificationClient implements ReminderNotificationClient {
  final scheduledReminders = <ScheduledReminder>[];
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
      ScheduledReminder(
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

class ScheduledReminder {
  ScheduledReminder({
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
