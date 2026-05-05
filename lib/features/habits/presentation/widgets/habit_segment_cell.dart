import 'package:flutter/material.dart';

import '../../domain/habit_entry_status.dart';

class HabitSegmentCell extends StatelessWidget {
  const HabitSegmentCell({
    required this.status,
    required this.borderRadius,
    required this.onTap,
    super.key,
  });

  final HabitEntryStatus status;
  final BorderRadius borderRadius;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: _backgroundColor(colorScheme),
      borderRadius: borderRadius,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: onTap,
        child: SizedBox(
          height: 42,
          child: Center(
            child: _icon == null
                ? null
                : Icon(_icon, size: 20, color: _foregroundColor(colorScheme)),
          ),
        ),
      ),
    );
  }

  Color _backgroundColor(ColorScheme colorScheme) {
    return switch (status) {
      HabitEntryStatus.none => colorScheme.surfaceContainerHighest,
      HabitEntryStatus.done => colorScheme.primary,
      HabitEntryStatus.incomplete => colorScheme.secondaryContainer,
      HabitEntryStatus.failed => colorScheme.errorContainer,
      HabitEntryStatus.skipped => colorScheme.surfaceContainerHigh,
    };
  }

  Color _foregroundColor(ColorScheme colorScheme) {
    return switch (status) {
      HabitEntryStatus.done => colorScheme.onPrimary,
      HabitEntryStatus.failed => colorScheme.onErrorContainer,
      HabitEntryStatus.incomplete => colorScheme.onSecondaryContainer,
      HabitEntryStatus.skipped => colorScheme.onSurfaceVariant,
      HabitEntryStatus.none => colorScheme.onSurfaceVariant,
    };
  }

  IconData? get _icon {
    return switch (status) {
      HabitEntryStatus.none => null,
      HabitEntryStatus.done => Icons.check,
      HabitEntryStatus.incomplete => Icons.remove,
      HabitEntryStatus.failed => Icons.close,
      HabitEntryStatus.skipped => Icons.do_not_disturb_on_outlined,
    };
  }
}
