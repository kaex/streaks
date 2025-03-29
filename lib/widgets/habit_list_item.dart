import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';
import '../screens/new_habit_screen.dart';

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

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        onLongPress: () {
          HapticFeedback.mediumImpact();
          _showOptionsBottomSheet(context);
        },
        borderRadius: BorderRadius.circular(16),
        splashColor: habit.color.withOpacity(0.1),
        highlightColor: habit.color.withOpacity(0.05),
        child: Ink(
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

                // Completion button with haptic feedback
                AnimatedCompletionButton(
                  isCompleted: habit.isCompletedToday(),
                  color: habit.color,
                  defaultColor: buttonEmptyColor,
                  onTap: () {
                    HapticFeedback.mediumImpact();
                    onToggle();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showOptionsBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.only(top: 12, bottom: 24),
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          ),
          child: SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Bottom sheet handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: isDarkMode ? Colors.grey[700] : Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                // Option buttons
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildOptionButton(
                        context: context,
                        icon: Icons.edit_outlined,
                        label: 'Edit',
                        color: Colors.blue,
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  NewHabitScreen(habitId: habit.id),
                            ),
                          );
                        },
                      ),
                      _buildOptionButton(
                        context: context,
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        color: Colors.red,
                        onTap: () {
                          Navigator.pop(context);
                          // Show deletion confirmation
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title: Text('Delete Habit'),
                              content: Text(
                                  'Are you sure you want to delete "${habit.title}"?'),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child: Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    // Delete the habit
                                    Navigator.pop(context);
                                    // Add habit deletion logic here
                                  },
                                  child: Text('Delete',
                                      style: TextStyle(color: Colors.red)),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildOptionButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: isDarkMode
                  ? const Color(0xFF252525)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
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

// Animated completion button widget with scale effect
class AnimatedCompletionButton extends StatefulWidget {
  final bool isCompleted;
  final Color color;
  final Color defaultColor;
  final VoidCallback onTap;

  const AnimatedCompletionButton({
    Key? key,
    required this.isCompleted,
    required this.color,
    required this.defaultColor,
    required this.onTap,
  }) : super(key: key);

  @override
  State<AnimatedCompletionButton> createState() =>
      _AnimatedCompletionButtonState();
}

class _AnimatedCompletionButtonState extends State<AnimatedCompletionButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isCompleted) {
      _animationController.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(AnimatedCompletionButton oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.isCompleted != oldWidget.isCompleted) {
      if (widget.isCompleted) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: 1.0 - (_scaleAnimation.value * 0.1),
            child: Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: widget.isCompleted ? widget.color : widget.defaultColor,
                borderRadius: BorderRadius.circular(8),
                boxShadow: widget.isCompleted
                    ? [
                        BoxShadow(
                          color: widget.color.withOpacity(0.4),
                          blurRadius: 4,
                          spreadRadius: 1,
                        )
                      ]
                    : null,
              ),
              child: Center(
                child: Icon(
                  Icons.check,
                  color: widget.isCompleted ? Colors.white : Colors.grey[600],
                  size: 20,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
