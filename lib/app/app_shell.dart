import 'package:flutter/material.dart';

import '../data/sample_data.dart';
import '../models/goal.dart';
import '../models/planner_task.dart';
import '../screens/calendar_screen.dart';
import '../screens/goal_details_screen.dart';
import '../screens/goals_screen.dart';
import '../screens/more_screen.dart';
import '../screens/today_screen.dart';
import '../widgets/add_goal_dialog.dart';

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  late List<Goal> _goals;
  late List<PlannerTask> _tasks;

  static const List<String> _titles = [
    'Today',
    'Goals',
    'Calendar',
    'More',
  ];

  @override
  void initState() {
    super.initState();
    _goals = List.of(sampleGoals);
    _tasks = List.of(sampleTasks);
  }

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  void _toggleTaskCompleted(String taskId) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        final nextCompletedState = !task.isCompleted;

        return task.copyWith(
          isCompleted: nextCompletedState,
          completedAt: nextCompletedState ? DateTime.now() : null,
        );
      }).toList();
    });
  }

  void _addTask(PlannerTask task) {
    setState(() {
      _tasks = [..._tasks, task];
    });
  }

  void _scheduleTaskForToday(String taskId) {
    setState(() {
      _tasks = _tasks.map((task) {
        if (task.id != taskId) {
          return task;
        }

        return task.scheduledToday();
      }).toList();
    });
  }

  void _addGoal({
    required String title,
    required String description,
  }) {
    final now = DateTime.now();

    final goal = Goal(
      id: 'goal_${now.microsecondsSinceEpoch}',
      title: title,
      description: description,
      status: GoalStatus.active,
      createdAt: now,
    );

    setState(() {
      _goals = [..._goals, goal];
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

    _addGoal(
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
            tasks: _tasks,
            onToggleTaskCompleted: _toggleTaskCompleted,
            onTaskCreated: _addTask,
            onScheduleTaskForToday: _scheduleTaskForToday,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screens = [
      TodayScreen(
        goals: _goals,
        tasks: _tasks,
        onToggleTaskCompleted: _toggleTaskCompleted,
      ),
      GoalsScreen(
        goals: _goals,
        tasks: _tasks,
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
      body: screens[_selectedIndex],
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