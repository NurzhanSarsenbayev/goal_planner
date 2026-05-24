import '../../features/habits/domain/habit.dart' as domain;
import '../../features/habits/domain/habit_entry.dart' as domain;
import '../../features/habits/domain/habit_entry_status.dart';
import '../../features/habits/domain/habit_tracking_type.dart';
import '../local/app_database.dart' as local;

domain.Habit mapHabit(local.Habit row) {
  return domain.Habit(
    id: row.id,
    title: row.title,
    description: row.description,
    trackingType: mapHabitTrackingType(row.trackingType),
    targetCount: row.targetCount,
    sortOrder: row.sortOrder,
    isArchived: row.isArchived,
    isReminderEnabled: row.isReminderEnabled,
    reminderTimeMinutes: row.reminderTimeMinutes,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

domain.HabitEntry mapHabitEntry(local.HabitEntry row) {
  return domain.HabitEntry(
    id: row.id,
    habitId: row.habitId,
    date: row.date,
    status: mapHabitEntryStatus(row.status),
    completedCount: row.completedCount,
    note: row.note,
    createdAt: row.createdAt,
    updatedAt: row.updatedAt,
  );
}

HabitTrackingType mapHabitTrackingType(String value) {
  for (final type in HabitTrackingType.values) {
    if (type.name == value) {
      return type;
    }
  }

  return HabitTrackingType.binary;
}

HabitEntryStatus mapHabitEntryStatus(String value) {
  for (final status in HabitEntryStatus.values) {
    if (status.name == value) {
      return status;
    }
  }

  return HabitEntryStatus.none;
}

String habitTrackingTypeToDatabaseValue(HabitTrackingType type) {
  return type.name;
}

String habitEntryStatusToDatabaseValue(HabitEntryStatus status) {
  return status.name;
}
