import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/data/local/app_database.dart' as local;
import 'package:goal_planner/data/repositories/drift_standalone_reminder_repository.dart';
import 'package:goal_planner/features/reminders/domain/standalone_reminder.dart';

void main() {
  group('DriftStandaloneReminderRepository', () {
    late local.AppDatabase database;
    late DriftStandaloneReminderRepository repository;

    setUp(() {
      database = local.AppDatabase.forTesting(NativeDatabase.memory());
      repository = DriftStandaloneReminderRepository(database);
    });

    tearDown(() async {
      await database.close();
    });

    test('persists and loads standalone reminder', () async {
      final reminder = _reminder();

      await repository.saveStandaloneReminder(reminder);

      final reminders = await repository.loadStandaloneReminders();

      expect(reminders, hasLength(1));
      expect(reminders.single.id, 'reminder_1');
      expect(reminders.single.title, 'Plan your day');
      expect(reminders.single.timeMinutes, 540);
      expect(reminders.single.isEnabled, isTrue);
      expect(reminders.single.createdAt, reminder.createdAt);
      expect(reminders.single.updatedAt, reminder.updatedAt);
      expect(
        reminders.single.scheduleType,
        StandaloneReminderScheduleType.daily,
      );
      expect(reminders.single.scheduledDate, isNull);
    });

    test('persists one-time standalone reminder schedule date', () async {
      final scheduledDate = DateTime(2026, 5, 22);

      await repository.saveStandaloneReminder(
        _reminder(
          id: 'once',
          title: 'Call vet',
          scheduleType: StandaloneReminderScheduleType.once,
          scheduledDate: scheduledDate,
          timeMinutes: 18 * 60 + 30,
        ),
      );

      final reminders = await repository.loadStandaloneReminders();

      expect(
        reminders.single.scheduleType,
        StandaloneReminderScheduleType.once,
      );
      expect(reminders.single.scheduledDate, scheduledDate);
      expect(reminders.single.timeMinutes, 1110);
    });

    test('loads standalone reminders ordered by time', () async {
      await repository.saveStandaloneReminder(
        _reminder(id: 'evening', title: 'Review today', timeMinutes: 21 * 60),
      );
      await repository.saveStandaloneReminder(
        _reminder(id: 'morning', title: 'Plan your day', timeMinutes: 9 * 60),
      );

      final reminders = await repository.loadStandaloneReminders();

      expect(reminders.map((reminder) => reminder.id), ['morning', 'evening']);
    });

    test('updates standalone reminder', () async {
      final reminder = _reminder();
      final updatedAt = DateTime(2026, 5, 21, 12);

      await repository.saveStandaloneReminder(reminder);
      final scheduledDate = DateTime(2026, 5, 22);

      await repository.updateStandaloneReminder(
        reminder.copyWith(
          title: 'Review today',
          scheduleType: StandaloneReminderScheduleType.once,
          scheduledDate: scheduledDate,
          timeMinutes: 21 * 60 + 30,
          isEnabled: false,
          updatedAt: updatedAt,
        ),
      );

      final reminders = await repository.loadStandaloneReminders();

      expect(reminders, hasLength(1));
      expect(reminders.single.title, 'Review today');
      expect(
        reminders.single.scheduleType,
        StandaloneReminderScheduleType.once,
      );
      expect(reminders.single.scheduledDate, scheduledDate);
      expect(reminders.single.timeMinutes, 1290);
      expect(reminders.single.isEnabled, isFalse);
      expect(reminders.single.updatedAt, updatedAt);
    });

    test('deletes standalone reminder', () async {
      await repository.saveStandaloneReminder(_reminder());

      await repository.deleteStandaloneReminder('reminder_1');

      final reminders = await repository.loadStandaloneReminders();

      expect(reminders, isEmpty);
    });
  });
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
