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
        onEdit: () {},
        onDelete: () {},
        onScheduleTime: onScheduleTime,
        onClearScheduledTime: onClearScheduledTime,
        onEditReminder: onEditReminder,
      ),
    ),
  );
}
