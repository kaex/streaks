import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tz_data;
import '../models/habit.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Initialize time zones
    tz_data.initializeTimeZones();

    // Set up Android initialization settings
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('@mipmap/launcher_icon');

    // Set up iOS initialization settings
    final DarwinInitializationSettings initializationSettingsIOS =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
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
      },
    );
  }

  // Request permission for iOS
  Future<bool> requestPermissions() async {
    final bool? result = await flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<
            IOSFlutterLocalNotificationsPlugin>()
        ?.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
    return result ?? false;
  }

  // Schedule notifications for a specific habit
  Future<void> scheduleHabitNotifications(Habit habit) async {
    // Cancel any existing notifications for this habit
    await cancelHabitNotifications(habit.id);

    // If there's no reminder time or no days selected, don't schedule
    if (habit.reminderTime == null || !habit.reminderDays.contains(true)) {
      return;
    }

    // For each selected day, schedule a notification
    for (int i = 0; i < habit.reminderDays.length; i++) {
      if (habit.reminderDays[i]) {
        await _scheduleWeeklyNotification(
          habit.id.hashCode + i, // Unique ID for each day
          habit.id,
          'Time for ${habit.title}!',
          'Keep your streak going - ${habit.description}',
          _getDayOfWeek(i), // Convert our day index to Day enum
          habit.reminderTime!,
        );
      }
    }
  }

  // Schedule a weekly notification for a specific day
  Future<void> _scheduleWeeklyNotification(
    int id,
    String habitId,
    String title,
    String body,
    Day day,
    TimeOfDay reminderTime,
  ) async {
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
      icon: '@mipmap/launcher_icon',
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

    // Schedule the notification
    await flutterLocalNotificationsPlugin.zonedSchedule(
      id,
      title,
      body,
      _nextInstanceOfDayTime(day, reminderTime),
      platformChannelSpecifics,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
      payload: habitId,
    );
  }

  // Calculate the next instance of a specific day and time
  tz.TZDateTime _nextInstanceOfDayTime(Day day, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Calculate days until the target day
    int daysUntil = day.index - scheduledDate.weekday + 1;
    if (daysUntil < 0) {
      daysUntil += 7;
    } else if (daysUntil == 0 &&
        (scheduledDate.hour > time.hour ||
            (scheduledDate.hour == time.hour &&
                scheduledDate.minute >= time.minute))) {
      daysUntil = 7;
    }

    // Add the days until the target
    scheduledDate = scheduledDate.add(Duration(days: daysUntil));

    return scheduledDate;
  }

  // Convert our day index (0 = Monday) to Flutter's Day enum (1 = Monday)
  Day _getDayOfWeek(int dayIndex) {
    // Our indices: 0=Monday, 1=Tuesday, ..., 6=Sunday
    // Flutter's Day enum: 1=Monday, 2=Tuesday, ..., 7=Sunday
    return Day.values[dayIndex];
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
