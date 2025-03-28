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
    // Automatically request permissions on first run
    await _notificationService.requestPermissions();
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

  Future<void> setNotificationsEnabled(bool enabled) async {
    if (_notificationsEnabled == enabled) return;

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
