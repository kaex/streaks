import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize time zones
    tz.initializeTimeZones();

    // Use the device's local timezone
    final String timeZoneName = DateTime.now().timeZoneName;
    debugPrint('Device timezone: $timeZoneName');

    // Default to local timezone without specifying a location name
    tz.setLocalLocation(tz.local);

    // Set up Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon');

    // Set up iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: false, // We'll request this separately
      requestBadgePermission: false, // We'll request this separately
      requestSoundPermission: false, // We'll request this separately
      onDidReceiveLocalNotification:
          (int id, String? title, String? body, String? payload) async {
        // Handle the notification
      },
    );

    // Initialize settings
    final InitializationSettings initializationSettings =
        InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Initialize the plugin
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) async {
        // Handle notification taps
        debugPrint('Notification triggered: ${response.payload}');
      },
    );
  }

  // Request permission for notifications
  Future<bool> requestPermissions() async {
    debugPrint('Requesting notification permissions...');

    // For iOS
    final bool? iosResult = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );

    // For Android 13+ (API level 33+)
    final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
        flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();

    final bool? androidResult =
        await androidImplementation?.requestNotificationsPermission();

    // Log results
    debugPrint('iOS permission result: $iosResult');
    debugPrint('Android permission result: $androidResult');

    // If either platform returns false, permissions were denied
    if (iosResult == false || androidResult == false) {
      debugPrint('Notification permissions denied by user');
      return false;
    }

    // If we're on Android and couldn't get a result, we're probably on an older
    // Android version where permissions are granted in the manifest
    final bool permissionGranted = iosResult ?? androidResult ?? true;

    debugPrint(
        'Notification permissions ${permissionGranted ? "granted" : "denied"}');
    return permissionGranted;
  }

  // Schedule notifications for a specific habit
  Future<void> scheduleHabitNotifications(Habit habit) async {
    debugPrint('=== Scheduling notifications for habit: ${habit.title} ===');

    // Cancel any existing notifications for this habit first
    await cancelHabitNotifications(habit.id);

    // If there's no reminder time or no days selected, don't schedule
    if (habit.reminderTime == null || !habit.reminderDays.contains(true)) {
      debugPrint(
          'No reminders set for this habit (no time or no days selected)');
      return;
    }

    // For each selected day, schedule a notification
    int scheduledCount = 0;
    for (int i = 0; i < habit.reminderDays.length; i++) {
      if (habit.reminderDays[i]) {
        final dayName = [
          'Monday',
          'Tuesday',
          'Wednesday',
          'Thursday',
          'Friday',
          'Saturday',
          'Sunday'
        ][i];
        final weekday = i + 1; // Monday = 1, Tuesday = 2, etc.

        debugPrint(
            'Setting up reminder for $dayName at ${habit.reminderTime!.hour}:${habit.reminderTime!.minute}');

        try {
          // Create a unique ID for each day's notification
          int id = habit.id.hashCode + i;

          // Schedule notification for this weekday
          await _scheduleNotificationForWeekday(
            id,
            habit.id,
            'Time for ${habit.title}!',
            'Keep your streak going - ${habit.description}',
            weekday,
            habit.reminderTime!,
          );
          scheduledCount++;
        } catch (e) {
          debugPrint('Failed to schedule notification: $e');
        }
      }
    }

    debugPrint(
        '=== Scheduled $scheduledCount notifications for habit: ${habit.title} ===');
  }

  // Schedule a notification for specific weekday at specific time
  Future<void> _scheduleNotificationForWeekday(
    int id,
    String habitId,
    String title,
    String body,
    int weekday, // 1 = Monday, 2 = Tuesday, etc.
    TimeOfDay reminderTime,
  ) async {
    debugPrint(
        'Scheduling notification id=$id for weekday=$weekday at ${reminderTime.hour}:${reminderTime.minute}');

    try {
      // Create notification details
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'habit_reminder_channel',
        'Habit Reminders',
        channelDescription:
            'This channel is used for habit reminder notifications',
        importance: Importance.high,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        color: Colors.purple,
        ticker: 'habit',
        icon: 'notification_icon',
      );

      final DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      final dayNames = [
        'Monday',
        'Tuesday',
        'Wednesday',
        'Thursday',
        'Friday',
        'Saturday',
        'Sunday'
      ];
      final dayName = dayNames[weekday - 1]; // Convert 1-based to 0-based index

      // Calculate the next instance of the weekday and time
      final nextOccurrence = _nextInstanceOfWeekdayTime(weekday, reminderTime);
      debugPrint('Next occurrence: ${nextOccurrence.toString()}');

      // Schedule notification with zonedSchedule
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        nextOccurrence,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: habitId,
      );

      debugPrint(
          'Weekly notification scheduled for $dayName at ${_formatTime(reminderTime)}');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Calculate the next instance of a specific weekday and time
  tz.TZDateTime _nextInstanceOfWeekdayTime(int weekday, TimeOfDay time) {
    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Move forward to the correct weekday if needed
    while (scheduledDate.weekday != weekday || scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(Duration(days: 1));
    }

    return scheduledDate;
  }

  // Format time for display
  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  // Cancel all notifications for a specific habit
  Future<void> cancelHabitNotifications(String habitId) async {
    // Calculate the base ID for this habit
    final int baseId = habitId.hashCode;

    // Cancel notifications for each day of the week
    for (int i = 0; i < 7; i++) {
      final notificationId = baseId + i;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
      debugPrint('Cancelled notification with ID: $notificationId');
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }

  // Test a notification (will show immediately)
  Future<void> showTestNotification() async {
    debugPrint('Showing test notification...');

    try {
      // Create notification details
      final AndroidNotificationDetails androidPlatformChannelSpecifics =
          AndroidNotificationDetails(
        'test_channel',
        'Test Notifications',
        channelDescription: 'Used for testing notifications',
        importance: Importance.max,
        priority: Priority.high,
        enableLights: true,
        enableVibration: true,
        playSound: true,
        color: Colors.purple,
        ticker: 'test',
        icon: 'notification_icon',
      );

      final DarwinNotificationDetails iOSPlatformChannelSpecifics =
          DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      );

      final NotificationDetails platformChannelSpecifics = NotificationDetails(
        android: androidPlatformChannelSpecifics,
        iOS: iOSPlatformChannelSpecifics,
      );

      // Show an immediate notification
      await flutterLocalNotificationsPlugin.show(
        0, // Use a fixed ID for test notifications
        'Test Notification',
        'This is a test notification from Streaks! If you see this, notifications are working correctly.',
        platformChannelSpecifics,
        payload: 'test_notification',
      );

      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }
}
