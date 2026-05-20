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

    testWidgets('keeps scheduled date label without time for untimed tasks', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          task: PlannerTask(
            id: 'task_1',
            title: 'Plan day',
            description: '',
            scheduledDate: DateTime(2026, 5, 21),
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(find.text('Scheduled: 21.05.2026'), findsOneWidget);
    });
  });
}

Widget _app({required PlannerTask task}) {
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
      ),
    ),
  );
}
