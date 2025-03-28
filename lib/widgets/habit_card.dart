import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/icon_utils.dart';
import '../theme/app_theme.dart';

class HabitCard extends StatelessWidget {
  final Habit habit;
  final Function(String) onToggleCompletion;
  final Function(String) onTap;
  final Function(String)? onDelete;
  final Function(String)? onEdit;

  const HabitCard({
    super.key,
    required this.habit,
    required this.onToggleCompletion,
    required this.onTap,
    this.onDelete,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    final isCompleted = habit.isCompletedToday();
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Theme-aware colors
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF151515) : Colors.white;
    final iconBackgroundColor =
        isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF5F5F5);
    final completionDefaultColor =
        isDarkMode ? const Color(0xFF252525) : const Color(0xFFEEEEEE);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final streakEmptyColor =
        isDarkMode ? const Color(0xFF222222) : const Color(0xFFEEEEEE);
    final streakBorderColor =
        isDarkMode ? Colors.white : const Color(0xFFF5F5F5);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: GestureDetector(
        onTap: () => onTap(habit.id),
        onLongPress: () => _showOptionsBottomSheet(context),
        child: Container(
          decoration: BoxDecoration(
            color: cardBackgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: !isDarkMode
                ? [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    )
                  ]
                : null,
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    // Habit Icon (square with rounded corners like HabitKit)
                    Container(
                      height: 60,
                      width: 60,
                      decoration: BoxDecoration(
                        color: iconBackgroundColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Icon(
                        IconUtils.getIconData(habit.iconName),
                        color: habit.color,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Habit Details
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
                          const SizedBox(height: 4),
                          Text(
                            habit.description.isNotEmpty
                                ? habit.description
                                : "Read for 15 minutes",
                            style: TextStyle(
                              fontSize: 14,
                              color: subtitleColor,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),

                    // Completion Button (square with rounded corners like HabitKit)
                    GestureDetector(
                      onTap: () => onToggleCompletion(habit.id),
                      child: Container(
                        height: 48,
                        width: 48,
                        decoration: BoxDecoration(
                          color: isCompleted
                              ? habit.color
                              : completionDefaultColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: isCompleted
                            ? const Icon(
                                Icons.check_rounded,
                                color: Colors.white,
                                size: 28,
                              )
                            : null,
                      ),
                    ),
                  ],
                ),
              ),

              // Streak Grid
              Padding(
                padding: const EdgeInsets.only(
                    left: 16.0, right: 16.0, bottom: 16.0),
                child: _buildStreakGrid(
                    habit, streakEmptyColor, streakBorderColor),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStreakGrid(Habit habit, Color emptyColor, Color borderColor) {
    final today = DateTime.now();

    // Create a grid of days like HabitKit (more compact)
    final int rows = 4;
    final int cols = 25;

    return SizedBox(
      height: 70, // Increased height for better visibility
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 25, // More columns like HabitKit
          crossAxisSpacing: 3, // Tighter spacing
          mainAxisSpacing: 3, // Tighter spacing
          childAspectRatio: 1,
        ),
        itemCount: rows * cols,
        itemBuilder: (context, index) {
          // Calculate the date for this index (starting from oldest)
          final dayOffset = rows * cols - 1 - index;
          final date = DateTime(today.year, today.month, today.day - dayOffset);

          final isCompleted = habit.completionDates[date] == true;
          final isToday = date.year == today.year &&
              date.month == today.month &&
              date.day == today.day;

          // Use square with rounded corners for grid cells
          return Container(
            width: 5,
            height: 5,
            decoration: BoxDecoration(
              color: isCompleted ? habit.color.withOpacity(0.8) : emptyColor,
              borderRadius:
                  BorderRadius.circular(2), // Slightly rounded corners
              border: isToday
                  ? Border.all(
                      color: borderColor,
                      width: 1,
                    )
                  : null,
            ),
            child: isCompleted
                ? Center(
                    child: Container(
                      width: 2,
                      height: 2,
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                    ),
                  )
                : null,
          );
        },
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (onEdit != null)
                  ListTile(
                    leading: Icon(Icons.edit,
                        color: isDarkMode ? Colors.white : Colors.grey[800]),
                    title:
                        Text('Edit Habit', style: TextStyle(color: textColor)),
                    onTap: () {
                      Navigator.pop(context);
                      onEdit!(habit.id);
                    },
                  ),
                if (onDelete != null)
                  ListTile(
                    leading: Icon(Icons.delete, color: Colors.red),
                    title: Text('Delete', style: TextStyle(color: Colors.red)),
                    onTap: () {
                      Navigator.pop(context);
                      onDelete!(habit.id);
                    },
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
