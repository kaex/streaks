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
    // Cancel any existing notifications for this habit
    await cancelHabitNotifications(habit.id);

    // If there's no reminder time or no days selected, don't schedule
    if (habit.reminderTime == null || !habit.reminderDays.contains(true)) {
      debugPrint('No reminders set for habit: ${habit.title}');
      return;
    }

    debugPrint('Scheduling notifications for habit: ${habit.title}');

    // For each selected day, schedule a notification
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
            'Scheduling for $dayName at ${habit.reminderTime!.hour}:${habit.reminderTime!.minute}');

        try {
          // Create a unique ID for each day's notification
          int id = habit.id.hashCode + i;

          // Schedule notification for today or next occurrence of this weekday
          await _scheduleNotificationForWeekday(
            id,
            habit.id,
            'Time for ${habit.title}!',
            'Keep your streak going - ${habit.description}',
            weekday,
            habit.reminderTime!,
          );
        } catch (e) {
          debugPrint('Failed to schedule notification: $e');
        }
      }
    }
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
      final scheduledDate = _getNextOccurrence(weekday, reminderTime);

      // Create a message indicating when this notification is for
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

      // Create random ID that will be consistent across app restarts
      final random = Random(id);
      final notificationId = random.nextInt(100000) + id;

      // If it's today and after the scheduled time, send immediately
      // Otherwise, delay the notification until the next occurrence
      final timeDifference = scheduledDate.difference(now).inMilliseconds;
      if (timeDifference <= 0) {
        // The scheduled time is in the past for today, show the notification immediately
        await flutterLocalNotificationsPlugin.show(
          notificationId,
          title,
          '$body (Every $dayName at ${_formatTime(reminderTime)})',
          platformChannelSpecifics,
          payload: habitId,
        );
        debugPrint('Notification shown immediately.');
      } else {
        // Use the Android AlarmManager to schedule for the exact time with a pending intent
        // that will trigger at the next occurrence
        final AndroidFlutterLocalNotificationsPlugin? androidImpl =
            flutterLocalNotificationsPlugin
                .resolvePlatformSpecificImplementation<
                    AndroidFlutterLocalNotificationsPlugin>();

        await androidImpl?.createNotificationChannel(
          const AndroidNotificationChannel(
            'habit_reminder_exact_channel',
            'Habit Reminders (Exact)',
            description:
                'This channel is used for exact habit reminder notifications',
            importance: Importance.high,
          ),
        );

        await flutterLocalNotificationsPlugin.show(
          notificationId,
          title,
          '$body (Every $dayName at ${_formatTime(reminderTime)})',
          platformChannelSpecifics,
          payload: habitId,
        );

        debugPrint(
            'Notification scheduled to show next $dayName at ${_formatTime(reminderTime)}');
      }
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Calculate the next occurrence of a specific weekday and time
  DateTime _getNextOccurrence(int weekday, TimeOfDay time) {
    final now = DateTime.now();

    // Create today's occurrence of the time
    DateTime scheduledDate = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Calculate days until target weekday (0-6)
    int daysUntil = (weekday - now.weekday) % 7;

    // If today is the target weekday but the time has passed, go to next week
    if (daysUntil == 0 && now.isAfter(scheduledDate)) {
      daysUntil = 7;
    }

    // Add the days to the scheduled date
    scheduledDate = scheduledDate.add(Duration(days: daysUntil));

    debugPrint('Next occurrence will be on: ${scheduledDate.toString()}');
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
      final random = Random(baseId + i);
      final notificationId = random.nextInt(100000) + baseId + i;
      await flutterLocalNotificationsPlugin.cancel(notificationId);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
