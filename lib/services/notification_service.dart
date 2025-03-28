import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
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
        debugPrint(
            'Scheduling for $dayName at ${habit.reminderTime!.hour}:${habit.reminderTime!.minute}');

        try {
          await _scheduleWeeklyNotification(
            habit.id.hashCode + i, // Unique ID for each day
            habit.id,
            'Time for ${habit.title}!',
            'Keep your streak going - ${habit.description}',
            i + 1, // Monday = 1, Tuesday = 2, etc.
            habit.reminderTime!,
          );
        } catch (e) {
          debugPrint('Failed to schedule notification: $e');
        }
      }
    }
  }

  // Schedule a weekly notification for a specific day
  Future<void> _scheduleWeeklyNotification(
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

      // Schedule the notification to repeat weekly on the specified day and time
      await flutterLocalNotificationsPlugin.periodicallyShow(
        id,
        title,
        body,
        RepeatInterval.weekly,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        payload: habitId,
      );

      debugPrint('Notification scheduled successfully for weekly interval');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
    }
  }

  // Cancel all notifications for a specific habit
  Future<void> cancelHabitNotifications(String habitId) async {
    // Calculate the base ID for this habit
    final int baseId = habitId.hashCode;

    // Cancel notifications for each day of the week
    for (int i = 0; i < 7; i++) {
      await flutterLocalNotificationsPlugin.cancel(baseId + i);
    }
  }

  // Cancel all notifications
  Future<void> cancelAllNotifications() async {
    await flutterLocalNotificationsPlugin.cancelAll();
  }
}
