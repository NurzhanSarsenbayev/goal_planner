import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/tasks/presentation/widgets/task_card.dart';
import 'package:goal_planner/l10n/app_localizations.dart';
import 'package:goal_planner/models/planner_task.dart';
import 'package:goal_planner/shared/planner_dates.dart';

void main() {
  group('TaskCard', () {
    testWidgets('shows scheduled time when task has scheduled time', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: todayDate(),
            scheduledTimeMinutes: 9 * 60 + 30,
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(find.text('Scheduled: Today · 09:30'), findsOneWidget);
    });

    testWidgets('shows reminder status when task has reminder', (tester) async {
      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: todayDate(),
            scheduledTimeMinutes: 9 * 60 + 30,
            reminderMinutesBefore: 15,
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(
        find.text('Scheduled: Today · 09:30 · Reminder: 15 min before'),
        findsOneWidget,
      );
    });

    testWidgets('shows scheduled time actions for scheduled tasks', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: todayDate(),
            createdAt: DateTime(2026, 5, 20),
          ),
          onScheduleTime: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Set time'), findsOneWidget);
    });

    testWidgets('shows reminder action for timed tasks', (tester) async {
      var didOpenReminder = false;

      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: todayDate(),
            scheduledTimeMinutes: 9 * 60 + 30,
            createdAt: DateTime(2026, 5, 20),
          ),
          onEditReminder: () {
            didOpenReminder = true;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reminder'));
      await tester.pumpAndSettle();

      expect(didOpenReminder, isTrue);
    });

    testWidgets('opens edit actions sheet from action button', (tester) async {
      var didEdit = false;

      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            createdAt: DateTime(2026, 5, 20),
          ),
          onEdit: () {
            didEdit = true;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit task'), findsOneWidget);
      expect(find.text('Title and description'), findsOneWidget);

      await tester.tap(find.text('Title and description'));
      await tester.pumpAndSettle();

      expect(didEdit, isTrue);
    });

    testWidgets('shows only this task section for recurring occurrence', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_recurring_rule_1_20260520',
            title: 'Workout',
            description: '',
            recurringRuleId: 'rule_1',
            scheduledDate: todayDate(),
            scheduledTimeMinutes: 9 * 60 + 30,
            reminderMinutesBefore: 15,
            createdAt: DateTime(2026, 5, 20),
          ),
          onScheduleTime: () {},
          onClearScheduledTime: () {},
          onEditReminder: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit recurring task'), findsOneWidget);
      expect(find.text('Only this task'), findsOneWidget);
      expect(find.text('Title and description'), findsOneWidget);
      expect(find.text('Change time'), findsOneWidget);
      expect(find.text('Reminder'), findsOneWidget);
      expect(find.text('Clear time'), findsOneWidget);
    });

    testWidgets('shows whole series action for recurring occurrence', (
      tester,
    ) async {
      var didEditSeries = false;

      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_recurring_rule_1_20260520',
            title: 'Workout',
            description: '',
            recurringRuleId: 'rule_1',
            scheduledDate: todayDate(),
            scheduledTimeMinutes: 9 * 60 + 30,
            reminderMinutesBefore: 15,
            createdAt: DateTime(2026, 5, 20),
          ),
          onEditRecurringSeries: () {
            didEditSeries = true;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Edit recurring task'), findsOneWidget);
      expect(find.text('Only this task'), findsOneWidget);
      expect(find.text('Delete this task'), findsOneWidget);
      expect(find.text('Whole series'), findsOneWidget);
      expect(find.text('Edit repeat rule'), findsOneWidget);

      await tester.tap(find.text('Edit repeat rule'));
      await tester.pumpAndSettle();

      expect(didEditSeries, isTrue);
    });

    testWidgets('runs delete whole series action for recurring occurrence', (
      tester,
    ) async {
      var didDeleteSeries = false;

      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_recurring_rule_1_20260520',
            title: 'Workout',
            description: '',
            recurringRuleId: 'rule_1',
            scheduledDate: todayDate(),
            createdAt: DateTime(2026, 5, 20),
          ),
          onEditRecurringSeries: () {},
          onDeleteRecurringSeries: () {
            didDeleteSeries = true;
          },
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Whole series'), findsOneWidget);
      expect(find.text('Edit repeat rule'), findsOneWidget);
      expect(find.text('Delete whole series'), findsOneWidget);

      await tester.tap(find.text('Delete whole series'));
      await tester.pumpAndSettle();

      expect(didDeleteSeries, isTrue);
    });

    testWidgets('shows clear time action when scheduled time exists', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: todayDate(),
            scheduledTimeMinutes: 9 * 60 + 30,
            createdAt: DateTime(2026, 5, 20),
          ),
          onScheduleTime: () {},
          onClearScheduledTime: () {},
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      expect(find.text('Change time'), findsOneWidget);
      expect(find.text('Clear time'), findsOneWidget);
    });

    testWidgets('keeps scheduled date label without time for untimed tasks', (
      tester,
    ) async {
      final scheduledDate = todayDate().add(const Duration(days: 1));

      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: scheduledDate,
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(
        find.text('Scheduled: ${formatPlannerDate(scheduledDate)}'),
        findsOneWidget,
      );
    });
  });
}

Widget _app({
  required PlannerTask task,
  VoidCallback? onScheduleTime,
  VoidCallback? onClearScheduledTime,
  VoidCallback? onEditReminder,
  VoidCallback? onEdit,
  VoidCallback? onEditRecurringSeries,
  VoidCallback? onDeleteRecurringSeries,
}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: TaskCard(
        task: task,
        goal: null,
        onToggleCompleted: () {},
        onEdit: onEdit ?? () {},
        onDelete: () {},
        onScheduleTime: onScheduleTime,
        onClearScheduledTime: onClearScheduledTime,
        onEditReminder: onEditReminder,
        onEditRecurringSeries: onEditRecurringSeries,
        onDeleteRecurringSeries: onDeleteRecurringSeries,
      ),
    ),
  );
}
