import 'habit_tracking_type.dart';

const _unset = Object();

class Habit {
  const Habit({
    required this.id,
    required this.title,
    required this.description,
    required this.trackingType,
    required this.targetCount,
    required this.sortOrder,
    required this.isArchived,
    this.isReminderEnabled = false,
    this.reminderTimeMinutes,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         reminderTimeMinutes == null ||
             reminderTimeMinutes >= 0 && reminderTimeMinutes < 24 * 60,
         'reminderTimeMinutes must be between 0 and 1439.',
       ),
       assert(
         !isReminderEnabled || reminderTimeMinutes != null,
         'Enabled habit reminder must have reminderTimeMinutes.',
       );

  final String id;
  final String title;
  final String description;
  final HabitTrackingType trackingType;
  final int? targetCount;
  final int sortOrder;
  final bool isArchived;
  final bool isReminderEnabled;
  final int? reminderTimeMinutes;
  final DateTime createdAt;
  final DateTime updatedAt;

  bool get isBinary => trackingType == HabitTrackingType.binary;

  bool get isCountBased => trackingType == HabitTrackingType.count;

  Habit copyWith({
    String? id,
    String? title,
    String? description,
    HabitTrackingType? trackingType,
    Object? targetCount = _unset,
    int? sortOrder,
    bool? isArchived,
    bool? isReminderEnabled,
    Object? reminderTimeMinutes = _unset,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      trackingType: trackingType ?? this.trackingType,
      targetCount: identical(targetCount, _unset)
          ? this.targetCount
          : targetCount as int?,
      sortOrder: sortOrder ?? this.sortOrder,
      isArchived: isArchived ?? this.isArchived,
      isReminderEnabled: isReminderEnabled ?? this.isReminderEnabled,
      reminderTimeMinutes: identical(reminderTimeMinutes, _unset)
          ? this.reminderTimeMinutes
          : reminderTimeMinutes as int?,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
