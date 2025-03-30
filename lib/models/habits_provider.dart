import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'habit.dart';
import 'notification_manager.dart';
import '../services/premium_service.dart';

class HabitsProvider with ChangeNotifier {
  List<Habit> _habits = [];
  static const String _prefsKey = 'habits';
  bool _isLoading = true;

  HabitsProvider() {
    _loadHabits();
  }

  List<Habit> get habits => _habits;
  bool get isLoading => _isLoading;

  Future<void> _loadHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson = prefs.getStringList(_prefsKey);

      if (habitsJson != null) {
        _habits = habitsJson
            .map((habitJson) => Habit.fromJson(jsonDecode(habitJson)))
            .toList();
      }
    } catch (e) {
      print('Error loading habits: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _saveHabits() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final habitsJson =
          _habits.map((habit) => jsonEncode(habit.toJson())).toList();
      await prefs.setStringList(_prefsKey, habitsJson);
    } catch (e) {
      print('Error saving habits: $e');
    }
  }

  Future<bool> canAddHabit(BuildContext context) async {
    final premiumService = Provider.of<PremiumService>(context, listen: false);
    return premiumService.canAddMoreHabits(_habits.length);
  }

  Future<void> addHabit(Habit habit, {BuildContext? context}) async {
    if (context != null) {
      final premiumService =
          Provider.of<PremiumService>(context, listen: false);

      // Check if user can add more habits
      if (!premiumService.canAddMoreHabits(_habits.length)) {
        // Cannot add more habits as a free user
        throw Exception(
            'Free users can only create ${PremiumService.maxFreeHabits} habits. Upgrade to premium for unlimited habits.');
      }
    }

    _habits.add(habit);
    notifyListeners();
    await _saveHabits();

    // Schedule notification if context is provided
    if (context != null) {
      final notificationManager =
          Provider.of<NotificationManager>(context, listen: false);
      await notificationManager.updateHabitNotifications(habit);
    }
  }

  Future<void> updateHabit(Habit updatedHabit, {BuildContext? context}) async {
    final index = _habits.indexWhere((habit) => habit.id == updatedHabit.id);
    if (index != -1) {
      _habits[index] = updatedHabit;
      notifyListeners();
      await _saveHabits();

      // Update notification if context is provided
      if (context != null) {
        final notificationManager =
            Provider.of<NotificationManager>(context, listen: false);
        await notificationManager.updateHabitNotifications(updatedHabit);
      }
    }
  }

  Future<void> deleteHabit(String habitId, {BuildContext? context}) async {
    _habits.removeWhere((habit) => habit.id == habitId);
    notifyListeners();
    await _saveHabits();

    // Remove notifications if context is provided
    if (context != null) {
      final notificationManager =
          Provider.of<NotificationManager>(context, listen: false);
      await notificationManager.removeHabitNotifications(habitId);
    }
  }

  Future<void> toggleHabitCompletion(String habitId) async {
    final index = _habits.indexWhere((habit) => habit.id == habitId);
    if (index != -1) {
      final habit = _habits[index];
      final today = DateTime.now();
      final todayDate = DateTime(today.year, today.month, today.day);

      final completionDates = Map<DateTime, bool>.from(habit.completionDates);
      final isCompleted = habit.completionDates[todayDate] ?? false;

      completionDates[todayDate] = !isCompleted;

      _habits[index] = habit.copyWith(completionDates: completionDates);
      notifyListeners();
      await _saveHabits();
    }
  }

  Habit? getHabitById(String id) {
    try {
      return _habits.firstWhere((habit) => habit.id == id);
    } catch (e) {
      return null;
    }
  }
}
