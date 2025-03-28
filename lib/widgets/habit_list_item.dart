import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';

class HabitListItem extends StatelessWidget {
  final Habit habit;
  final VoidCallback onTap;
  final VoidCallback onToggle;

  const HabitListItem({
    Key? key,
    required this.habit,
    required this.onTap,
    required this.onToggle,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final iconData = IconUtils.getIconData(habit.iconName);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final buttonEmptyColor =
        isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    final iconDisabledColor = isDarkMode ? Colors.grey[600] : Colors.grey[400];
    final statIconColor = isDarkMode ? Colors.grey[500] : Colors.grey[600];
    final statTextColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: cardBackgroundColor,
          borderRadius: BorderRadius.circular(16),
          boxShadow: !isDarkMode
              ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Habit icon
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: habit.color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  iconData,
                  color: habit.color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),

              // Habit information
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      habit.title,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: textColor,
                      ),
                    ),
                    if (habit.description.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          habit.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: 14,
                            color: subtitleColor,
                          ),
                        ),
                      ),

                    // Stats row
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Row(
                        children: [
                          // Current streak
                          _buildStat(
                              Icons.local_fire_department,
                              habit.currentStreak.toString(),
                              'Current streak',
                              statIconColor,
                              statTextColor),
                          const SizedBox(width: 16),
                          // Best streak
                          _buildStat(
                              Icons.emoji_events,
                              habit.bestStreak.toString(),
                              'Best streak',
                              statIconColor,
                              statTextColor),
                          const SizedBox(width: 16),
                          // Total completions
                          _buildStat(
                              Icons.check_circle_outline,
                              habit.totalCompletions.toString(),
                              'Total completions',
                              statIconColor,
                              statTextColor),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Completion button
              GestureDetector(
                onTap: onToggle,
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: habit.isCompletedToday()
                        ? habit.color
                        : buttonEmptyColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: habit.isCompletedToday()
                          ? Colors.white
                          : iconDisabledColor,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStat(IconData icon, String value, String tooltip,
      Color? iconColor, Color? textColor) {
    return Tooltip(
      message: tooltip,
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: iconColor,
          ),
          const SizedBox(width: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 14,
              color: textColor,
            ),
          ),
        ],
      ),
    );
  }
}
