import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';
import '../../habits/application/habit_repository.dart';
import '../../habits/domain/habit.dart';
import '../../habits/domain/habit_entry.dart';
import '../../habits/domain/habit_entry_status.dart';
import '../../tasks/application/task_repository.dart';

class DailyReviewPendingSummary {
  const DailyReviewPendingSummary({
    required this.unfinishedTodayTaskCount,
    required this.overdueTaskCount,
    required this.pendingHabitCount,
  });

  final int unfinishedTodayTaskCount;
  final int overdueTaskCount;
  final int pendingHabitCount;

  int get pendingItemCount {
    return unfinishedTodayTaskCount + overdueTaskCount + pendingHabitCount;
  }

  bool get hasPendingItems => pendingItemCount > 0;
}

class DailyReviewPendingChecker {
  const DailyReviewPendingChecker({
    required TaskRepository taskRepository,
    required HabitRepository habitRepository,
    DateTime Function()? todayProvider,
  }) : _taskRepository = taskRepository,
       _habitRepository = habitRepository,
       _todayProvider = todayProvider ?? todayDate;

  final TaskRepository _taskRepository;
  final HabitRepository _habitRepository;
  final DateTime Function() _todayProvider;

  Future<DailyReviewPendingSummary> loadPendingSummary() async {
    final reviewDate = dateOnly(_todayProvider());
    final tasks = await _taskRepository.loadTasks();
    final habits = await _habitRepository.loadHabits();
    final habitEntries = await _habitRepository.loadEntriesForRange(
      startDate: reviewDate,
      endDate: reviewDate,
    );

    return buildPendingSummary(
      tasks: tasks,
      habits: habits,
      habitEntries: habitEntries,
      reviewDate: reviewDate,
    );
  }

  DailyReviewPendingSummary buildPendingSummary({
    required List<PlannerTask> tasks,
    required List<Habit> habits,
    required List<HabitEntry> habitEntries,
    required DateTime reviewDate,
  }) {
    final normalizedReviewDate = dateOnly(reviewDate);
    final unfinishedTodayTaskCount = tasks
        .where(
          (task) =>
              !task.isCompleted &&
              _isScheduledForDate(task, normalizedReviewDate),
        )
        .length;
    final overdueTaskCount = tasks
        .where(
          (task) => !task.isCompleted && _isOverdue(task, normalizedReviewDate),
        )
        .length;
    final habitEntriesByHabitId = {
      for (final entry in habitEntries)
        if (entry.date == normalizedReviewDate) entry.habitId: entry,
    };
    final pendingHabitCount = habits
        .where((habit) => !habit.isArchived)
        .where((habit) => _isHabitPending(habit, habitEntriesByHabitId))
        .length;

    return DailyReviewPendingSummary(
      unfinishedTodayTaskCount: unfinishedTodayTaskCount,
      overdueTaskCount: overdueTaskCount,
      pendingHabitCount: pendingHabitCount,
    );
  }

  bool _isScheduledForDate(PlannerTask task, DateTime date) {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return false;
    }

    return dateOnly(scheduledDate) == date;
  }

  bool _isOverdue(PlannerTask task, DateTime reviewDate) {
    final scheduledDate = task.scheduledDate;

    if (scheduledDate == null) {
      return false;
    }

    return dateOnly(scheduledDate).isBefore(reviewDate);
  }

  bool _isHabitPending(Habit habit, Map<String, HabitEntry> entriesByHabitId) {
    final entry = entriesByHabitId[habit.id];

    if (entry == null) {
      return true;
    }

    switch (entry.status) {
      case HabitEntryStatus.none:
        return true;
      case HabitEntryStatus.incomplete:
        return true;
      case HabitEntryStatus.done:
      case HabitEntryStatus.skipped:
      case HabitEntryStatus.failed:
        return false;
    }
  }
}
