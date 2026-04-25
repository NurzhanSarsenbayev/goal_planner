import 'dart:async';

import 'package:flutter/material.dart';

import '../data/local/app_database.dart' as local;
import '../data/repositories/planner_repository.dart';
import '../models/goal.dart';
import '../screens/calendar_screen.dart';
import '../screens/goal_details_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/more_screen.dart';
import '../screens/today_screen.dart';
import '../state/planner_store.dart';
import '../widgets/add_goal_dialog.dart';
import '../widgets/add_task_dialog.dart';

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

  static const List<String> _titles = [
    'Today',
    'Goals',
    'Calendar',
    'More',
  ];

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
    final result = await showDialog<GoalDraft>(
      context: context,
      builder: (context) {
        return const AddGoalDialog();
      },
    );

    if (result == null) {
      return;
    }

    _store.addGoal(
      title: result.title,
      description: result.description,
    );
  }

  Future<void> _showAddStandaloneTaskDialog() async {
    final result = await showDialog<TaskDraft>(
      context: context,
      builder: (context) {
        return const AddTaskDialog();
      },
    );

    if (result == null) {
      return;
    }

    _store.addStandaloneTaskForToday(
      title: result.title,
      description: result.description,
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
            onTaskCreated: _store.addTask,
            onMilestoneCreated: _store.addMilestone,
            onScheduleTaskForToday: _store.scheduleTaskForToday,
            onDeleteTask: _store.deleteTask,
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
        onAddStandaloneTask: _showAddStandaloneTaskDialog,
        onDeleteTask: _store.deleteTask,
      ),
      GoalsScreen(
        goals: _store.goals,
        tasks: _store.tasks,
        onGoalSelected: _openGoalDetails,
        onAddGoal: _showAddGoalDialog,
      ),
      const CalendarScreen(),
      const MoreScreen(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _store.isInitialized
          ? screens[_selectedIndex]
          : const Center(
              child: CircularProgressIndicator(),
            ),
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