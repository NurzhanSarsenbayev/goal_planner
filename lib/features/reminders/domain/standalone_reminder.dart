import '../../../shared/planner_time.dart';

class StandaloneReminder {
  StandaloneReminder({
    required this.id,
    required this.title,
    required this.timeMinutes,
    required this.isEnabled,
    required this.createdAt,
    required this.updatedAt,
  }) : assert(
         isValidPlannerTimeMinutes(timeMinutes),
         'timeMinutes must be between 0 and 1439.',
       );

  final String id;
  final String title;
  final int timeMinutes;
  final bool isEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;

  StandaloneReminder copyWith({
    String? id,
    String? title,
    int? timeMinutes,
    bool? isEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return StandaloneReminder(
      id: id ?? this.id,
      title: title ?? this.title,
      timeMinutes: timeMinutes ?? this.timeMinutes,
      isEnabled: isEnabled ?? this.isEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
