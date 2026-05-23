import 'package:flutter_test/flutter_test.dart';
import 'package:goal_planner/features/reminders/common/application/local_notification_service.dart';
import 'package:goal_planner/features/reminders/common/application/reminder_notification_client.dart';

void main() {
  group('LocalNotificationService', () {
    test('implements reminder notification client', () {
      final service = LocalNotificationService();

      expect(service, isA<LocalNotificationService>());
      expect(service, isA<ReminderNotificationClient>());
    });
  });
}
