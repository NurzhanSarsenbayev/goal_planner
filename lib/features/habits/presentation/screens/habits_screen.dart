import 'package:flutter/material.dart';

import '../../application/habit_store.dart';
import '../widgets/add_habit_dialog.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({required this.habitStore, super.key});

  final HabitStore habitStore;

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  @override
  void initState() {
    super.initState();
    widget.habitStore.initialize();
  }

  Future<void> _showAddHabitDialog() async {
    final draft = await showDialog<AddHabitDraft>(
      context: context,
      builder: (context) {
        return const AddHabitDialog();
      },
    );

    if (!mounted || draft == null) {
      return;
    }

    await widget.habitStore.createHabit(
      title: draft.title,
      description: draft.description,
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.habitStore,
      builder: (context, _) {
        final habitStore = widget.habitStore;

        return Scaffold(
          appBar: AppBar(title: const Text('Habits')),
          body: _HabitsBody(habitStore: habitStore),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: _showAddHabitDialog,
            icon: const Icon(Icons.add),
            label: const Text('Habit'),
          ),
        );
      },
    );
  }
}

class _HabitsBody extends StatelessWidget {
  const _HabitsBody({required this.habitStore});

  final HabitStore habitStore;

  @override
  Widget build(BuildContext context) {
    if (habitStore.isLoading && !habitStore.isInitialized) {
      return const Center(child: CircularProgressIndicator());
    }

    if (habitStore.habits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text(
            'No habits yet.\nCreate your first habit soon.',
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    final activeHabits = [
      for (final habit in habitStore.habits)
        if (!habit.isArchived) habit,
    ];

    if (activeHabits.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Text('All habits are archived.', textAlign: TextAlign.center),
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: activeHabits.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final habit = activeHabits[index];

        return Card(
          child: ListTile(
            title: Text(habit.title),
            subtitle: habit.description.isEmpty
                ? null
                : Text(habit.description),
          ),
        );
      },
    );
  }
}
