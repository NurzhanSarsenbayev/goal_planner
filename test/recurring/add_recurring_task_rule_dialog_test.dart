import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/recurring/presentation/widgets/add_recurring_task_rule_dialog.dart';
import 'package:goal_planner/l10n/app_localizations.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('AddRecurringTaskRuleDialog', () {
    testWidgets('shows existing time and reminder when editing rule', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          initialRule: RecurringTaskRule(
            id: 'rule-1',
            title: 'Workout',
            description: '',
            recurrenceType: RecurrenceType.weekly,
            weekdays: const [DateTime.monday],
            monthDay: null,
            startDate: DateTime(2026, 5, 25),
            scheduledTimeMinutes: 9 * 60 + 30,
            reminderMinutesBefore: 15,
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(find.text('Time: 09:30'), findsOneWidget);
      expect(find.text('15 min before'), findsOneWidget);
    });

    testWidgets('hides reminder selector when time is not set', (tester) async {
      await tester.pumpWidget(
        _app(
          initialRule: RecurringTaskRule(
            id: 'rule-1',
            title: 'Workout',
            description: '',
            recurrenceType: RecurrenceType.weekly,
            weekdays: const [DateTime.monday],
            monthDay: null,
            startDate: DateTime(2026, 5, 25),
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(find.text('Add time'), findsOneWidget);
      expect(find.text('Reminder'), findsNothing);
    });
  });
}

Widget _app({required RecurringTaskRule initialRule}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(
      body: AddRecurringTaskRuleDialog(
        goals: const [],
        milestones: const [],
        initialRule: initialRule,
        dialogTitle: 'Edit recurring task',
        submitLabel: 'Save',
      ),
    ),
  );
}
