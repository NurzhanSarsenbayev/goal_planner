import '../../../models/planner_task.dart';
import '../../../shared/planner_dates.dart';

int compareTasksByScheduledDateTimeThenTitle(
  PlannerTask first,
  PlannerTask second,
) {
  final dateCompare = _compareScheduledDates(first, second);

  if (dateCompare != 0) {
    return dateCompare;
  }

  return compareTasksByScheduledTimeThenTitle(first, second);
}

int compareTasksByScheduledTimeThenTitle(
  PlannerTask first,
  PlannerTask second,
) {
  final firstTime = first.scheduledTimeMinutes;
  final secondTime = second.scheduledTimeMinutes;

  if (firstTime != null && secondTime != null) {
    final timeCompare = firstTime.compareTo(secondTime);

    if (timeCompare != 0) {
      return timeCompare;
    }
  }

  if (firstTime != null && secondTime == null) {
    return -1;
  }

  if (firstTime == null && secondTime != null) {
    return 1;
  }

  final titleCompare = first.title.toLowerCase().compareTo(
    second.title.toLowerCase(),
  );

  if (titleCompare != 0) {
    return titleCompare;
  }

  return first.createdAt.compareTo(second.createdAt);
}

int _compareScheduledDates(PlannerTask first, PlannerTask second) {
  final firstDate = first.scheduledDate;
  final secondDate = second.scheduledDate;

  if (firstDate == null && secondDate == null) {
    return 0;
  }

  if (firstDate == null) {
    return 1;
  }

  if (secondDate == null) {
    return -1;
  }

  return dateOnly(firstDate).compareTo(dateOnly(secondDate));
}
