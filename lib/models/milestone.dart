class Milestone {
  const Milestone({
    required this.id,
    required this.goalId,
    required this.title,
    required this.description,
    required this.createdAt,
  });

  final String id;
  final String goalId;
  final String title;
  final String description;
  final DateTime createdAt;

  Milestone copyWith({
    String? id,
    String? goalId,
    String? title,
    String? description,
    DateTime? createdAt,
  }) {
    return Milestone(
      id: id ?? this.id,
      goalId: goalId ?? this.goalId,
      title: title ?? this.title,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}