import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/models/recurring_task_exception.dart';

void main() {
  group('RecurringTaskException', () {
    test('normalizes date to date-only', () {
      final exception = RecurringTaskException(
        id: 'exception-1',
        ruleId: 'rule-1',
        date: DateTime(2026, 4, 27, 18, 45),
        createdAt: DateTime(2026, 4, 1),
      );

      expect(exception.date, DateTime(2026, 4, 27));
    });

    test('matches same rule and same date', () {
      final exception = RecurringTaskException(
        id: 'exception-1',
        ruleId: 'rule-1',
        date: DateTime(2026, 4, 27),
        createdAt: DateTime(2026, 4, 1),
      );

      expect(
        exception.matches(
          ruleId: 'rule-1',
          date: DateTime(2026, 4, 27, 10, 30),
        ),
        isTrue,
      );
    });

    test('does not match different rule', () {
      final exception = RecurringTaskException(
        id: 'exception-1',
        ruleId: 'rule-1',
        date: DateTime(2026, 4, 27),
        createdAt: DateTime(2026, 4, 1),
      );

      expect(
        exception.matches(ruleId: 'rule-2', date: DateTime(2026, 4, 27)),
        isFalse,
      );
    });

    test('does not match different date', () {
      final exception = RecurringTaskException(
        id: 'exception-1',
        ruleId: 'rule-1',
        date: DateTime(2026, 4, 27),
        createdAt: DateTime(2026, 4, 1),
      );

      expect(
        exception.matches(ruleId: 'rule-1', date: DateTime(2026, 4, 28)),
        isFalse,
      );
    });
  });
}
