import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/icon_utils.dart';

class SharePreview extends StatelessWidget {
  final Habit habit;
  final VoidCallback onShare;
  final VoidCallback onCancel;

  const SharePreview({
    super.key,
    required this.habit,
    required this.onShare,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();
    final rows = 7;
    final cols = 20;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey[900]!),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Row(
              children: [
                const Text(
                  'STREAKS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                // Close button
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onCancel,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Habit info
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: habit.color.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    IconUtils.getIconData(habit.iconName),
                    color: habit.color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        habit.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (habit.description.isNotEmpty)
                        Text(
                          habit.description,
                          style: TextStyle(
                            color: Colors.grey[400],
                            fontSize: 14,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Streak visualization (mini version)
            AspectRatio(
              aspectRatio: 1.5,
              child: GridView.builder(
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 20, // 20 columns
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                  childAspectRatio: 1,
                ),
                itemCount: rows * cols,
                itemBuilder: (context, index) {
                  final dayOffset = (rows * cols) - 1 - index;
                  final date =
                      DateTime(today.year, today.month, today.day - dayOffset);

                  final isCompleted = habit.completionDates[date] == true;
                  final isToday = date.year == today.year &&
                      date.month == today.month &&
                      date.day == today.day;

                  return Container(
                    decoration: BoxDecoration(
                      color: isCompleted
                          ? habit.color.withOpacity(0.7)
                          : habit.color.withOpacity(0.15),
                      shape: BoxShape.circle,
                      border: isToday
                          ? Border.all(
                              color: habit.color,
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
            ),
            const SizedBox(height: 20),

            // Stats
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildStatColumn('Duration', '${_formatDuration(habit)}'),
                _buildStatColumn('Streak', '${habit.currentStreak}'),
                _buildStatColumn('Total', '${habit.totalCompletions}'),
              ],
            ),
            const SizedBox(height: 30),

            // Share button
            ElevatedButton(
              onPressed: onShare,
              style: ElevatedButton.styleFrom(
                backgroundColor: habit.color,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.share, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Share',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 4),
        Text(
          title,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  String _formatDuration(Habit habit) {
    final days = habit.totalCompletions;
    if (days < 60) {
      return '$days days';
    } else {
      final months = (days / 30).floor();
      return '$months months';
    }
  }
}
