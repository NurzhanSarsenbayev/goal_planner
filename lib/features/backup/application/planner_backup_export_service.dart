import '../../goals/application/goal_repository.dart';
import '../../habits/application/habit_repository.dart';
import '../../milestones/application/milestone_repository.dart';
import '../../recurring/application/recurring_task_repository.dart';
import '../../tasks/application/task_repository.dart';
import '../../reminders/standalone/application/standalone_reminder_repository.dart';
import '../../reminders/daily_review/application/daily_review_reminder_settings_repository.dart';
import '../domain/planner_backup.dart';

class PlannerBackupExportService {
  PlannerBackupExportService({
    required GoalRepository goalRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
    required RecurringTaskRepository recurringTaskRepository,
    required HabitRepository habitRepository,
    required StandaloneReminderRepository standaloneReminderRepository,
    required DailyReviewReminderSettingsRepository
    dailyReviewReminderSettingsRepository,
    DateTime Function()? now,
  }) : _goalRepository = goalRepository,
       _milestoneRepository = milestoneRepository,
       _taskRepository = taskRepository,
       _recurringTaskRepository = recurringTaskRepository,
       _habitRepository = habitRepository,
       _standaloneReminderRepository = standaloneReminderRepository,
       _dailyReviewReminderSettingsRepository =
           dailyReviewReminderSettingsRepository,
       _now = now ?? DateTime.now;

  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;
  final RecurringTaskRepository _recurringTaskRepository;
  final HabitRepository _habitRepository;
  final StandaloneReminderRepository _standaloneReminderRepository;
  final DailyReviewReminderSettingsRepository
  _dailyReviewReminderSettingsRepository;
  final DateTime Function() _now;

  Future<PlannerBackup> createBackup() async {
    final goals = await _goalRepository.loadGoals();
    final milestones = await _milestoneRepository.loadMilestones();
    final tasks = await _taskRepository.loadTasks();
    final recurringRules = await _recurringTaskRepository
        .loadRecurringTaskRules();
    final recurringExceptions = await _recurringTaskRepository
        .loadRecurringTaskExceptions();
    final habits = await _habitRepository.loadHabits();
    final habitEntries = await _habitRepository.loadAllEntries();
    final standaloneReminders = await _standaloneReminderRepository
        .loadStandaloneReminders();
    final dailyReviewReminderSettings =
        await _dailyReviewReminderSettingsRepository.loadSettings();

    return PlannerBackup.create(
      exportedAt: _now(),
      data: PlannerBackupData(
        goals: goals,
        milestones: milestones,
        tasks: tasks,
        recurringRules: recurringRules,
        recurringExceptions: recurringExceptions,
        habits: habits,
        habitEntries: habitEntries,
        standaloneReminders: standaloneReminders,
        dailyReviewReminderSettings: dailyReviewReminderSettings,
      ),
    );
  }
}
