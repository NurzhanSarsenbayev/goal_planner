import '../models/goal.dart';
import '../models/planner_task.dart';

final sampleGoals = [
  Goal(
    id: 'goal_blog',
    title: 'Develop personal blog',
    description: 'Build a stable content routine for blog growth.',
    status: GoalStatus.active,
    createdAt: DateTime.now(),
  ),
  Goal(
    id: 'goal_health',
    title: 'Improve health routine',
    description: 'Create a realistic daily movement and recovery system.',
    status: GoalStatus.active,
    createdAt: DateTime.now(),
  ),
];

final sampleTasks = [
  PlannerTask(
    id: 'task_blog_1',
    goalId: 'goal_blog',
    title: 'Write 10 post ideas',
    description: 'Draft topics for the next two weeks.',
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
  ),
  PlannerTask(
    id: 'task_blog_2',
    goalId: 'goal_blog',
    title: 'Record one short video',
    description: 'Prepare and record one simple reel.',
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
  ),
  PlannerTask(
    id: 'task_health_1',
    goalId: 'goal_health',
    title: 'Walk 30 minutes',
    description: 'Easy walk without overcomplicating it.',
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
  ),
  PlannerTask(
    id: 'task_personal_1',
    title: 'Buy a gift',
    description: 'One-off task not connected to any goal.',
    scheduledDate: DateTime.now(),
    createdAt: DateTime.now(),
  ),
];