import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/planner_task.dart';

Future<void> showTaskEditActionsSheet(
  BuildContext context, {
  required PlannerTask task,
  required VoidCallback onEdit,
  required VoidCallback onDelete,
  VoidCallback? onAttachToGoal,
  VoidCallback? onDetachFromGoal,
  VoidCallback? onMoveToMilestone,
  VoidCallback? onMoveToDirectGoal,
  VoidCallback? onScheduleDate,
  VoidCallback? onScheduleTime,
  VoidCallback? onClearScheduledTime,
  VoidCallback? onRemoveFromToday,
  VoidCallback? onUnschedule,
  VoidCallback? onEditReminder,
  VoidCallback? onEditRecurringSeries,
  VoidCallback? onDeleteRecurringSeries,
}) async {
  final l10n = AppLocalizations.of(context);
  final isRecurringOccurrence = task.recurringRuleId != null;
  final shouldShowWholeSeries =
      isRecurringOccurrence &&
      (onEditRecurringSeries != null || onDeleteRecurringSeries != null);

  final shouldShowScheduleDate = onScheduleDate != null;
  final shouldShowRemoveFromToday = onRemoveFromToday != null;
  final shouldShowUnschedule = onUnschedule != null;
  final shouldShowScheduleTime =
      onScheduleTime != null && task.scheduledDate != null;
  final shouldShowClearScheduledTime =
      onClearScheduledTime != null && task.scheduledTimeMinutes != null;
  final shouldShowAttachToGoal = onAttachToGoal != null;
  final shouldShowDetachFromGoal = onDetachFromGoal != null;
  final shouldShowMoveToMilestone = onMoveToMilestone != null;
  final shouldShowMoveToDirectGoal = onMoveToDirectGoal != null;
  final shouldShowEditReminder =
      onEditReminder != null && task.scheduledTimeMinutes != null;

  await showModalBottomSheet<void>(
    context: context,
    builder: (sheetContext) {
      return SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _TaskEditActionsHeader(
                title: isRecurringOccurrence
                    ? l10n.taskEditActionsRecurringSheetTitle
                    : l10n.taskEditActionsSheetTitle,
              ),
              if (isRecurringOccurrence)
                _TaskEditActionsSectionHeader(
                  title: l10n.taskEditActionsOnlyThisTaskSection,
                ),
              _TaskEditActionTile(
                icon: Icons.edit_outlined,
                title: l10n.taskEditActionTitleAndDescription,
                onTap: () {
                  _runAfterClosingSheet(sheetContext, onEdit);
                },
              ),
              if (shouldShowScheduleDate)
                _TaskEditActionTile(
                  icon: Icons.event_outlined,
                  title: l10n.taskActionScheduleDate,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onScheduleDate);
                  },
                ),
              if (shouldShowScheduleTime)
                _TaskEditActionTile(
                  icon: Icons.schedule,
                  title: task.scheduledTimeMinutes == null
                      ? l10n.taskActionSetTime
                      : l10n.taskActionChangeTime,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onScheduleTime);
                  },
                ),
              if (shouldShowEditReminder)
                _TaskEditActionTile(
                  icon: Icons.notifications_outlined,
                  title: l10n.taskReminderFieldLabel,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onEditReminder);
                  },
                ),
              if (shouldShowClearScheduledTime)
                _TaskEditActionTile(
                  icon: Icons.schedule_send_outlined,
                  title: l10n.taskActionClearTime,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onClearScheduledTime);
                  },
                ),
              if (shouldShowRemoveFromToday)
                _TaskEditActionTile(
                  icon: Icons.today_outlined,
                  title: l10n.taskActionRemoveFromToday,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onRemoveFromToday);
                  },
                ),
              if (shouldShowUnschedule)
                _TaskEditActionTile(
                  icon: Icons.event_busy_outlined,
                  title: l10n.taskActionRemoveScheduledDate,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onUnschedule);
                  },
                ),
              if (shouldShowAttachToGoal)
                _TaskEditActionTile(
                  icon: Icons.flag_outlined,
                  title: l10n.taskActionAttachToGoal,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onAttachToGoal);
                  },
                ),
              if (shouldShowDetachFromGoal)
                _TaskEditActionTile(
                  icon: Icons.link_off,
                  title: l10n.taskActionDetachFromGoal,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onDetachFromGoal);
                  },
                ),
              if (shouldShowMoveToMilestone)
                _TaskEditActionTile(
                  icon: Icons.account_tree_outlined,
                  title: l10n.taskActionMoveToMilestone,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onMoveToMilestone);
                  },
                ),
              if (shouldShowMoveToDirectGoal)
                _TaskEditActionTile(
                  icon: Icons.low_priority_outlined,
                  title: l10n.taskActionMoveToDirectGoal,
                  onTap: () {
                    _runAfterClosingSheet(sheetContext, onMoveToDirectGoal);
                  },
                ),
              const Divider(height: 1),
              _TaskEditActionTile(
                icon: Icons.delete_outline,
                title: isRecurringOccurrence
                    ? l10n.taskEditActionDeleteThisTask
                    : l10n.commonDelete,
                onTap: () {
                  _runAfterClosingSheet(sheetContext, onDelete);
                },
              ),
              if (shouldShowWholeSeries) ...[
                const Divider(height: 1),
                _TaskEditActionsSectionHeader(
                  title: l10n.taskEditActionsWholeSeriesSection,
                ),
                if (onEditRecurringSeries != null)
                  _TaskEditActionTile(
                    icon: Icons.repeat,
                    title: l10n.taskEditActionEditSeries,
                    onTap: () {
                      _runAfterClosingSheet(
                        sheetContext,
                        onEditRecurringSeries,
                      );
                    },
                  ),
                if (onDeleteRecurringSeries != null)
                  _TaskEditActionTile(
                    icon: Icons.delete_forever_outlined,
                    title: l10n.taskEditActionDeleteSeries,
                    onTap: () {
                      _runAfterClosingSheet(
                        sheetContext,
                        onDeleteRecurringSeries,
                      );
                    },
                  ),
              ],
            ],
          ),
        ),
      );
    },
  );
}

void _runAfterClosingSheet(BuildContext context, VoidCallback action) {
  Navigator.of(context).pop();

  WidgetsBinding.instance.addPostFrameCallback((_) {
    action();
  });
}

class _TaskEditActionsHeader extends StatelessWidget {
  const _TaskEditActionsHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 8),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}

class _TaskEditActionsSectionHeader extends StatelessWidget {
  const _TaskEditActionsSectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: Theme.of(context).textTheme.labelLarge?.copyWith(
            color: Theme.of(context).colorScheme.primary,
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}

class _TaskEditActionTile extends StatelessWidget {
  const _TaskEditActionTile({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return ListTile(leading: Icon(icon), title: Text(title), onTap: onTap);
  }
}
