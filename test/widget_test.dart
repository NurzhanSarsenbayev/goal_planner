import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/app/goal_planner_app.dart';

void main() {
  testWidgets('app shell renders bottom navigation', (tester) async {
    await tester.pumpWidget(const GoalPlannerApp());

    expect(find.text('Today'), findsWidgets);
    expect(find.text('Goals'), findsOneWidget);
    expect(find.text('Calendar'), findsOneWidget);
    expect(find.text('More'), findsOneWidget);
  });
}