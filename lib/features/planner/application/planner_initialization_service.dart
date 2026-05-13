import '../../../models/goal.dart';
import '../../../models/milestone.dart';
import '../../../models/planner_task.dart';
import '../../../models/recurring_task_exception.dart';
import '../../../models/recurring_task_rule.dart';
import '../../../shared/planner_dates.dart';
import '../../goals/application/goal_repository.dart';
import '../../milestones/application/milestone_repository.dart';
import '../../recurring/application/recurring_task_application_service.dart';
import '../../recurring/application/recurring_task_repository.dart';
import '../../tasks/application/task_repository.dart';

class PlannerInitialState {
  const PlannerInitialState({
    required this.goals,
    required this.milestones,
    required this.tasks,
    required this.recurringRules,
    required this.recurringExceptions,
  });

  final List<Goal> goals;
  final List<Milestone> milestones;
  final List<PlannerTask> tasks;
  final List<RecurringTaskRule> recurringRules;
  final List<RecurringTaskException> recurringExceptions;
}

class PlannerInitializationService {
  PlannerInitializationService({
    required GoalRepository goalRepository,
    required MilestoneRepository milestoneRepository,
    required TaskRepository taskRepository,
    required RecurringTaskRepository recurringTaskRepository,
    RecurringTaskApplicationService? recurringTaskApplicationService,
  }) : _goalRepository = goalRepository,
       _milestoneRepository = milestoneRepository,
       _taskRepository = taskRepository,
       _recurringTaskRepository = recurringTaskRepository,
       _recurringTaskApplicationService =
           recurringTaskApplicationService ?? RecurringTaskApplicationService();

  final GoalRepository _goalRepository;
  final MilestoneRepository _milestoneRepository;
  final TaskRepository _taskRepository;
  final RecurringTaskRepository _recurringTaskRepository;
  final RecurringTaskApplicationService _recurringTaskApplicationService;

  Future<PlannerInitialState> initialize() async {
    final initialState = await _loadFromDatabase();

    final generatedTasks = _recurringTaskApplicationService
        .generateUpcomingOccurrences(
          rules: initialState.recurringRules,
          exceptions: initialState.recurringExceptions,
          existingTasks: initialState.tasks,
          today: todayDate(),
        );

    if (generatedTasks.isEmpty) {
      return initialState;
    }

    await _recurringTaskRepository.saveGeneratedOccurrences(generatedTasks);

    return PlannerInitialState(
      goals: initialState.goals,
      milestones: initialState.milestones,
      tasks: [...initialState.tasks, ...generatedTasks],
      recurringRules: initialState.recurringRules,
      recurringExceptions: initialState.recurringExceptions,
    );
  }

  Future<PlannerInitialState> _loadFromDatabase() async {
    final goals = await _goalRepository.loadGoals();
    final milestones = await _milestoneRepository.loadMilestones();
    final tasks = await _taskRepository.loadTasks();
    final recurringRules = await _recurringTaskRepository
        .loadRecurringTaskRules();
    final recurringExceptions = await _recurringTaskRepository
        .loadRecurringTaskExceptions();

    return PlannerInitialState(
      goals: goals,
      milestones: milestones,
      tasks: tasks,
      recurringRules: recurringRules,
      recurringExceptions: recurringExceptions,
    );
  }
}
