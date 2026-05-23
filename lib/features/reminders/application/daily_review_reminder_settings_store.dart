import 'package:flutter/foundation.dart';

import '../domain/daily_review_reminder_settings.dart';
import 'daily_review_reminder_settings_repository.dart';

class DailyReviewReminderSettingsStore extends ChangeNotifier {
  DailyReviewReminderSettingsStore({
    required DailyReviewReminderSettingsRepository settingsRepository,
    required Future<void> Function() syncDailyReviewReminder,
  }) : _settingsRepository = settingsRepository,
       _syncDailyReviewReminder = syncDailyReviewReminder;

  final DailyReviewReminderSettingsRepository _settingsRepository;
  final Future<void> Function() _syncDailyReviewReminder;

  DailyReviewReminderSettings _settings =
      const DailyReviewReminderSettings.defaults();
  bool _isInitialized = false;
  bool _isLoading = false;

  DailyReviewReminderSettings get settings => _settings;

  bool get isInitialized => _isInitialized;

  bool get isLoading => _isLoading;

  Future<void> initialize() async {
    if (_isInitialized || _isLoading) {
      return;
    }

    _isLoading = true;
    notifyListeners();

    try {
      _settings = await _settingsRepository.loadSettings();
      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setEnabled(bool isEnabled) async {
    if (_settings.isEnabled == isEnabled) {
      return;
    }

    await _saveSettings(_settings.copyWith(isEnabled: isEnabled));
  }

  Future<void> setTimeMinutes(int timeMinutes) async {
    if (_settings.timeMinutes == timeMinutes) {
      return;
    }

    await _saveSettings(_settings.copyWith(timeMinutes: timeMinutes));
  }

  Future<void> _saveSettings(DailyReviewReminderSettings settings) async {
    _settings = settings;
    notifyListeners();

    await _settingsRepository.saveSettings(settings);
    await _syncDailyReviewReminder();
  }
}
