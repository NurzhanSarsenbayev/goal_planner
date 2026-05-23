import 'package:flutter/foundation.dart';

import '../domain/standalone_reminder.dart';
import 'standalone_reminder_application_service.dart';

class StandaloneReminderStore extends ChangeNotifier {
  StandaloneReminderStore({
    required StandaloneReminderApplicationService applicationService,
  }) : _applicationService = applicationService;

  final StandaloneReminderApplicationService _applicationService;

  List<StandaloneReminder> _reminders = [];
  bool _isInitialized = false;
  bool _isLoading = false;

  List<StandaloneReminder> get reminders => List.unmodifiable(_reminders);

  bool get isInitialized => _isInitialized;

  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    await reload();
  }

  Future<void> reload() async {
    if (_isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      final loadedReminders = await _applicationService
          .loadStandaloneReminders();

      _reminders = [...loadedReminders];
      _sortReminders();
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createStandaloneReminder({
    required String title,
    required StandaloneReminderScheduleType scheduleType,
    required DateTime? scheduledDate,
    required int timeMinutes,
  }) async {
    final reminder = await _applicationService.createStandaloneReminder(
      title: title,
      scheduleType: scheduleType,
      scheduledDate: scheduledDate,
      timeMinutes: timeMinutes,
    );

    if (reminder == null) {
      return;
    }

    _reminders = [..._reminders, reminder];
    _sortReminders();
    notifyListeners();
  }

  Future<void> updateStandaloneReminder({
    required String reminderId,
    required String title,
    required StandaloneReminderScheduleType scheduleType,
    required DateTime? scheduledDate,
    required int timeMinutes,
  }) async {
    final reminder = _findReminder(reminderId);

    if (reminder == null) {
      return;
    }

    final updated = await _applicationService.updateStandaloneReminder(
      reminder: reminder,
      title: title,
      scheduleType: scheduleType,
      scheduledDate: scheduledDate,
      timeMinutes: timeMinutes,
    );

    _replaceReminder(updated);
    notifyListeners();
  }

  Future<void> setStandaloneReminderEnabled({
    required String reminderId,
    required bool isEnabled,
  }) async {
    final reminder = _findReminder(reminderId);

    if (reminder == null) {
      return;
    }

    final updated = await _applicationService.setStandaloneReminderEnabled(
      reminder: reminder,
      isEnabled: isEnabled,
    );

    _replaceReminder(updated);
    notifyListeners();
  }

  Future<void> deleteStandaloneReminder(String reminderId) async {
    final reminder = _findReminder(reminderId);

    if (reminder == null) {
      return;
    }

    await _applicationService.deleteStandaloneReminder(reminder.id);

    _reminders = _reminders
        .where((candidate) => candidate.id != reminder.id)
        .toList();
    notifyListeners();
  }

  StandaloneReminder? _findReminder(String reminderId) {
    for (final reminder in _reminders) {
      if (reminder.id == reminderId) {
        return reminder;
      }
    }

    return null;
  }

  void _replaceReminder(StandaloneReminder updated) {
    _reminders = [
      for (final reminder in _reminders)
        if (reminder.id == updated.id) updated else reminder,
    ];
    _sortReminders();
  }

  void _sortReminders() {
    _reminders.sort((a, b) {
      final timeComparison = a.timeMinutes.compareTo(b.timeMinutes);

      if (timeComparison != 0) {
        return timeComparison;
      }

      return a.createdAt.compareTo(b.createdAt);
    });
  }
}
