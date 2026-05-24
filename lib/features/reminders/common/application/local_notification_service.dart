import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as timezone_data;
import 'package:timezone/timezone.dart' as timezone;

import 'reminder_notification_texts.dart';
import 'reminder_notification_client.dart';

class LocalNotificationService implements ReminderNotificationClient {
  LocalNotificationService({
    FlutterLocalNotificationsPlugin? plugin,
    ReminderNotificationTexts? notificationTexts,
  }) : _plugin = plugin ?? FlutterLocalNotificationsPlugin(),
       _notificationTexts = notificationTexts ?? ReminderNotificationTexts();

  final FlutterLocalNotificationsPlugin _plugin;
  final ReminderNotificationTexts _notificationTexts;

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
    final androidDetails = AndroidNotificationDetails(
      'goal_planner_reminders',
      _notificationTexts.testChannelName,
      channelDescription: _notificationTexts.testChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.show(
      id: 1,
      title: _notificationTexts.testNotificationTitle,
      body: _notificationTexts.testNotificationBody,
      notificationDetails: notificationDetails,
    );
  }

  @override
  Future<void> scheduleReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    String? payload,
    ReminderRepeat repeat = ReminderRepeat.none,
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

    final androidDetails = AndroidNotificationDetails(
      'goal_planner_task_reminders',
      _notificationTexts.reminderChannelName,
      channelDescription: _notificationTexts.reminderChannelDescription,
      importance: Importance.high,
      priority: Priority.high,
    );

    final notificationDetails = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id: id,
      title: title,
      body: body,
      scheduledDate: timezone.TZDateTime.from(scheduledAt, timezone.local),
      notificationDetails: notificationDetails,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      payload: payload,
      matchDateTimeComponents: repeat == ReminderRepeat.daily
          ? DateTimeComponents.time
          : null,
    );
  }

  @override
  Future<void> cancelReminder(int id) async {
    await initialize();

    await _plugin.cancel(id: id);
  }

  Future<void> _configureLocalTimeZone() async {
    final localTimeZone = await FlutterTimezone.getLocalTimezone();
    timezone.setLocalLocation(timezone.getLocation(localTimeZone));
  }
}
