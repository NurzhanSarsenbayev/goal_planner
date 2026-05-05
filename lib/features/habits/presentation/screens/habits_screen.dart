import 'package:flutter/material.dart';

import '../../application/habit_store.dart';
import '../../domain/habit_entry_status.dart';
import '../widgets/add_habit_dialog.dart';
import '../widgets/habit_week_grid.dart';
import '../widgets/habit_status_bottom_sheet.dart';

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

  Future<void> _showHabitStatusSheet({
    required String habitId,
    required DateTime date,
    required HabitEntryStatus status,
  }) async {
    final selectedStatus = await showHabitStatusBottomSheet(
      context: context,
      currentStatus: status,
    );

    if (!mounted || selectedStatus == null) {
      return;
    }

    if (selectedStatus == HabitEntryStatus.none) {
      await widget.habitStore.clearEntry(habitId: habitId, date: date);

      return;
    }

    await widget.habitStore.markEntry(
      habitId: habitId,
      date: date,
      status: selectedStatus,
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
          body: _HabitsBody(
            habitStore: habitStore,
            onCellTap: _showHabitStatusSheet,
          ),
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
  const _HabitsBody({required this.habitStore, required this.onCellTap});

  final HabitStore habitStore;
  final HabitCellTapCallback onCellTap;

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
    );
  }
}
