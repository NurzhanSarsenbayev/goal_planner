import 'package:flutter/material.dart';

import '../app/app_dialogs.dart';
import '../models/goal.dart';
import '../models/planner_task.dart';
import '../shared/planner_dates.dart';
import '../widgets/tasks/task_card.dart';
import '../widgets/calendar/calendar_month_grid.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onCompleteTaskOnDate,
    required this.onEditTask,
    required this.onScheduleTaskForDate,
    required this.onRemoveTaskFromSchedule,
    required this.onDeleteTask,
    required this.onAddTaskForDate,
    required this.onEnsureRecurringTasksForMonth,
    required this.onAddRecurringTaskForDate,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function({required String taskId, required DateTime completedAt})
  onCompleteTaskOnDate;
  final void Function(PlannerTask task) onEditTask;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function(String taskId) onRemoveTaskFromSchedule;
  final void Function(String taskId) onDeleteTask;
  final void Function(DateTime date) onAddTaskForDate;
  final void Function(DateTime visibleMonth) onEnsureRecurringTasksForMonth;
  final void Function(DateTime date) onAddRecurringTaskForDate;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

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
    final selectedDateTasks = _tasksForDate(_selectedDate);
    final datesWithTasks = _datesWithTasks(widget.tasks);

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
              _selectedDateTitle(_selectedDate),
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            if (selectedDateTasks.isEmpty)
              Text(
                'No tasks scheduled for this day.',
                style: Theme.of(context).textTheme.bodyMedium,
              )
            else
              for (final task in selectedDateTasks) ...[
                TaskCard(
                  task: task,
                  goal: _findGoalById(task.goalId),
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
                  onScheduleDate: () {
                    _showScheduleTaskDatePicker(context, task);
                  },
                  onUnschedule: () {
                    widget.onRemoveTaskFromSchedule(task.id);
                  },
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
            label: const Text('Add'),
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
                              'You are creating a task for a past date: '
                              '${formatPlannerDate(_selectedDate)}.',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ListTile(
                leading: const Icon(Icons.check_circle_outline),
                title: const Text('One-time task'),
                subtitle: Text(
                  'Create a task for ${formatPlannerDate(_selectedDate)}',
                ),
                onTap: () {
                  Navigator.of(context).pop(_CalendarAddAction.oneTimeTask);
                },
              ),
              ListTile(
                leading: const Icon(Icons.repeat),
                title: const Text('Recurring task'),
                subtitle: Text(
                  'Create a repeating task starting ${formatPlannerDate(_selectedDate)}',
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

  Future<void> _showScheduleTaskDatePicker(
    BuildContext context,
    PlannerTask task,
  ) async {
    final selectedDate = await showScheduleTaskDatePicker(
      context,
      initialDate: task.scheduledDate,
    );

    if (selectedDate == null) {
      return;
    }

    widget.onScheduleTaskForDate(taskId: task.id, scheduledDate: selectedDate);
  }

  List<PlannerTask> _tasksForDate(DateTime date) {
    final selectedDate = dateOnly(date);

    final selectedTasks = widget.tasks.where((task) {
      final scheduledDate = task.scheduledDate;

      if (scheduledDate == null) {
        return false;
      }

      return dateOnly(scheduledDate) == selectedDate;
    }).toList()..sort((first, second) => first.title.compareTo(second.title));

    return selectedTasks;
  }

  Set<DateTime> _datesWithTasks(List<PlannerTask> sourceTasks) {
    return sourceTasks
        .where((task) => task.scheduledDate != null)
        .map((task) => dateOnly(task.scheduledDate!))
        .toSet();
  }

  String _selectedDateTitle(DateTime date) {
    return 'Selected day: ${_dateGroupTitle(date)}';
  }

  String _dateGroupTitle(DateTime date) {
    return relativePlannerDateTitle(date);
  }

  Goal? _findGoalById(String? goalId) {
    if (goalId == null) {
      return null;
    }

    for (final goal in widget.goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}

enum _CalendarAddAction { oneTimeTask, recurringTask }
