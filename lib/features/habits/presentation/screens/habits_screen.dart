import 'package:flutter/material.dart';

import '../../application/habit_store.dart';
import '../habit_dialog_actions.dart';
import '../widgets/habit_presentation_callbacks.dart';
import '../widgets/habit_week_grid.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({required this.habitStore, super.key});

  final HabitStore habitStore;

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  late final HabitDialogActions _habitDialogActions;

  @override
  void initState() {
    super.initState();

    _habitDialogActions = HabitDialogActions(habitStore: widget.habitStore);
    widget.habitStore.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.habitStore,
      builder: (context, _) {
        final habitStore = widget.habitStore;

        return Scaffold(
          appBar: AppBar(title: const Text('Habits')),
          body: _HabitsBody(
            habitStore: habitStore,
            onCellTap: ({required habitId, required date, required status}) {
              return _habitDialogActions.showStatusSheet(
                context,
                habitId: habitId,
                date: date,
                status: status,
              );
            },
            onEditHabit: (habit) {
              return _habitDialogActions.showEditDialog(context, habit);
            },
            onArchiveHabit: (habit) {
              return _habitDialogActions.showArchiveDialog(context, habit);
            },
            onDeleteHabit: (habit) {
              return _habitDialogActions.showDeleteDialog(context, habit);
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              _habitDialogActions.showAddDialog(context);
            },
            icon: const Icon(Icons.add),
            label: const Text('Habit'),
          ),
        );
      },
    );
  }
}

class _HabitsBody extends StatelessWidget {
  const _HabitsBody({
    required this.habitStore,
    required this.onCellTap,
    required this.onEditHabit,
    required this.onArchiveHabit,
    required this.onDeleteHabit,
  });

  final HabitStore habitStore;
  final HabitCellTapCallback onCellTap;
  final HabitActionCallback onEditHabit;
  final HabitActionCallback onArchiveHabit;
  final HabitActionCallback onDeleteHabit;

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

    return HabitWeekGrid(
      weekView: habitStore.weekView,
      isLoading: habitStore.isLoading,
      onPreviousWeek: () {
        habitStore.goToPreviousWeek();
      },
      onNextWeek: () {
        habitStore.goToNextWeek();
      },
      onCurrentWeek: () {
        habitStore.goToCurrentWeek();
      },
      onCellTap: onCellTap,
      onEditHabit: onEditHabit,
      onArchiveHabit: onArchiveHabit,
      onDeleteHabit: onDeleteHabit,
    );
  }
}
