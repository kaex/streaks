import 'package:intl/intl.dart';

class AppDateUtils {
  static String formatDate(DateTime date) {
    return DateFormat('dd MMM yyyy').format(date);
  }

  static String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  static String formatMonthShort(DateTime date) {
    return DateFormat('MMM').format(date);
  }

  static DateTime today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static bool isSameDay(DateTime date1, DateTime date2) {
    return date1.year == date2.year &&
        date1.month == date2.month &&
        date1.day == date2.day;
  }

  static List<DateTime> getDaysInMonth(DateTime date) {
    final firstDayOfMonth = DateTime(date.year, date.month, 1);
    final lastDayOfMonth = DateTime(date.year, date.month + 1, 0);

    final days = <DateTime>[];
    for (int i = 0; i < lastDayOfMonth.day; i++) {
      days.add(firstDayOfMonth.add(Duration(days: i)));
    }

    return days;
  }

  static List<DateTime> getLast365Days() {
    final today = DateTime.now();
    final days = <DateTime>[];

    for (int i = 365; i >= 0; i--) {
      final date = DateTime(today.year, today.month, today.day - i);
      days.add(date);
    }

    return days;
  }

  static Map<String, int> getMonthLabelsForLast3Months() {
    final today = DateTime.now();
    final months = <String, int>{};

    for (int i = 2; i >= 0; i--) {
      final date = DateTime(today.year, today.month - i, 1);
      final monthLabel = DateFormat('MMM').format(date).toUpperCase();
      months[monthLabel] = date.month;
    }

    return months;
  }

  static String getDayOfWeek(int weekday) {
    const days = ['Mo', 'Tu', 'We', 'Th', 'Fr', 'Sa', 'Su'];
    return days[weekday - 1];
  }
}
