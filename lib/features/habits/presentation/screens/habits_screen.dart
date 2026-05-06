import 'package:flutter/material.dart';

import '../../application/habit_store.dart';
import '../habit_dialog_actions.dart';
import '../widgets/habit_presentation_callbacks.dart';
import '../widgets/habit_week_grid.dart';
import '../widgets/habits_empty_state.dart';

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
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.habitStore,
      builder: (context, _) {
        final habitStore = widget.habitStore;
        final hasArchivedHabits = habitStore.habits.any(
          (habit) => habit.isArchived,
        );

        return Scaffold(
          appBar: AppBar(
            title: const Text('Habits'),
            actions: [
              if (hasArchivedHabits)
                IconButton(
                  tooltip: 'Archived habits',
                  onPressed: () {
                    _habitDialogActions.showArchivedHabitsSheet(context);
                  },
                  icon: const Icon(Icons.archive_outlined),
                ),
            ],
          ),
          body: _HabitsBody(
            habitStore: habitStore,
            onCreateHabit: () {
              return _habitDialogActions.showAddDialog(context);
            },
            onViewArchivedHabits: () {
              return _habitDialogActions.showArchivedHabitsSheet(context);
            },
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
    required this.onCreateHabit,
    required this.onCellTap,
    required this.onEditHabit,
    required this.onArchiveHabit,
    required this.onDeleteHabit,
    required this.onViewArchivedHabits,
  });

  final HabitStore habitStore;
  final Future<void> Function() onCreateHabit;
  final Future<void> Function() onViewArchivedHabits;
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
      return HabitsEmptyState(onCreateHabit: onCreateHabit);
    }

    final activeHabits = [
      for (final habit in habitStore.habits)
        if (!habit.isArchived) habit,
    ];

    if (activeHabits.isEmpty) {
      return HabitsEmptyState(
        title: 'All habits are archived',
        description: 'Create a new habit or restore an archived one.',
        buttonLabel: 'Create new habit',
        secondaryButtonLabel: 'View archived habits',
        icon: Icons.archive_outlined,
        showExamples: false,
        onCreateHabit: onCreateHabit,
        onSecondaryAction: onViewArchivedHabits,
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
