import 'package:flutter/material.dart';

import '../app/app_dialogs.dart';
import '../models/goal.dart';
import '../models/planner_task.dart';
import '../widgets/placeholder_screen.dart';
import '../widgets/task_card.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({
    super.key,
    required this.goals,
    required this.tasks,
    required this.onToggleTaskCompleted,
    required this.onEditTask,
    required this.onScheduleTaskForDate,
    required this.onRemoveTaskFromSchedule,
    required this.onDeleteTask,
  });

  final List<Goal> goals;
  final List<PlannerTask> tasks;
  final void Function(String taskId) onToggleTaskCompleted;
  final void Function(PlannerTask task) onEditTask;
  final void Function({required String taskId, required DateTime scheduledDate})
  onScheduleTaskForDate;
  final void Function(String taskId) onRemoveTaskFromSchedule;
  final void Function(String taskId) onDeleteTask;

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _visibleMonth;
  late DateTime _selectedDate;

  @override
  void initState() {
    super.initState();

    final today = _dateOnly(DateTime.now());
    _visibleMonth = DateTime(today.year, today.month);
    _selectedDate = today;
  }

  @override
  Widget build(BuildContext context) {
    final scheduledGroups = _buildScheduledTaskGroups(widget.tasks);

    if (scheduledGroups.isEmpty) {
      return Column(
        children: [
          _MonthGrid(
            visibleMonth: _visibleMonth,
            selectedDate: _selectedDate,
            datesWithTasks: const {},
            onPreviousMonth: _showPreviousMonth,
            onNextMonth: _showNextMonth,
            onSelectDate: _selectDate,
          ),
          const Expanded(
            child: PlaceholderScreen(
              title: 'Calendar',
              description: 'No scheduled tasks yet.',
              icon: Icons.calendar_month,
            ),
          ),
        ],
      );
    }

    final selectedDateTasks = _tasksForDate(_selectedDate);
    final datesWithTasks = _datesWithTasks(widget.tasks);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
      children: [
        _MonthGrid(
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
                widget.onToggleTaskCompleted(task.id);
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
        const SizedBox(height: 24),
        Text(
          'All scheduled tasks',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 8),
        for (final group in scheduledGroups) ...[
          Padding(
            padding: const EdgeInsets.only(top: 8, bottom: 8),
            child: Text(
              _dateGroupTitle(group.date),
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),
          for (final task in group.tasks) ...[
            TaskCard(
              task: task,
              goal: _findGoalById(task.goalId),
              onToggleCompleted: () {
                widget.onToggleTaskCompleted(task.id);
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
      ],
    );
  }

  void _showPreviousMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month - 1);
    });
  }

  void _showNextMonth() {
    setState(() {
      _visibleMonth = DateTime(_visibleMonth.year, _visibleMonth.month + 1);
    });
  }

  void _selectDate(DateTime date) {
    setState(() {
      _selectedDate = _dateOnly(date);
    });
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
    final selectedDate = _dateOnly(date);

    final selectedTasks = widget.tasks.where((task) {
      final scheduledDate = task.scheduledDate;

      if (scheduledDate == null) {
        return false;
      }

      return _dateOnly(scheduledDate) == selectedDate;
    }).toList()..sort((first, second) => first.title.compareTo(second.title));

    return selectedTasks;
  }

  Set<DateTime> _datesWithTasks(List<PlannerTask> sourceTasks) {
    return sourceTasks
        .where((task) => task.scheduledDate != null)
        .map((task) => _dateOnly(task.scheduledDate!))
        .toSet();
  }

  List<_ScheduledTaskGroup> _buildScheduledTaskGroups(
    List<PlannerTask> sourceTasks,
  ) {
    final scheduledTasks =
        sourceTasks.where((task) => task.scheduledDate != null).toList()
          ..sort((first, second) {
            final firstDate = first.scheduledDate!;
            final secondDate = second.scheduledDate!;

            final dateComparison = firstDate.compareTo(secondDate);

            if (dateComparison != 0) {
              return dateComparison;
            }

            return first.title.compareTo(second.title);
          });

    final groups = <_ScheduledTaskGroup>[];

    for (final task in scheduledTasks) {
      final scheduledDate = task.scheduledDate!;
      final dateOnly = _dateOnly(scheduledDate);

      if (groups.isEmpty || groups.last.date != dateOnly) {
        groups.add(_ScheduledTaskGroup(date: dateOnly, tasks: [task]));
      } else {
        groups.last.tasks.add(task);
      }
    }

    return groups;
  }

  String _selectedDateTitle(DateTime date) {
    return 'Selected day: ${_dateGroupTitle(date)}';
  }

  String _dateGroupTitle(DateTime date) {
    final today = _dateOnly(DateTime.now());
    final tomorrow = today.add(const Duration(days: 1));
    final yesterday = today.subtract(const Duration(days: 1));

    if (date == today) {
      return 'Today';
    }

    if (date == tomorrow) {
      return 'Tomorrow';
    }

    if (date == yesterday) {
      return 'Yesterday';
    }

    return _formatDate(date);
  }

  String _formatDate(DateTime date) {
    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    final year = date.year.toString();

    return '$day.$month.$year';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
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

class _MonthGrid extends StatelessWidget {
  const _MonthGrid({
    required this.visibleMonth,
    required this.selectedDate,
    required this.datesWithTasks,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onSelectDate,
  });

  final DateTime visibleMonth;
  final DateTime selectedDate;
  final Set<DateTime> datesWithTasks;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final void Function(DateTime date) onSelectDate;

  @override
  Widget build(BuildContext context) {
    final days = _visibleCalendarDays();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                IconButton(
                  onPressed: onPreviousMonth,
                  icon: const Icon(Icons.chevron_left),
                ),
                Expanded(
                  child: Text(
                    _monthTitle(visibleMonth),
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  onPressed: onNextMonth,
                  icon: const Icon(Icons.chevron_right),
                ),
              ],
            ),
            const SizedBox(height: 8),
            const Row(
              children: [
                _WeekdayLabel('Mon'),
                _WeekdayLabel('Tue'),
                _WeekdayLabel('Wed'),
                _WeekdayLabel('Thu'),
                _WeekdayLabel('Fri'),
                _WeekdayLabel('Sat'),
                _WeekdayLabel('Sun'),
              ],
            ),
            const SizedBox(height: 8),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: days.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemBuilder: (context, index) {
                final date = days[index];

                if (date == null) {
                  return const SizedBox.shrink();
                }

                final dateOnly = _dateOnly(date);
                final isSelected = dateOnly == _dateOnly(selectedDate);
                final isToday = dateOnly == _dateOnly(DateTime.now());
                final hasTasks = datesWithTasks.contains(dateOnly);

                return _DayCell(
                  date: dateOnly,
                  isSelected: isSelected,
                  isToday: isToday,
                  hasTasks: hasTasks,
                  onTap: () {
                    onSelectDate(dateOnly);
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  List<DateTime?> _visibleCalendarDays() {
    final firstDayOfMonth = DateTime(visibleMonth.year, visibleMonth.month);
    final daysInMonth = DateTime(
      visibleMonth.year,
      visibleMonth.month + 1,
      0,
    ).day;
    final leadingEmptyDays = firstDayOfMonth.weekday - 1;

    return [
      for (var index = 0; index < leadingEmptyDays; index++) null,
      for (var day = 1; day <= daysInMonth; day++)
        DateTime(visibleMonth.year, visibleMonth.month, day),
    ];
  }

  String _monthTitle(DateTime date) {
    const monthNames = [
      'January',
      'February',
      'March',
      'April',
      'May',
      'June',
      'July',
      'August',
      'September',
      'October',
      'November',
      'December',
    ];

    return '${monthNames[date.month - 1]} ${date.year}';
  }

  DateTime _dateOnly(DateTime date) {
    return DateTime(date.year, date.month, date.day);
  }
}

class _WeekdayLabel extends StatelessWidget {
  const _WeekdayLabel(this.label);

  final String label;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Text(
        label,
        textAlign: TextAlign.center,
        style: Theme.of(context).textTheme.labelSmall,
      ),
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.date,
    required this.isSelected,
    required this.isToday,
    required this.hasTasks,
    required this.onTap,
  });

  final DateTime date;
  final bool isSelected;
  final bool isToday;
  final bool hasTasks;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? colorScheme.primaryContainer : null,
          border: isToday ? Border.all(color: colorScheme.primary) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              date.day.toString(),
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4),
            if (hasTasks)
              Container(
                width: 5,
                height: 5,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  shape: BoxShape.circle,
                ),
              )
            else
              const SizedBox(height: 5),
          ],
        ),
      ),
    );
  }
}

class _ScheduledTaskGroup {
  _ScheduledTaskGroup({required this.date, required this.tasks});

  final DateTime date;
  final List<PlannerTask> tasks;
}
