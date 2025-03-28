import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/date_utils.dart';

class StreakGrid extends StatelessWidget {
  final Habit habit;
  final Function(DateTime)? onDayTap;
  final double? height;

  const StreakGrid({
    super.key,
    required this.habit,
    this.onDayTap,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    // Create a grid of days (like HabitKit)
    final int rows = 7;
    final int cols = 25;
    final int totalDays = rows * cols;

    return SizedBox(
      height: height ?? 80, // Use provided height or default to 80
      child: GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 25, // 25 columns like HabitKit
          crossAxisSpacing: 3, // Tighter spacing
          mainAxisSpacing: 3,
          childAspectRatio: 1,
        ),
        itemCount: totalDays,
        itemBuilder: (ctx, index) {
          // Calculate the date for this index (starting from oldest)
          final dayOffset = totalDays - 1 - index;
          final date = DateTime(today.year, today.month, today.day - dayOffset);

          final isCompleted = habit.completionDates[date] == true;
          final isToday = AppDateUtils.isSameDay(date, today);

          // Square cells with rounded corners like HabitKit
          return GestureDetector(
            onTap: onDayTap != null ? () => onDayTap!(date) : null,
            child: Container(
              decoration: BoxDecoration(
                color: isCompleted
                    ? habit.color.withOpacity(0.8)
                    : const Color(
                        0xFF222222), // Dark gray for non-completed days
                borderRadius:
                    BorderRadius.circular(2), // Slightly rounded corners
                border: isToday
                    ? Border.all(
                        color: Colors.white,
                        width: 1,
                      )
                    : null,
              ),
              // Add white dot in the center for completed days
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
            ),
          );
        },
      ),
    );
  }
}
