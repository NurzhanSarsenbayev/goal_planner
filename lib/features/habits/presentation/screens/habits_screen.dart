import 'package:flutter/material.dart';

import '../../application/habit_store.dart';
import '../../domain/habit_entry_status.dart';
import '../../domain/habit.dart';
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

  Future<void> _showEditHabitDialog(Habit habit) async {
    final draft = await showDialog<AddHabitDraft>(
      context: context,
      builder: (context) {
        return AddHabitDialog(
          initialTitle: habit.title,
          initialDescription: habit.description,
          dialogTitle: 'Edit habit',
          actionLabel: 'Save',
        );
      },
    );

    if (!mounted || draft == null) {
      return;
    }

    await widget.habitStore.updateHabit(
      habitId: habit.id,
      title: draft.title,
      description: draft.description,
    );
  }

  Future<void> _archiveHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Archive habit?'),
          content: Text(
            '“${habit.title}” will be hidden from the active habit list.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Archive'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await widget.habitStore.archiveHabit(habit.id);
  }

  Future<void> _deleteHabit(Habit habit) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete habit?'),
          content: Text(
            '“${habit.title}” and its tracked entries will be deleted.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirmed != true) {
      return;
    }

    await widget.habitStore.deleteHabit(habit.id);
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
            onEditHabit: _showEditHabitDialog,
            onArchiveHabit: _archiveHabit,
            onDeleteHabit: _deleteHabit,
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
