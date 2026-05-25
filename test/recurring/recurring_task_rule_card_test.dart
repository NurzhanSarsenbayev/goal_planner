import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/recurring/presentation/widgets/recurring_task_rule_card.dart';
import 'package:goal_planner/l10n/app_localizations.dart';
import 'package:goal_planner/models/recurring_task_rule.dart';

void main() {
  group('RecurringTaskRuleCard', () {
    testWidgets('shows recurrence time and reminder in subtitle', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          rule: RecurringTaskRule(
            id: 'rule-1',
            title: 'Workout',
            description: '',
            recurrenceType: RecurrenceType.weekly,
            weekdays: const [DateTime.tuesday, DateTime.wednesday],
            monthDay: null,
            startDate: DateTime(2026, 5, 25),
            scheduledTimeMinutes: 9 * 60 + 30,
            reminderMinutesBefore: 15,
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(find.text('Workout'), findsOneWidget);
      expect(
        find.text('Weekly · Tue, Wed · Time: 09:30 · 15 min before'),
        findsOneWidget,
      );
    });

    testWidgets('does not show time when rule has no scheduled time', (
      tester,
    ) async {
      await tester.pumpWidget(
        _app(
          rule: RecurringTaskRule(
            id: 'rule-1',
            title: 'Workout',
            description: '',
            recurrenceType: RecurrenceType.weekly,
            weekdays: const [DateTime.tuesday, DateTime.wednesday],
            monthDay: null,
            startDate: DateTime(2026, 5, 25),
            createdAt: DateTime(2026, 5, 20),
          ),
        ),
      );

      expect(find.text('Workout'), findsOneWidget);
      expect(find.text('Weekly · Tue, Wed'), findsOneWidget);
      expect(find.textContaining('Time:'), findsNothing);
    });
  });
}

Widget _app({required RecurringTaskRule rule}) {
  return MaterialApp(
    locale: const Locale('en'),
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    supportedLocales: AppLocalizations.supportedLocales,
    home: Scaffold(body: RecurringTaskRuleCard(rule: rule)),
  );
}
