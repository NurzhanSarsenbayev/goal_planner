import 'package:flutter/material.dart';

import '../../domain/habit_entry_status.dart';

Future<HabitEntryStatus?> showHabitStatusBottomSheet({
  required BuildContext context,
  required HabitEntryStatus currentStatus,
}) {
  return showModalBottomSheet<HabitEntryStatus>(
    context: context,
    showDragHandle: true,
    builder: (context) {
      return HabitStatusBottomSheet(currentStatus: currentStatus);
    },
  );
}

class HabitStatusBottomSheet extends StatelessWidget {
  const HabitStatusBottomSheet({required this.currentStatus, super.key});

  final HabitEntryStatus currentStatus;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Mark habit',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _StatusActionButton(
                    label: 'Done',
                    icon: Icons.check,
                    status: HabitEntryStatus.done,
                    currentStatus: currentStatus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusActionButton(
                    label: 'No',
                    icon: Icons.close,
                    status: HabitEntryStatus.failed,
                    currentStatus: currentStatus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusActionButton(
                    label: 'Skip',
                    icon: Icons.do_not_disturb_on_outlined,
                    status: HabitEntryStatus.skipped,
                    currentStatus: currentStatus,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _StatusActionButton(
                    label: 'Clear',
                    icon: Icons.radio_button_unchecked,
                    status: HabitEntryStatus.none,
                    currentStatus: currentStatus,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StatusActionButton extends StatelessWidget {
  const _StatusActionButton({
    required this.label,
    required this.icon,
    required this.status,
    required this.currentStatus,
  });

  final String label;
  final IconData icon;
  final HabitEntryStatus status;
  final HabitEntryStatus currentStatus;

  bool get _isSelected => status == currentStatus;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: () {
        Navigator.of(context).pop(status);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: _isSelected
              ? colorScheme.primaryContainer
              : colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: _isSelected ? colorScheme.primary : Colors.transparent,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: _isSelected
                  ? colorScheme.onPrimaryContainer
                  : colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: _isSelected
                    ? colorScheme.onPrimaryContainer
                    : colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
