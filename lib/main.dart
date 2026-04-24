import 'package:flutter/material.dart';

import 'data/sample_data.dart';
import 'models/goal.dart';
import 'models/planner_task.dart';

void main() {
  runApp(const GoalPlannerApp());
}

class GoalPlannerApp extends StatelessWidget {
  const GoalPlannerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Goal Planner',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}

class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _selectedIndex = 0;

  static const List<Widget> _screens = [
    TodayScreen(),
    GoalsScreen(),
    CalendarScreen(),
    MoreScreen(),
  ];

  static const List<String> _titles = [
    'Today',
    'Goals',
    'Calendar',
    'More',
  ];

  void _onDestinationSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_titles[_selectedIndex]),
      ),
      body: _screens[_selectedIndex],
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

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final todayTasks = sampleTasks
        .where((task) => task.isScheduledForToday)
        .toList();

    if (todayTasks.isEmpty) {
      return const PlaceholderScreen(
        title: 'Today',
        description: 'No tasks scheduled for today yet.',
        icon: Icons.today,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: todayTasks.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final task = todayTasks[index];
        final goal = _findGoalById(task.goalId);

        return TaskCard(
          task: task,
          goal: goal,
        );
      },
    );
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in sampleGoals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}

class GoalsScreen extends StatelessWidget {
  const GoalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    if (sampleGoals.isEmpty) {
      return const PlaceholderScreen(
        title: 'Goals',
        description: 'No goals yet. Create your first long-term goal.',
        icon: Icons.flag,
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: sampleGoals.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final goal = sampleGoals[index];
        final goalTasks = sampleTasks
            .where((task) => task.goalId == goal.id)
            .toList();

        final completedTasks = goalTasks
            .where((task) => task.isCompleted)
            .length;

        return GoalCard(
          goal: goal,
          totalTasks: goalTasks.length,
          completedTasks: completedTasks,
        );
      },
    );
  }
}

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'Calendar',
      description: 'Calendar will show tasks and plans by date.',
      icon: Icons.calendar_month,
    );
  }
}

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const PlaceholderScreen(
      title: 'More',
      description: 'More will contain reports, checklists, settings, and later features.',
      icon: Icons.more_horiz,
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.description,
    required this.icon,
  });

  final String title;
  final String description;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  const TaskCard({
    super.key,
    required this.task,
    required this.goal,
  });

  final PlannerTask task;
  final Goal? goal;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        leading: Icon(
          task.isCompleted
              ? Icons.check_circle
              : Icons.radio_button_unchecked,
        ),
        title: Text(task.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (task.description.isNotEmpty) Text(task.description),
            if (goal != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  'Goal: ${goal!.title}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class GoalCard extends StatelessWidget {
  const GoalCard({
    super.key,
    required this.goal,
    required this.totalTasks,
    required this.completedTasks,
  });

  final Goal goal;
  final int totalTasks;
  final int completedTasks;

  @override
  Widget build(BuildContext context) {
    final progressText = totalTasks == 0
        ? 'No tasks yet'
        : '$completedTasks / $totalTasks tasks completed';

    return Card(
      child: ListTile(
        leading: const Icon(Icons.flag_outlined),
        title: Text(goal.title),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (goal.description.isNotEmpty) Text(goal.description),
            const SizedBox(height: 4),
            Text(
              progressText,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
    );
  }
}