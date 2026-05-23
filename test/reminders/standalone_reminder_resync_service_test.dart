import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';
import 'package:goal_planner/features/reminders/standalone/application/standalone_reminder_repository.dart';
import 'package:goal_planner/features/reminders/standalone/application/standalone_reminder_resync_service.dart';
import 'package:goal_planner/features/reminders/standalone/application/standalone_reminder_scheduler.dart';
import 'package:goal_planner/features/reminders/standalone/domain/standalone_reminder.dart';

void main() {
  group('StandaloneReminderResyncService', () {
    test('syncs all standalone reminders loaded from repository', () async {
      final repository = _FakeStandaloneReminderRepository([
        _reminder(id: 'morning', timeMinutes: 9 * 60),
        _reminder(id: 'disabled', timeMinutes: 10 * 60, isEnabled: false),
      ]);
      final notifications = _FakeReminderNotificationClient();
      final service = _service(
        repository: repository,
        notifications: notifications,
      );

      await service.syncStandaloneReminders();

      expect(notifications.canceledIds, [
        standaloneReminderNotificationId('morning'),
        standaloneReminderNotificationId('disabled'),
      ]);
      expect(notifications.scheduledReminders, hasLength(1));
      expect(
        notifications.scheduledReminders.single.id,
        standaloneReminderNotificationId('morning'),
      );
      expect(
        notifications.scheduledReminders.single.repeat,
        ReminderRepeat.daily,
      );
    });

    test(
      'cancels removed reminders and syncs current reminders after replacement',
      () async {
        final notifications = _FakeReminderNotificationClient();
        final service = _service(
          repository: _FakeStandaloneReminderRepository(),
          notifications: notifications,
        );

        await service.syncAfterStandaloneReminderSetReplacement(
          previousReminders: [
            _reminder(id: 'removed', timeMinutes: 8 * 60),
            _reminder(id: 'kept', timeMinutes: 9 * 60),
          ],
          currentReminders: [
            _reminder(id: 'kept', timeMinutes: 9 * 60),
            _reminder(
              id: 'restored',
              scheduleType: StandaloneReminderScheduleType.once,
              scheduledDate: DateTime(2026, 5, 22),
              timeMinutes: 18 * 60 + 30,
            ),
          ],
        );

        expect(notifications.canceledIds, [
          standaloneReminderNotificationId('removed'),
          standaloneReminderNotificationId('kept'),
          standaloneReminderNotificationId('restored'),
        ]);
        expect(notifications.scheduledReminders.map((call) => call.id), [
          standaloneReminderNotificationId('kept'),
          standaloneReminderNotificationId('restored'),
        ]);
        expect(notifications.scheduledReminders.map((call) => call.repeat), [
          ReminderRepeat.daily,
          ReminderRepeat.none,
        ]);
      },
    );

    test('loads standalone reminders from repository', () async {
      final repository = _FakeStandaloneReminderRepository([
        _reminder(id: 'reminder_1', timeMinutes: 9 * 60),
      ]);
      final service = _service(repository: repository);

      final reminders = await service.loadStandaloneReminders();

      expect(reminders.map((reminder) => reminder.id), ['reminder_1']);
    });
  });
}

StandaloneReminderResyncService _service({
  required _FakeStandaloneReminderRepository repository,
  _FakeReminderNotificationClient? notifications,
}) {
  final notificationClient = notifications ?? _FakeReminderNotificationClient();

  return StandaloneReminderResyncService(
    repository: repository,
    scheduler: StandaloneReminderScheduler(
      notifications: notificationClient,
      now: () => DateTime(2026, 5, 21, 8),
    ),
  );
}

StandaloneReminder _reminder({
  required String id,
  StandaloneReminderScheduleType scheduleType =
      StandaloneReminderScheduleType.daily,
  DateTime? scheduledDate,
  required int timeMinutes,
  bool isEnabled = true,
}) {
  final now = DateTime(2026, 5, 21, 8);

  return StandaloneReminder(
    id: id,
    title: 'Reminder $id',
    scheduleType: scheduleType,
    scheduledDate: scheduledDate,
    timeMinutes: timeMinutes,
    isEnabled: isEnabled,
    createdAt: now,
    updatedAt: now,
  );
}

class _FakeStandaloneReminderRepository
    implements StandaloneReminderRepository {
  const _FakeStandaloneReminderRepository([this.reminders = const []]);

  final List<StandaloneReminder> reminders;

  @override
  Future<List<StandaloneReminder>> loadStandaloneReminders() async {
    return reminders;
  }

  @override
  Future<void> saveStandaloneReminder(StandaloneReminder reminder) async {}

  @override
  Future<void> updateStandaloneReminder(StandaloneReminder reminder) async {}

  @override
  Future<void> deleteStandaloneReminder(String reminderId) async {}
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
