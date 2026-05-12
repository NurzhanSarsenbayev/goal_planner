import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../domain/habit.dart';

Future<ArchivedHabitSelection?> showArchivedHabitsBottomSheet({
  required BuildContext context,
  required List<Habit> archivedHabits,
}) {
  return showModalBottomSheet<ArchivedHabitSelection>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return ArchivedHabitsBottomSheet(archivedHabits: archivedHabits);
    },
  );
}

enum ArchivedHabitAction { unarchive, delete }

class ArchivedHabitSelection {
  const ArchivedHabitSelection({required this.habit, required this.action});

  final Habit habit;
  final ArchivedHabitAction action;
}

class ArchivedHabitsBottomSheet extends StatelessWidget {
  const ArchivedHabitsBottomSheet({required this.archivedHabits, super.key});

  final List<Habit> archivedHabits;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return SafeArea(
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.archivedHabitsTitle,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              if (archivedHabits.isEmpty)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Text(l10n.archivedHabitsEmpty),
                )
              else
                Flexible(
                  child: ListView.separated(
                    shrinkWrap: true,
                    itemCount: archivedHabits.length,
                    separatorBuilder: (_, _) {
                      return const Divider(height: 1);
                    },
                    itemBuilder: (context, index) {
                      final habit = archivedHabits[index];

                      return _ArchivedHabitTile(habit: habit);
                    },
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ArchivedHabitTile extends StatelessWidget {
  const _ArchivedHabitTile({required this.habit});

  final Habit habit;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(habit.title, maxLines: 1, overflow: TextOverflow.ellipsis),
      subtitle: habit.description.isEmpty
          ? null
          : Text(
              habit.description,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            tooltip: l10n.archivedHabitRestoreTooltip,
            onPressed: () {
              Navigator.of(context).pop(
                ArchivedHabitSelection(
                  habit: habit,
                  action: ArchivedHabitAction.unarchive,
                ),
              );
            },
            icon: const Icon(Icons.unarchive_outlined),
          ),
          IconButton(
            tooltip: l10n.archivedHabitDeleteTooltip,
            onPressed: () {
              Navigator.of(context).pop(
                ArchivedHabitSelection(
                  habit: habit,
                  action: ArchivedHabitAction.delete,
                ),
              );
            },
            icon: const Icon(Icons.delete_outline),
          ),
        ],
      ),
    );
  }
}
