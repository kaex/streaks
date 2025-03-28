import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/notification_manager.dart';
import '../models/habits_provider.dart';
import '../theme/app_theme.dart';
import 'new_habit_screen.dart';

class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final notificationManager = Provider.of<NotificationManager>(context);
    final habitsProvider = Provider.of<HabitsProvider>(context);
    final habits = habitsProvider.habits;

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
    final cardColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        title: Text(
          'Notification Settings',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Master switch
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(16),
                boxShadow: isDarkMode
                    ? null
                    : [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
              ),
              child: SwitchListTile(
                title: Text(
                  'Enable Notifications',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: textColor,
                  ),
                ),
                subtitle: Text(
                  'Turn off to disable all habit reminders',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
                value: notificationManager.notificationsEnabled,
                activeColor: AppTheme.accentColor,
                onChanged: (value) {
                  notificationManager.setNotificationsEnabled(value);

                  if (value) {
                    // Show snackbar with message that notifications have been enabled
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Notifications enabled! Your habit reminders have been scheduled.'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );

                    // Reschedule all habit notifications
                    _rescheduleAllNotifications(context, habitsProvider.habits);
                  } else {
                    // Show snackbar with message that notifications have been disabled
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text(
                            'Notifications disabled! You won\'t receive any reminders.'),
                        duration: const Duration(seconds: 3),
                        action: SnackBarAction(
                          label: 'OK',
                          onPressed: () {},
                        ),
                      ),
                    );
                  }
                },
              ),
            ),
          ),

          // Habits with reminders section
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'HABITS WITH REMINDERS',
              style: TextStyle(
                color: AppTheme.accentColor,
                fontSize: 12,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.0,
              ),
            ),
          ),

          Expanded(
            child: ListView.builder(
              itemCount: habits.length,
              padding: const EdgeInsets.all(16),
              itemBuilder: (context, index) {
                final habit = habits[index];

                // Only show habits that have reminder settings
                if (habit.reminderTime == null ||
                    !habit.reminderDays.contains(true)) {
                  return const SizedBox.shrink();
                }

                // Format reminder days
                final List<String> dayNames = [
                  'Mon',
                  'Tue',
                  'Wed',
                  'Thu',
                  'Fri',
                  'Sat',
                  'Sun'
                ];
                final List<String> selectedDays = [];
                for (int i = 0; i < habit.reminderDays.length; i++) {
                  if (habit.reminderDays[i]) {
                    selectedDays.add(dayNames[i]);
                  }
                }

                // Format time
                final String timeStr = habit.reminderTime != null
                    ? _formatTime(habit.reminderTime!)
                    : 'No time set';

                final String reminderText =
                    '${selectedDays.join(', ')} at $timeStr';

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: cardColor,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: isDarkMode
                        ? null
                        : [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(16),
                    leading: Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: habit.color.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        Icons.notifications_active,
                        color: habit.color,
                        size: 24,
                      ),
                    ),
                    title: Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 4.0),
                      child: Text(
                        reminderText,
                        style: TextStyle(
                          fontSize: 14,
                          color: subtitleColor,
                        ),
                      ),
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.edit, color: AppTheme.accentColor),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                NewHabitScreen(habitId: habit.id),
                          ),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _rescheduleAllNotifications(
      BuildContext context, List<dynamic> habits) async {
    final notificationManager =
        Provider.of<NotificationManager>(context, listen: false);

    for (final habit in habits) {
      if (habit.reminderTime != null && habit.reminderDays.contains(true)) {
        await notificationManager.updateHabitNotifications(habit);
      }
    }
  }
}
