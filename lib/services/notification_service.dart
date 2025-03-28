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

    // Set local timezone
    final String timeZoneName = tz.local.name;
    tz.setLocalLocation(tz.getLocation(timeZoneName));

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
            '  - Scheduling for $dayName at ${habit.reminderTime!.hour}:${habit.reminderTime!.minute}');

        try {
          await _scheduleWeeklyNotification(
            habit.id.hashCode + i, // Unique ID for each day
            habit.id,
            'Time for ${habit.title}!',
            'Keep your streak going - ${habit.description}',
            _getDayOfWeek(i), // Convert our day index to Day enum
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
    Day day,
    TimeOfDay reminderTime,
  ) async {
    debugPrint(
        'Scheduling notification id=$id for day=${day.name} at ${reminderTime.hour}:${reminderTime.minute}');

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
        icon:
            'notification_icon', // This will fall back to the default app icon
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
      final scheduledDate = _nextInstanceOfDayTime(day, reminderTime);
      debugPrint('  Scheduled for: ${scheduledDate.toString()}');

      // Schedule the notification
      await flutterLocalNotificationsPlugin.zonedSchedule(
        id,
        title,
        body,
        scheduledDate,
        platformChannelSpecifics,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.dayOfWeekAndTime,
        payload: habitId,
      );

      debugPrint('  Notification scheduled successfully');
    } catch (e) {
      debugPrint('Error scheduling notification: $e');
      rethrow; // Rethrow to let the caller handle it
    }
  }

  // Calculate the next instance of a specific day and time
  tz.TZDateTime _nextInstanceOfDayTime(Day day, TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    debugPrint('Current time (local): ${now.toString()}');

    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    debugPrint('Initial scheduled date: ${scheduledDate.toString()}');
    debugPrint(
        'Target day: ${day.toString()}, Current weekday: ${scheduledDate.weekday}');

    // Calculate days until the target day
    int daysUntil = day.index - scheduledDate.weekday;
    debugPrint(
        'Initial daysUntil calculation: $daysUntil = ${day.index} - ${scheduledDate.weekday}');

    if (daysUntil < 0) {
      daysUntil += 7;
      debugPrint('daysUntil was negative, adding 7: $daysUntil');
    } else if (daysUntil == 0 &&
        (scheduledDate.hour > time.hour ||
            (scheduledDate.hour == time.hour &&
                scheduledDate.minute >= time.minute))) {
      daysUntil = 7;
      debugPrint(
          'daysUntil was 0 but time is in the past, adding 7: $daysUntil');
    }

    // Add the days until the target
    scheduledDate = scheduledDate.add(Duration(days: daysUntil));
    debugPrint('Final scheduled date: ${scheduledDate.toString()}');

    return scheduledDate;
  }

  // Convert our day index (0 = Monday) to Flutter's Day enum (1 = Monday)
  Day _getDayOfWeek(int dayIndex) {
    // Our indices: 0=Monday, 1=Tuesday, ..., 6=Sunday
    // Flutter's Day enum: 1=Monday, 2=Tuesday, ..., 7=Sunday

    // Day.monday => 1, Day.tuesday => 2, etc.
    // Need to map our 0-based index to Flutter's 1-based Day enum
    final Map<int, Day> dayMap = {
      0: Day.monday, // Monday
      1: Day.tuesday, // Tuesday
      2: Day.wednesday, // Wednesday
      3: Day.thursday, // Thursday
      4: Day.friday, // Friday
      5: Day.saturday, // Saturday
      6: Day.sunday, // Sunday
    };

    debugPrint('Converting day index $dayIndex to ${dayMap[dayIndex]}');
    return dayMap[dayIndex]!;
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

  // Show an immediate test notification
  Future<void> showTestNotification() async {
    debugPrint('Showing test notification');

    // Create notification details
    final AndroidNotificationDetails androidPlatformChannelSpecifics =
        AndroidNotificationDetails(
      'test_channel',
      'Test Notifications',
      channelDescription: 'Used for testing notifications',
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      color: Colors.red,
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

    try {
      // Show the notification immediately
      await flutterLocalNotificationsPlugin.show(
        0,
        'Test Notification',
        'This is a test notification from Streaks app.',
        platformChannelSpecifics,
        payload: 'test',
      );
      debugPrint('Test notification sent successfully');
    } catch (e) {
      debugPrint('Error showing test notification: $e');
    }
  }
}
