import 'package:flutter/foundation.dart';

import '../../../shared/planner_dates.dart';
import '../domain/habit.dart';
import '../domain/habit_entry.dart';
import '../domain/habit_entry_status.dart';
import '../domain/habit_tracking_type.dart';
import 'habit_application_service.dart';
import 'habit_repository.dart';
import 'habit_week_view_builder.dart';
import 'habit_today_summary.dart';

class HabitStore extends ChangeNotifier {
  HabitStore({
    required HabitRepository habitRepository,
    HabitApplicationService habitApplicationService =
        const HabitApplicationService(),
    HabitWeekViewBuilder habitWeekViewBuilder = const HabitWeekViewBuilder(),
    HabitTodaySummaryBuilder habitTodaySummaryBuilder =
        const HabitTodaySummaryBuilder(),
    DateTime Function() todayProvider = todayDate,
    DateTime? initialWeekStart,
  }) : _habitRepository = habitRepository,
       _habitApplicationService = habitApplicationService,
       _habitWeekViewBuilder = habitWeekViewBuilder,
       _habitTodaySummaryBuilder = habitTodaySummaryBuilder,
       _todayProvider = todayProvider,
       _visibleWeekStart = dateOnly(
         initialWeekStart ?? _startOfWeek(DateTime.now()),
       );

  final HabitRepository _habitRepository;
  final HabitApplicationService _habitApplicationService;
  final HabitWeekViewBuilder _habitWeekViewBuilder;
  final HabitTodaySummaryBuilder _habitTodaySummaryBuilder;
  final DateTime Function() _todayProvider;

  List<Habit> _habits = [];
  List<HabitEntry> _visibleWeekEntries = [];
  List<HabitEntry> _todayEntries = [];
  DateTime _visibleWeekStart;
  bool _isInitialized = false;
  bool _isLoading = false;

  List<Habit> get habits => List.unmodifiable(_habits);

  List<HabitEntry> get visibleWeekEntries =>
      List.unmodifiable(_visibleWeekEntries);

  List<HabitEntry> get todayEntries => List.unmodifiable(_todayEntries);

  DateTime get visibleWeekStart => _visibleWeekStart;

  bool get isInitialized => _isInitialized;

  bool get isLoading => _isLoading;

  HabitWeekView get weekView {
    return _habitWeekViewBuilder.build(
      habits: _habits,
      entries: _visibleWeekEntries,
      weekStart: _visibleWeekStart,
    );
  }

  HabitTodaySummary get todaySummary {
    return _habitTodaySummaryBuilder.build(
      habits: _habits,
      entries: _todayEntries,
      date: _todayDate,
    );
  }

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
      _habits = await _habitRepository.loadHabits();
      _visibleWeekEntries = await _habitRepository.loadEntriesForRange(
        startDate: _visibleWeekStart,
        endDate: _visibleWeekEnd,
      );
      _todayEntries = await _habitRepository.loadEntriesForRange(
        startDate: _todayDate,
        endDate: _todayDate,
      );

      _isInitialized = true;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> goToPreviousWeek() async {
    await setVisibleWeek(_visibleWeekStart.subtract(const Duration(days: 7)));
  }

  Future<void> goToNextWeek() async {
    await setVisibleWeek(_visibleWeekStart.add(const Duration(days: 7)));
  }

  Future<void> goToCurrentWeek() async {
    await setVisibleWeek(_startOfWeek(DateTime.now()));
  }

  Future<void> setVisibleWeek(DateTime weekStart) async {
    final normalizedWeekStart = dateOnly(weekStart);

    if (normalizedWeekStart == _visibleWeekStart) {
      return;
    }

    _visibleWeekStart = normalizedWeekStart;
    _isLoading = true;
    notifyListeners();

    _visibleWeekEntries = await _habitRepository.loadEntriesForRange(
      startDate: _visibleWeekStart,
      endDate: _visibleWeekEnd,
    );

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createHabit({
    required String title,
    required String description,
    HabitTrackingType trackingType = HabitTrackingType.binary,
    int? targetCount,
  }) async {
    final result = _habitApplicationService.createHabit(
      habits: _habits,
      title: title,
      description: description,
      trackingType: trackingType,
      targetCount: targetCount,
    );

    await _applyHabitMutation(result);
  }

  Future<void> updateHabit({
    required String habitId,
    required String title,
    required String description,
    HabitTrackingType? trackingType,
    int? targetCount,
  }) async {
    final result = _habitApplicationService.updateHabit(
      habits: _habits,
      habitId: habitId,
      title: title,
      description: description,
      trackingType: trackingType,
      targetCount: targetCount,
    );

    await _applyHabitMutation(result);
  }

  Future<void> updateHabitReminder({
    required String habitId,
    required bool isReminderEnabled,
    required int? reminderTimeMinutes,
  }) async {
    final result = _habitApplicationService.updateHabitReminder(
      habits: _habits,
      habitId: habitId,
      isReminderEnabled: isReminderEnabled,
      reminderTimeMinutes: reminderTimeMinutes,
    );

    await _applyHabitMutation(result);
  }

  Future<void> archiveHabit(String habitId) async {
    final result = _habitApplicationService.archiveHabit(
      habits: _habits,
      habitId: habitId,
    );

    await _applyHabitMutation(result);
  }

  Future<void> unarchiveHabit(String habitId) async {
    final result = _habitApplicationService.unarchiveHabit(
      habits: _habits,
      habitId: habitId,
    );

    await _applyHabitMutation(result);
  }

  Future<void> deleteHabit(String habitId) async {
    final result = _habitApplicationService.deleteHabit(
      habits: _habits,
      habitId: habitId,
    );

    await _applyHabitMutation(result);
  }

  Future<void> markEntry({
    required String habitId,
    required DateTime date,
    required HabitEntryStatus status,
    int completedCount = 0,
  }) async {
    final habit = _findHabit(habitId);

    if (habit == null) {
      return;
    }

    final result = _habitApplicationService.markEntry(
      entries: _visibleWeekEntries,
      habit: habit,
      date: date,
      status: status,
      completedCount: completedCount,
    );

    await _applyEntryMutation(result, affectedDate: date);
  }

  Future<void> clearEntry({
    required String habitId,
    required DateTime date,
  }) async {
    final result = _habitApplicationService.clearEntry(
      entries: _visibleWeekEntries,
      habitId: habitId,
      date: date,
    );

    await _applyEntryMutation(result, affectedDate: date);
  }

  Future<List<HabitEntry>> loadEntriesForRange({
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return _habitRepository.loadEntriesForRange(
      startDate: dateOnly(startDate),
      endDate: dateOnly(endDate),
    );
  }

  Habit? _findHabit(String habitId) {
    for (final habit in _habits) {
      if (habit.id == habitId) {
        return habit;
      }
    }

    return null;
  }

  Future<void> _applyHabitMutation(HabitMutationResult result) async {
    if (!result.hasChange) {
      return;
    }

    _habits = result.habits;
    notifyListeners();

    final habitToPersist = result.habitToPersist;
    final habitIdToDelete = result.habitIdToDelete;

    if (habitToPersist != null) {
      await _habitRepository.saveHabit(habitToPersist);
    }

    if (habitIdToDelete != null) {
      await _habitRepository.deleteHabit(habitIdToDelete);
      _visibleWeekEntries = [
        for (final entry in _visibleWeekEntries)
          if (entry.habitId != habitIdToDelete) entry,
      ];
      _todayEntries = [
        for (final entry in _todayEntries)
          if (entry.habitId != habitIdToDelete) entry,
      ];
      notifyListeners();
    }
  }

  Future<void> _applyEntryMutation(
    HabitEntryMutationResult result, {
    required DateTime affectedDate,
  }) async {
    if (!result.hasChange) {
      return;
    }

    _visibleWeekEntries = result.entries;

    if (dateOnly(affectedDate) == _todayDate) {
      _todayEntries = [
        for (final entry in result.entries)
          if (entry.date == _todayDate) entry,
      ];
    }

    notifyListeners();

    final entryToPersist = result.entryToPersist;
    final entryIdToDelete = result.entryIdToDelete;

    if (entryToPersist != null) {
      await _habitRepository.saveEntry(entryToPersist);
    }

    if (entryIdToDelete != null) {
      await _habitRepository.deleteEntry(entryIdToDelete);
    }
  }

  DateTime get _visibleWeekEnd {
    return _visibleWeekStart.add(const Duration(days: 6));
  }

  DateTime get _todayDate {
    return dateOnly(_todayProvider());
  }

  static DateTime _startOfWeek(DateTime date) {
    final normalizedDate = dateOnly(date);

    return normalizedDate.subtract(
      Duration(days: normalizedDate.weekday - DateTime.monday),
    );
  }
}
