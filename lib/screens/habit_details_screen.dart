import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habits_provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';
import '../utils/share_utils.dart';
import '../widgets/highlight_card.dart';
import '../widgets/progress_chart.dart';
import '../widgets/streak_grid.dart';
import 'new_habit_screen.dart';
import 'share_customization_screen.dart';

class HabitDetailsScreen extends StatelessWidget {
  final String habitId;

  const HabitDetailsScreen({
    super.key,
    required this.habitId,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, habitsProvider, child) {
        final habit = habitsProvider.getHabitById(habitId);
        final isDarkMode = Theme.of(context).brightness == Brightness.dark;

        // Theme-aware colors
        final scaffoldBackgroundColor =
            isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
        final cardBackgroundColor =
            isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
        final textColor = isDarkMode ? Colors.white : Colors.black;
        final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
        final streakEmptyColor =
            isDarkMode ? const Color(0xFF252525) : const Color(0xFFEEEEEE);

        if (habit == null) {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Habit Details'),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ),
            body: const Center(
              child: Text('Habit not found'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: scaffoldBackgroundColor,
            scrolledUnderElevation: 0, // Prevent color change when scrolling
            elevation: 0,
            title: Text(
              'Habits',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: textColor),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              // More options
              IconButton(
                icon: Icon(Icons.more_horiz, color: textColor),
                onPressed: () {
                  _showOptionsMenu(context, habit, habitsProvider);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Last 365 days label
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Text(
                    'LAST 365 DAYS',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                // Main habit card with full-width streak grid
                Container(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(20),
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Habit info row
                      Row(
                        children: [
                          // Icon container
                          Container(
                            height: 48,
                            width: 48,
                            decoration: BoxDecoration(
                              color: habit.color.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              IconUtils.getIconData(habit.iconName),
                              color: habit.color,
                              size: 24,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Habit details
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  habit.title,
                                  style: TextStyle(
                                    fontSize:
                                        habit.description.isEmpty ? 24 : 20,
                                    fontWeight: FontWeight.bold,
                                    color: textColor,
                                  ),
                                ),
                                if (habit.description.isNotEmpty) ...[
                                  const SizedBox(height: 4),
                                  Text(
                                    habit.description,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: subtitleColor,
                                    ),
                                  ),
                                ] else
                                  const SizedBox(height: 2),
                              ],
                            ),
                          ),
                          // Completion button
                          GestureDetector(
                            onTap: () {
                              habitsProvider.toggleHabitCompletion(habitId);
                            },
                            child: Container(
                              height: 48,
                              width: 48,
                              decoration: BoxDecoration(
                                color: habit.isCompletedToday()
                                    ? habit.color
                                    : streakEmptyColor,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: habit.isCompletedToday()
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
                      const SizedBox(height: 24),

                      // Streak grid - using squares like HabitKit
                      SizedBox(
                        height: 180, // Taller grid
                        child: GridView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 20, // 20 columns as in the image
                            crossAxisSpacing: 3, // Slightly less spacing
                            mainAxisSpacing: 3, // Slightly less spacing
                            childAspectRatio: 1,
                          ),
                          itemCount: 200, // 10 rows x 20 columns
                          itemBuilder: (ctx, index) {
                            // Calculate the date for this index (starting from oldest)
                            final today = DateTime.now();
                            final dayOffset = 200 - 1 - index;
                            final date = DateTime(
                                today.year, today.month, today.day - dayOffset);

                            final isCompleted =
                                habit.completionDates[date] == true;
                            final isToday = date.year == today.year &&
                                date.month == today.month &&
                                date.day == today.day;

                            return Container(
                              decoration: BoxDecoration(
                                color: isCompleted
                                    ? habit.color.withOpacity(0.8)
                                    : streakEmptyColor,
                                borderRadius: BorderRadius.circular(
                                    2), // Square with slightly rounded corners
                              ),
                              child: isToday && isCompleted
                                  ? Center(
                                      child: Container(
                                        width: 4,
                                        height: 4,
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
                      ),
                    ],
                  ),
                ),

                // Share Button
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
                  child: SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ShareCustomizationScreen(habit: habit),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: habit.color,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(24),
                        ),
                      ),
                      child: const Text(
                        'Share',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ),

                // Highlights section
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  child: Text(
                    'HIGHLIGHTS',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
                  ),
                ),

                // Highlights cards - 2x2 grid
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          // Current Streak
                          Expanded(
                            child: HighlightCard(
                              title: 'Current Streak',
                              value: '${habit.currentStreak}',
                              leading: Icon(
                                Icons.local_fire_department,
                                color: habit.color,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6), // Reduced spacing
                          // Best Streak
                          Expanded(
                            child: HighlightCard(
                              title: 'Best Streak',
                              value: '${habit.bestStreak}',
                              leading: Icon(
                                Icons.emoji_events,
                                color: habit.color,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6), // Reduced spacing
                      Row(
                        children: [
                          // Completion
                          Expanded(
                            child: HighlightCard(
                              title: 'Completion',
                              value: '${habit.totalCompletions}',
                              leading: Icon(
                                Icons.check_rounded,
                                color: habit.color,
                                size: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6), // Reduced spacing
                          // Streak Goal
                          Expanded(
                            child: HighlightCard(
                              title: 'Streak Goal',
                              value: 'Daily',
                              leading: Icon(
                                Icons.track_changes,
                                color: habit.color,
                                size: 24,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Progress Chart
                const SizedBox(height: 6),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: ProgressChart(
                    habits: [habit],
                    dates: List.generate(
                      30,
                      (index) =>
                          DateTime.now().subtract(Duration(days: 29 - index)),
                    ),
                    habitId: habit.id,
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showOptionsMenu(
      BuildContext context, Habit habit, HabitsProvider habitsProvider) {
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
                ListTile(
                  leading: Icon(Icons.edit,
                      color: isDarkMode ? Colors.white : Colors.grey[800]),
                  title: Text('Edit Habit', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => NewHabitScreen(habitId: habitId),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: Icon(Icons.share,
                      color: isDarkMode ? Colors.white : Colors.grey[800]),
                  title: Text('Share', style: TextStyle(color: textColor)),
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            ShareCustomizationScreen(habit: habit),
                      ),
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.delete, color: Colors.red),
                  title: const Text('Delete Habit',
                      style: TextStyle(color: Colors.red)),
                  onTap: () {
                    Navigator.pop(context);
                    _showDeleteConfirmation(context, habitsProvider, habit);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showDeleteConfirmation(
      BuildContext context, HabitsProvider habitsProvider, Habit habit) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Habit'),
          content: Text(
            'Are you sure you want to delete "${habit.title}"? This action cannot be undone.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                habitsProvider.deleteHabit(habitId, context: context);
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Go back to habits list
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }
}
