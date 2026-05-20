import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/application/local_notification_service.dart';

void main() {
  group('LocalNotificationService', () {
    test('can be created', () {
      final service = LocalNotificationService();

      expect(service, isA<LocalNotificationService>());
    });
  });
}
