import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/habit.dart';
import '../services/notification_service.dart';

class NotificationManager extends ChangeNotifier {
  bool _notificationsEnabled = true;
  static const String _notificationsEnabledKey = 'notificationsEnabled';
  late Future<void> initialized;
  final NotificationService _notificationService = NotificationService();

  bool get notificationsEnabled => _notificationsEnabled;

  NotificationManager() {
    initialized = _init();
  }

  Future<void> _init() async {
    await _loadSettings();
    await _notificationService.init();

    if (_notificationsEnabled) {
      // Request permissions if notifications are enabled by default
      final permissionGranted = await _notificationService.requestPermissions();

      // If permissions were denied but we're trying to enable notifications by default,
      // update our state to match reality
      if (!permissionGranted && _notificationsEnabled) {
        _notificationsEnabled = false;
        // Save this state silently
        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setBool(_notificationsEnabledKey, false);
        } catch (e) {
          debugPrint('Error saving notification settings: $e');
        }
      }
    }
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _notificationsEnabled = prefs.getBool(_notificationsEnabledKey) ?? true;
    } catch (e) {
      // Default to notifications being enabled
      _notificationsEnabled = true;
    }
  }

  Future<void> setNotificationsEnabled(
      bool enabled, BuildContext context) async {
    if (_notificationsEnabled == enabled) return;

    // If enabling notifications, request permissions first
    if (enabled) {
      bool permissionGranted = await _notificationService.requestPermissions();
      if (!permissionGranted) {
        // If permissions were denied, don't enable notifications and show guidance
        debugPrint('Notification permissions denied');

        // Show a dialog explaining how to enable permissions
        if (context.mounted) {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text('Permission Required'),
                content: const Text(
                  'Notifications permission was denied. To enable notifications, please go to your device settings and grant notification permission to the app.',
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _notificationService.requestPermissions();
                    },
                    child: const Text('Try Again'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ],
              );
            },
          );
        }
        return;
      }
    }

    _notificationsEnabled = enabled;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_notificationsEnabledKey, enabled);

      if (!enabled) {
        // Cancel all notifications if they're disabled
        await _notificationService.cancelAllNotifications();
      }
    } catch (e) {
      debugPrint('Error saving notification settings: $e');
    }
  }

  // Called when a habit is added or updated
  Future<void> updateHabitNotifications(Habit habit) async {
    if (!_notificationsEnabled) return;

    await _notificationService.scheduleHabitNotifications(habit);
  }

  // Called when a habit is deleted
  Future<void> removeHabitNotifications(String habitId) async {
    await _notificationService.cancelHabitNotifications(habitId);
  }
}
