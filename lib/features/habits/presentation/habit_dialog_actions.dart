import 'package:flutter/material.dart';

import '../application/habit_store.dart';
import '../domain/habit.dart';
import '../domain/habit_entry_status.dart';
import 'widgets/add_habit_dialog.dart';
import 'widgets/habit_status_bottom_sheet.dart';
import 'widgets/archived_habits_bottom_sheet.dart';

class HabitDialogActions {
  const HabitDialogActions({required HabitStore habitStore})
    : _habitStore = habitStore;

  final HabitStore _habitStore;

  Future<void> showAddDialog(BuildContext context) async {
    final draft = await showDialog<AddHabitDraft>(
      context: context,
      builder: (context) {
        return const AddHabitDialog();
      },
    );

    if (!context.mounted || draft == null) {
      return;
    }

    await _habitStore.createHabit(
      title: draft.title,
      description: draft.description,
    );
  }

  Future<void> showEditDialog(BuildContext context, Habit habit) async {
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

    if (!context.mounted || draft == null) {
      return;
    }

    await _habitStore.updateHabit(
      habitId: habit.id,
      title: draft.title,
      description: draft.description,
    );
  }

  Future<void> showArchiveDialog(BuildContext context, Habit habit) async {
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

    if (!context.mounted || confirmed != true) {
      return;
    }

    await _habitStore.archiveHabit(habit.id);
  }

  Future<void> showDeleteDialog(BuildContext context, Habit habit) async {
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

    if (!context.mounted || confirmed != true) {
      return;
    }

    await _habitStore.deleteHabit(habit.id);
  }

  Future<void> showStatusSheet(
    BuildContext context, {
    required String habitId,
    required DateTime date,
    required HabitEntryStatus status,
  }) async {
    final selectedStatus = await showHabitStatusBottomSheet(
      context: context,
      currentStatus: status,
    );

    if (!context.mounted || selectedStatus == null) {
      return;
    }

    if (selectedStatus == HabitEntryStatus.none) {
      await _habitStore.clearEntry(habitId: habitId, date: date);

      return;
    }

    await _habitStore.markEntry(
      habitId: habitId,
      date: date,
      status: selectedStatus,
    );
  }

  Future<void> showArchivedHabitsSheet(BuildContext context) async {
    final archivedHabits = [
      for (final habit in _habitStore.habits)
        if (habit.isArchived) habit,
    ];

    final selection = await showArchivedHabitsBottomSheet(
      context: context,
      archivedHabits: archivedHabits,
    );

    if (!context.mounted || selection == null) {
      return;
    }

    switch (selection.action) {
      case ArchivedHabitAction.unarchive:
        await _habitStore.unarchiveHabit(selection.habit.id);
      case ArchivedHabitAction.delete:
        await showDeleteDialog(context, selection.habit);
    }
  }
}
