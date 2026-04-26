import 'dart:async';

import 'package:flutter/material.dart';

import '../data/local/app_database.dart' as local;
import '../data/repositories/planner_repository.dart';
import '../models/goal.dart';
import '../models/planner_task.dart';
import '../screens/calendar_screen.dart';
import '../screens/goal_details_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/all_tasks_screen.dart';
import '../screens/more_screen.dart';
import '../screens/today_screen.dart';
import '../state/planner_store.dart';
import 'app_dialogs.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  late final local.AppDatabase _database;
  late final PlannerRepository _repository;
  late final PlannerStore _store;

  int _selectedIndex = 0;

  static const List<String> _titles = ['Today', 'Goals', 'Calendar', 'More'];

  @override
  void initState() {
    super.initState();

    _database = local.AppDatabase();
    _repository = PlannerRepository(_database);
    _store = PlannerStore(_repository);

    _store.addListener(_onStoreChanged);
    unawaited(_store.initialize());
  }

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _store.dispose();
    unawaited(_database.close());

    super.dispose();
  }

  void _onStoreChanged() {
    setState(() {});
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Future<void> _showAddGoalDialog() async {
    final result = await showAddGoalDialog(context);

    if (result == null) {
      return;
    }

    _store.addGoal(title: result.title, description: result.description);
  }

  Future<void> _showEditGoalDialog(Goal goal) async {
    final result = await showEditGoalDialog(context, goal: goal);

    if (result == null) {
      return;
    }

    _store.updateGoal(
      goalId: goal.id,
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showDeleteGoalDialog(Goal goal) async {
    final milestoneCount = _store.milestones
        .where((milestone) => milestone.goalId == goal.id)
        .length;

    final taskCount = _store.tasks
        .where((task) => task.goalId == goal.id)
        .length;

    final shouldDelete = await showDeleteGoalDialog(
      context,
      goal: goal,
      milestoneCount: milestoneCount,
      taskCount: taskCount,
    );

    if (!shouldDelete) {
      return;
    }

    _store.deleteGoalWithRelatedData(goal.id);
  }

  Future<void> _showAddTodayTaskDialog() async {
    final result = await showAddTaskWithPlacementDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    _store.addTaskForToday(
      title: result.title,
      description: result.description,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  Future<void> _showAddTaskForDateDialog(DateTime scheduledDate) async {
    final result = await showAddTaskWithPlacementDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    _store.addTaskForDate(
      title: result.title,
      description: result.description,
      scheduledDate: scheduledDate,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  Future<void> _showAttachTaskToGoalDialog(PlannerTask task) async {
    final result = await showTaskPlacementDialog(
      context,
      goals: _store.goals,
      milestones: _store.milestones,
    );

    if (result == null) {
      return;
    }

    _store.attachTaskToGoal(
      taskId: task.id,
      goalId: result.goalId,
      milestoneId: result.milestoneId,
    );
  }

  Future<void> _showEditTaskDialog(PlannerTask task) async {
    final result = await showEditTaskDialog(context, task: task);

    if (result == null) {
      return;
    }

    _store.updateTask(
      taskId: task.id,
      title: result.title,
      description: result.description,
    );
  }

  void _openAllTasks() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return AllTasksScreen(
            goals: _store.goals,
            milestones: _store.milestones,
            tasks: _store.tasks,
            onToggleTaskCompleted: _store.toggleTaskCompleted,
            onTaskUpdated: _store.updateTask,
            onTaskAttachedToGoal: _store.attachTaskToGoal,
            onTaskDetachedFromGoal: _store.detachTaskFromGoal,
            onDeleteTask: _store.deleteTask,
            onScheduleTaskForToday: _store.scheduleTaskForToday,
            onScheduleTaskForDate: _store.scheduleTaskForDate,
          );
        },
      ),
    );
  }

  void _openGoalDetails(Goal goal) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) {
          return GoalDetailsScreen(
            goal: goal,
            milestones: _store.milestones,
            tasks: _store.tasks,
            onToggleTaskCompleted: _store.toggleTaskCompleted,
            onDeleteTask: _store.deleteTask,
            onTaskCreated: _store.addTask,
            onTaskUpdated: _store.updateTask,
            onTaskMovedToDirectGoal: _store.moveTaskToDirectGoal,
            onTaskAssignedToMilestone: _store.assignTaskToMilestone,
            onMilestoneCreated: _store.addMilestone,
            onMilestoneUpdated: _store.updateMilestone,
            onMilestoneDeletedAndTasksMovedToDirect:
                _store.deleteMilestoneAndMoveTasksToDirect,
            onMilestoneDeletedWithTasks: _store.deleteMilestoneWithTasks,
            onScheduleTaskForToday: _store.scheduleTaskForToday,
            onScheduleTaskForDate: _store.scheduleTaskForDate,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onToggleTaskCompleted: _store.toggleTaskCompleted,
        onEditTask: _showEditTaskDialog,
        onAttachTaskToGoal: _showAttachTaskToGoalDialog,
        onDetachTaskFromGoal: _store.detachTaskFromGoal,
        onRemoveTaskFromToday: _store.unscheduleTask,
        onScheduleTaskForDate: _store.scheduleTaskForDate,
        onDeleteTask: _store.deleteTask,
        onAddTask: _showAddTodayTaskDialog,
      ),
      GoalsScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onGoalSelected: _openGoalDetails,
        onEditGoal: _showEditGoalDialog,
        onDeleteGoal: _showDeleteGoalDialog,
        onAddGoal: _showAddGoalDialog,
      ),
      CalendarScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onToggleTaskCompleted: _store.toggleTaskCompleted,
        onEditTask: _showEditTaskDialog,
        onScheduleTaskForDate: _store.scheduleTaskForDate,
        onRemoveTaskFromSchedule: _store.unscheduleTask,
        onDeleteTask: _store.deleteTask,
        onAddTaskForDate: _showAddTaskForDateDialog,
      ),
      MoreScreen(onOpenAllTasks: _openAllTasks),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(_titles[_selectedIndex])),
      body: _store.isInitialized
          ? screens[_selectedIndex]
          : const Center(child: CircularProgressIndicator()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: _onDestinationSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.today_outlined),
            selectedIcon: Icon(Icons.today),
            label: 'Today',
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: 'Goals',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.more_horiz),
            selectedIcon: Icon(Icons.more),
            label: 'More',
          ),
        ],
      ),
    );
  }
}
