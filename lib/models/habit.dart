import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

class Habit {
  final String id;
  final String title;
  final String description;
  final DateTime startDate;
  final List<bool> reminderDays; // [Monday, Tuesday, ..., Sunday]
  final TimeOfDay? reminderTime;
  final String interval; // 'daily', 'weekly', etc.
  final Color color;
  final String iconName;
  final Map<DateTime, bool> completionDates;
  final int streakGoal;
  final List<String>? categories; // Categories for habit classification

  Habit({
    String? id,
    required this.title,
    this.description = '',
    DateTime? startDate,
    List<bool>? reminderDays,
    this.reminderTime,
    this.interval = 'daily',
    Color? color,
    this.iconName = 'book',
    Map<DateTime, bool>? completionDates,
    this.streakGoal = 1,
    this.categories,
  })  : id = id ?? const Uuid().v4(),
        startDate = startDate ?? DateTime.now(),
        reminderDays = reminderDays ?? List.filled(7, false),
        color = color ?? Colors.red,
        completionDates = completionDates ?? {};

  int get currentStreak {
    if (completionDates.isEmpty) return 0;

    int streak = 0;
    DateTime today = DateTime.now();
    DateTime date = DateTime(today.year, today.month, today.day);

    while (true) {
      bool completed = completionDates[date] ?? false;
      if (!completed) break;
      streak++;
      date = date.subtract(const Duration(days: 1));
    }

    return streak;
  }

  int get bestStreak {
    if (completionDates.isEmpty) return 0;

    int maxStreak = 0;
    int currentMaxStreak = 0;

    // Sort dates
    List<DateTime> sortedDates = completionDates.keys.toList()
      ..sort((a, b) => a.compareTo(b));

    DateTime? prevDate;

    for (var date in sortedDates) {
      if (completionDates[date] == true) {
        if (prevDate == null || date.difference(prevDate).inDays == 1) {
          currentMaxStreak++;
        } else {
          currentMaxStreak = 1;
        }

        if (currentMaxStreak > maxStreak) {
          maxStreak = currentMaxStreak;
        }

        prevDate = date;
      }
    }

    return maxStreak;
  }

  int get totalCompletions {
    return completionDates.values.where((completed) => completed).length;
  }

  bool isCompletedToday() {
    final today = DateTime.now();
    final todayDate = DateTime(today.year, today.month, today.day);
    return completionDates[todayDate] == true;
  }

  Habit copyWith({
    String? title,
    String? description,
    DateTime? startDate,
    List<bool>? reminderDays,
    TimeOfDay? reminderTime,
    String? interval,
    Color? color,
    String? iconName,
    Map<DateTime, bool>? completionDates,
    int? streakGoal,
    List<String>? categories,
  }) {
    return Habit(
      id: this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      reminderDays: reminderDays ?? List.from(this.reminderDays),
      reminderTime: reminderTime ?? this.reminderTime,
      interval: interval ?? this.interval,
      color: color ?? this.color,
      iconName: iconName ?? this.iconName,
      completionDates: completionDates ?? Map.from(this.completionDates),
      streakGoal: streakGoal ?? this.streakGoal,
      categories: categories ?? this.categories,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'reminderDays': reminderDays,
      'reminderTime': reminderTime != null
          ? {'hour': reminderTime!.hour, 'minute': reminderTime!.minute}
          : null,
      'interval': interval,
      'color': color.value,
      'iconName': iconName,
      'completionDates': completionDates.map(
        (key, value) => MapEntry(key.toIso8601String(), value),
      ),
      'streakGoal': streakGoal,
      'categories': categories,
    };
  }

  factory Habit.fromJson(Map<String, dynamic> json) {
    final reminderTimeJson = json['reminderTime'];
    final TimeOfDay? reminderTime = reminderTimeJson != null
        ? TimeOfDay(
            hour: reminderTimeJson['hour'],
            minute: reminderTimeJson['minute'],
          )
        : null;

    final completionDatesJson = json['completionDates'] as Map<String, dynamic>;
    final completionDates = completionDatesJson.map(
      (key, value) => MapEntry(DateTime.parse(key), value as bool),
    );

    return Habit(
      id: json['id'],
      title: json['title'],
      description: json['description'],
      startDate: DateTime.parse(json['startDate']),
      reminderDays: List<bool>.from(json['reminderDays']),
      reminderTime: reminderTime,
      interval: json['interval'],
      color: Color(json['color']),
      iconName: json['iconName'],
      completionDates: completionDates,
      streakGoal: json['streakGoal'],
      categories: json['categories'] != null
          ? List<String>.from(json['categories'])
          : null,
    );
  }
}
