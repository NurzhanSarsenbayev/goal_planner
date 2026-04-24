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
}