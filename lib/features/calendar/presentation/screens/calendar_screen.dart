import 'package:flutter/material.dart';

import '../../../../l10n/app_localizations.dart';
import '../../../../models/goal.dart';
import '../../../../models/planner_task.dart';
import '../../../../shared/planner_dates.dart';
import '../../../tasks/presentation/task_date_dialogs.dart';
import '../../../tasks/presentation/task_schedule_dialog_actions.dart';
import '../../../tasks/presentation/widgets/task_card.dart';
import '../../application/calendar_task_view_builder.dart';
import '../widgets/calendar_month_grid.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onCompleteTaskOnDate,
    required this.onEditTask,
    required this.onScheduleTaskForDate,
    required this.onScheduleTaskForDateAndTime,
    required this.onUpdateTaskReminder,
    required this.onRemoveTaskFromSchedule,
    required this.onDeleteTask,
    required this.onAddTaskForDate,
    required this.onEnsureRecurringTasksForMonth,
    required this.onAddRecurringTaskForDate,
    required this.onEditRecurringTaskRule,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;
  final void Function(PlannerTask task) onEditTask;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function({
    required String taskId,
    required DateTime scheduledDate,
    required int? scheduledTimeMinutes,
  })
  onScheduleTaskForDateAndTime;
  final void Function({
    required String taskId,
    required int? reminderMinutesBefore,
  })
  onUpdateTaskReminder;
  final void Function(String taskId) onRemoveTaskFromSchedule;
  final void Function(String taskId) onDeleteTask;
  final void Function(DateTime date) onAddTaskForDate;
  final void Function(DateTime visibleMonth) onEnsureRecurringTasksForMonth;
  final void Function(DateTime date) onAddRecurringTaskForDate;
  final void Function(String ruleId) onEditRecurringTaskRule;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  final CalendarTaskViewBuilder _taskViewBuilder =
      const CalendarTaskViewBuilder();

  final TaskScheduleDialogActions _taskScheduleDialogActions =
      const TaskScheduleDialogActions();

  @override
  void initState() {
    super.initState();

    final today = todayDate();
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDate = today;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      widget.onEnsureRecurringTasksForMonth(_visibleMonth);
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);

    final selectedDateTasks = _taskViewBuilder.tasksForDate(
      tasks: widget.tasks,
      date: _selectedDate,
    );
    final datesWithTasks = _taskViewBuilder.datesWithTasks(widget.tasks);

    return Stack(
      children: [
        ListView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
          children: [
            CalendarMonthGrid(
              visibleMonth: _visibleMonth,
              selectedDate: _selectedDate,
              datesWithTasks: datesWithTasks,
              onPreviousMonth: _showPreviousMonth,
              onNextMonth: _showNextMonth,
              onSelectDate: _selectDate,
            ),
            const SizedBox(height: 24),
            Text(
              _selectedDateTitle(l10n, _selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (selectedDateTasks.isEmpty)
              Text(
                l10n.calendarNoTasksForDay,
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final task in selectedDateTasks) ...[
                TaskCard(
                  task: task,
                  goal: _taskViewBuilder.findGoalById(
                    goals: widget.goals,
                    goalId: task.goalId,
                  ),
                  onToggleCompleted: () {
                    handleTaskCompletionWithDateFlow(
                      context,
                      task: task,
                      onToggleTaskCompleted: widget.onToggleTaskCompleted,
                      onCompleteTaskOnDate: widget.onCompleteTaskOnDate,
                    );
                  },
                  onEdit: () {
                    widget.onEditTask(task);
                  },
                  onEditRecurringSeries: task.recurringRuleId == null
                      ? null
                      : () {
                          widget.onEditRecurringTaskRule(task.recurringRuleId!);
                        },
                  onScheduleDate: () {
                    _taskScheduleDialogActions.showScheduleDatePicker(
                      context,
                      task: task,
                      onScheduleTaskForDate: widget.onScheduleTaskForDate,
                    );
                  },
                  onUnschedule: () {
                    widget.onRemoveTaskFromSchedule(task.id);
                  },
                  onScheduleTime:
                      TaskScheduleDialogActions.canEditScheduleTime(task)
                      ? () {
                          _taskScheduleDialogActions.showScheduleTimePicker(
                            context,
                            task: task,
                            onScheduleTaskForDateAndTime:
                                widget.onScheduleTaskForDateAndTime,
                          );
                        }
                      : null,
                  onClearScheduledTime:
                      TaskScheduleDialogActions.canEditScheduleTime(task) &&
                          task.scheduledTimeMinutes != null
                      ? () {
                          _taskScheduleDialogActions.clearScheduledTime(
                            task,
                            onScheduleTaskForDateAndTime:
                                widget.onScheduleTaskForDateAndTime,
                          );
                        }
                      : null,
                  onEditReminder:
                      TaskScheduleDialogActions.canEditReminder(task)
                      ? () {
                          _taskScheduleDialogActions.showReminderPicker(
                            context,
                            task: task,
                            onUpdateTaskReminder: widget.onUpdateTaskReminder,
                          );
                        }
                      : null,
                  onDelete: () {
                    widget.onDeleteTask(task.id);
                  },
                ),
                const SizedBox(height: 8),
              ],
          ],
        ),
        Positioned(
          right: 16,
          bottom: 16,
          child: FloatingActionButton.extended(
            onPressed: () {
              _showAddActionSheet(context);
            },
            icon: const Icon(Icons.add),
            label: Text(l10n.calendarAddButton),
          ),
        ),
      ],
    );
  }

  void _showPreviousMonth() {
    final previousMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);

    setState(() {
      _visibleMonth = previousMonth;
    });

    widget.onEnsureRecurringTasksForMonth(previousMonth);
  }

  void _showNextMonth() {
    final nextMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);

    setState(() {
      _visibleMonth = nextMonth;
    });

    widget.onEnsureRecurringTasksForMonth(nextMonth);
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = dateOnly(date);
    });
  }

  Future<void> _showAddActionSheet(BuildContext context) async {
    final l10n = AppLocalizations.of(context);
    final selectedDateText = formatPlannerDate(_selectedDate);
    final isPastDate = dateOnly(_selectedDate).isBefore(todayDate());

    final selectedAction = await showModalBottomSheet<_CalendarAddAction>(
      context: context,
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (isPastDate)
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(Icons.history),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              l10n.calendarPastDateWarning(selectedDateText),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: Text(l10n.calendarOneTimeTaskTitle),
                subtitle: Text(
                  l10n.calendarOneTimeTaskSubtitle(selectedDateText),
                ),
                onTap: () {
                  Navigator.of(context).pop(_CalendarAddAction.oneTimeTask);
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: Text(l10n.calendarRecurringTaskTitle),
                subtitle: Text(
                  l10n.calendarRecurringTaskSubtitle(selectedDateText),
                ),
                onTap: () {
                  Navigator.of(context).pop(_CalendarAddAction.recurringTask);
                },
              ),
            ],
          ),
        );
      },
    );

    if (selectedAction == _CalendarAddAction.oneTimeTask) {
      widget.onAddTaskForDate(_selectedDate);
      return;
    }

    if (selectedAction == _CalendarAddAction.recurringTask) {
      widget.onAddRecurringTaskForDate(_selectedDate);
    }
  }

  String _selectedDateTitle(AppLocalizations l10n, DateTime date) {
    return l10n.calendarSelectedDayTitle(_dateGroupTitle(l10n, date));
  }

  String _dateGroupTitle(AppLocalizations l10n, DateTime date) {
    final normalizedDate = dateOnly(date);
    final today = todayDate();
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    if (normalizedDate == today) {
      return l10n.calendarDateToday;
    }

    if (normalizedDate == tomorrow) {
      return l10n.calendarDateTomorrow;
    }

    if (normalizedDate == yesterday) {
      return l10n.calendarDateYesterday;
    }

    return formatPlannerDate(normalizedDate);
  }
}

enum _CalendarAddAction { oneTimeTask, recurringTask }
