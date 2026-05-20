import '../../../models/goal.dart';
import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';
import '../../tasks/application/task_schedule_sorting.dart';

class CalendarTaskViewBuilder {
  const CalendarTaskViewBuilder();

  List<PlannerTask> tasksForDate({
    required List<PlannerTask> tasks,
    required DateTime date,
  }) {
    final selectedDate = dateOnly(date);

    final selectedTasks = tasks.where((task) {
      final scheduledDate = task.scheduledDate;

      if (scheduledDate == null) {
        return false;
      }

      return dateOnly(scheduledDate) == selectedDate;
    }).toList()..sort(compareTasksByScheduledTimeThenTitle);

    return selectedTasks;
  }

  Set<DateTime> datesWithTasks(List<PlannerTask> tasks) {
    return tasks
        .where((task) => task.scheduledDate != null)
        .map((task) => dateOnly(task.scheduledDate!))
        .toSet();
  }

  Goal? findGoalById({required List<Goal> goals, required String? goalId}) {
    if (goalId == null) {
      return null;
    }

    for (final goal in goals) {
      if (goal.id == goalId) {
        return goal;
      }
    }

    return null;
  }
}
