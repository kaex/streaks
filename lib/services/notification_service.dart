import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'dart:math';
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
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
        debugPrint('Notification response received: ${response.payload}');
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

  // Schedule a single notification for immediate delivery
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

      // Calculate next occurrence
      final now = DateTime.now();
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

      // Create today's date with the reminder time
      DateTime scheduledTime = DateTime(
        now.year,
        now.month,
        now.day,
        reminderTime.hour,
        reminderTime.minute,
      );

      // Calculate days until target weekday (0 if today is the target day)
      int daysUntil = (weekday - now.weekday) % 7;

      // If today is the target day but the time has passed, schedule for next week
      if (daysUntil == 0 && now.isAfter(scheduledTime)) {
        daysUntil = 7;
      }

      // Add days until the target weekday
      scheduledTime = scheduledTime.add(Duration(days: daysUntil));

      debugPrint('Calculated next occurrence: ${scheduledTime.toString()}');

      // Create a unique ID for this notification
      final notificationId = id;

      // Calculate seconds until notification time
      final secondsUntil = scheduledTime.difference(now).inSeconds;
      debugPrint('Seconds until notification: $secondsUntil');

      if (secondsUntil > 0) {
        // Only schedule for future time
        // Use pending intent approach
        await flutterLocalNotificationsPlugin.periodicallyShow(
          notificationId,
          title,
          body,
          RepeatInterval.weekly, // Will repeat weekly
          platformChannelSpecifics,
          payload: habitId,
          androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        );

        debugPrint(
            'Notification scheduled for $dayName at ${_formatTime(reminderTime)} (will repeat weekly)');
      } else {
        debugPrint('Cannot schedule in the past, notification not set');
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
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
}
