import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/shared/planner_time.dart';

void main() {
  group('planner time', () {
    test('validates minutes since midnight range', () {
      expect(isValidPlannerTimeMinutes(0), isTrue);
      expect(isValidPlannerTimeMinutes(570), isTrue);
      expect(isValidPlannerTimeMinutes(1439), isTrue);

      expect(isValidPlannerTimeMinutes(-1), isFalse);
      expect(isValidPlannerTimeMinutes(1440), isFalse);
    });

    test('converts hour and minute to minutes since midnight', () {
      expect(plannerTimeMinutes(hour: 0, minute: 0), 0);
      expect(plannerTimeMinutes(hour: 9, minute: 30), 570);
      expect(plannerTimeMinutes(hour: 23, minute: 59), 1439);
    });

    test('formats minutes since midnight as HH:mm', () {
      expect(formatPlannerTime(0), '00:00');
      expect(formatPlannerTime(5), '00:05');
      expect(formatPlannerTime(570), '09:30');
      expect(formatPlannerTime(780), '13:00');
      expect(formatPlannerTime(1439), '23:59');
    });
  });
}
