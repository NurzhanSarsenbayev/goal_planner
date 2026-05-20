import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'task_reminder_scheduler.dart';

class LocalNotificationService implements TaskReminderNotificationClient {
  LocalNotificationService({FlutterLocalNotificationsPlugin? plugin})
    : _plugin = plugin ?? FlutterLocalNotificationsPlugin();

  final FlutterLocalNotificationsPlugin _plugin;

  Future<void>? _initializeFuture;

  Future<void> initialize() {
    return _initializeFuture ??= _initialize();
  }

  Future<void> _initialize() async {
    timezone_data.initializeTimeZones();
    await _configureLocalTimeZone();

    const initializationSettings = InitializationSettings(
      android: AndroidInitializationSettings('@mipmap/ic_launcher'),
    );

    await _plugin.initialize(settings: initializationSettings);
  }

  Future<bool> requestNotificationPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await android?.requestNotificationsPermission();

    return granted ?? true;
  }

  Future<bool> requestExactAlarmPermission() async {
    final android = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await android?.requestExactAlarmsPermission();

    return granted ?? true;
  }

  Future<bool> requestTaskReminderPermissions() async {
    await initialize();

    final notificationPermissionGranted = await requestNotificationPermission();

    if (!notificationPermissionGranted) {
      return false;
    }

    final exactAlarmPermissionGranted = await requestExactAlarmPermission();

    return exactAlarmPermissionGranted;
  }

  Future<void> showTestNotification() async {
    const androidDetails = AndroidNotificationDetails(
      'goal_planner_test',
      'Goal Planner test notifications',
      channelDescription: 'Used to verify local notification setup.',
      importance: Importance.defaultImportance,
      priority: Priority.defaultPriority,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 1,
      title: 'Goal Planner',
      body: 'Notifications are working.',
      notificationDetails: notificationDetails,
    );
  }

  @override
  Future<void> scheduleTaskReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
  }) async {
    await initialize();

    final notificationPermissionGranted = await requestNotificationPermission();

    if (!notificationPermissionGranted) {
      return;
    }

    final exactAlarmPermissionGranted = await requestExactAlarmPermission();

    if (!exactAlarmPermissionGranted) {
      return;
    }

    const androidDetails = AndroidNotificationDetails(
      'goal_planner_task_reminders',
      'Task reminders',
      channelDescription: 'Notifications for scheduled Goal Planner tasks.',
      importance: Importance.high,
      priority: Priority.high,
    );

    const notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: timezone.TZDateTime.from(scheduledAt, timezone.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
    );
  }

  @override
  Future<void> cancelTaskReminder(int id) async {
    await initialize();

    await _plugin.cancel(id: id);
  }

  Future<void> _configureLocalTimeZone() async {
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(localTimeZone));
  }
}
