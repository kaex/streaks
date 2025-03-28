import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/habits_provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';

class HabitsDetailsView extends StatelessWidget {
  const HabitsDetailsView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, habitsProvider, child) {
        if (habitsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final habits = habitsProvider.habits;

        if (habits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.analytics_outlined,
                  size: 80,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'No habits to analyze',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Add some habits to see your stats',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          );
        }

        // Calculate some stats
        final totalHabits = habits.length;
        final completedToday = habits.where((h) => h.isCompletedToday()).length;
        final completionRate = totalHabits > 0
            ? (completedToday / totalHabits * 100).toStringAsFixed(0)
            : '0';

        // Get top habits by streak
        final topHabits = List.from(habits)
          ..sort((a, b) => b.currentStreak.compareTo(a.currentStreak));
        final topHabitsList = topHabits.take(5).toList();

        final isDarkMode = Theme.of(context).brightness == Brightness.dark;
        final headerTextColor =
            isDarkMode ? Colors.grey[200] : Colors.grey[800];

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Summary cards
              Row(
                children: [
                  _buildSummaryCard(
                    context,
                    'Total Habits',
                    totalHabits.toString(),
                    Icons.list_alt,
                    Colors.blue,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    context,
                    'Completed Today',
                    '$completedToday/$totalHabits',
                    Icons.check_circle,
                    Colors.green,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  _buildSummaryCard(
                    context,
                    'Completion Rate',
                    '$completionRate%',
                    Icons.pie_chart,
                    Colors.amber,
                  ),
                  const SizedBox(width: 12),
                  _buildSummaryCard(
                    context,
                    'Best Streak',
                    _getBestOverallStreak(habits).toString(),
                    Icons.local_fire_department,
                    Colors.deepOrange,
                  ),
                ],
              ),

              // Top habits section
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Text(
                  'Top Habits by Streak',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                ),
              ),
              ...topHabitsList
                  .map((habit) => _buildTopHabitItem(context, habit))
                  .toList(),

              // Weekly progress chart
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Text(
                  'Weekly Progress',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                ),
              ),
              _buildWeeklyProgressChart(context, habits),

              // Categories breakdown
              Padding(
                padding: const EdgeInsets.only(top: 24, bottom: 16),
                child: Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                ),
              ),
              _buildCategoriesBreakdown(context, habits),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              icon,
              color: color,
              size: 28,
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 14,
                color: subtitleColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHabitItem(BuildContext context, habit) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
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
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: habit.color.withOpacity(0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              IconUtils.getIconData(habit.iconName),
              color: habit.color,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  habit.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Started ${_getTimeAgo(habit.startDate)}',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.local_fire_department,
                    color: Colors.deepOrange,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    habit.currentStreak.toString(),
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                ],
              ),
              Text(
                'current streak',
                style: TextStyle(
                  fontSize: 12,
                  color: subtitleColor,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeeklyProgressChart(BuildContext context, habits) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final labelColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    // Get last 7 days
    final now = DateTime.now();
    final dates =
        List.generate(7, (i) => DateTime(now.year, now.month, now.day - i));

    // Count completions for each day
    final completions = dates.map((date) {
      return habits.where((h) {
        final dateStr = date.toIso8601String().split('T')[0];
        return h.completionDates.keys
                .map((d) => d.toIso8601String().split('T')[0])
                .contains(dateStr) &&
            h.completionDates[date] == true;
      }).length;
    }).toList();

    // Day labels
    final dayLabels = [
      'Today',
      'Yest.',
      ...dates.sublist(2, 7).map((d) =>
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][d.weekday - 1])
    ];

    return Container(
      height: 200,
      padding: const EdgeInsets.all(16),
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
      child: BarChart(
        BarChartData(
          barGroups: List.generate(7, (i) {
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: completions[i].toDouble(),
                  color: AppTheme.accentColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            );
          }),
          alignment: BarChartAlignment.spaceAround,
          maxY: habits.length.toDouble() + 2,
          titlesData: FlTitlesData(
            leftTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            rightTitles: AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        dayLabels[value.toInt()],
                        style: TextStyle(
                          color: labelColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }),
            ),
          ),
          borderData: FlBorderData(show: false),
          gridData: FlGridData(show: false),
        ),
      ),
    );
  }

  Widget _buildCategoriesBreakdown(BuildContext context, habits) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];
    final iconBackgroundColor =
        isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFEEEEEE);
    final iconColor = isDarkMode ? Colors.white : Colors.grey[800];

    // Get all categories
    final categoryCount = <String, int>{};

    for (final habit in habits) {
      if (habit.categories != null) {
        for (final category in habit.categories!) {
          categoryCount[category] = (categoryCount[category] ?? 0) + 1;
        }
      }
    }

    // Sort by count
    final sortedCategories = categoryCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    if (sortedCategories.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
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
        child: Center(
          child: Text(
            'No categories found',
            style: TextStyle(
              fontSize: 16,
              color: subtitleColor,
            ),
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
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
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: sortedCategories.length,
        itemBuilder: (context, index) {
          final entry = sortedCategories[index];
          final percentage =
              (entry.value / habits.length * 100).toStringAsFixed(0);

          IconData? icon;
          switch (entry.key) {
            case 'Fitness':
              icon = Icons.directions_bike;
              break;
            case 'Health':
              icon = Icons.favorite;
              break;
            case 'Nutrition':
              icon = Icons.restaurant;
              break;
            case 'Art':
              icon = Icons.brush;
              break;
            case 'Finances':
              icon = Icons.attach_money;
              break;
            case 'Social':
              icon = Icons.people;
              break;
            case 'Study':
              icon = Icons.school;
              break;
            case 'Work':
              icon = Icons.work;
              break;
            case 'Morning':
              icon = Icons.wb_sunny;
              break;
            case 'Day':
              icon = Icons.wb_cloudy;
              break;
            case 'Evening':
              icon = Icons.nights_stay;
              break;
            case 'Other':
              icon = Icons.apps;
              break;
          }

          // Center container for single category
          if (sortedCategories.length == 1) {
            return Center(
              child: Container(
                width: MediaQuery.of(context).size.width * 0.9,
                padding: const EdgeInsets.symmetric(vertical: 12.0),
                child: Row(
                  children: [
                    if (icon != null)
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: iconBackgroundColor,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          icon,
                          color: iconColor,
                          size: 20,
                        ),
                      ),
                    if (icon != null) const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          fontSize: 16,
                          color: textColor,
                        ),
                      ),
                    ),
                    Text(
                      '${entry.value} habits',
                      style: TextStyle(
                        fontSize: 14,
                        color: subtitleColor,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AppTheme.accentColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        '$percentage%',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.accentColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Regular list item for multiple categories
          return Padding(
            padding: const EdgeInsets.only(bottom: 12.0),
            child: Row(
              children: [
                if (icon != null)
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: iconBackgroundColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      icon,
                      color: iconColor,
                      size: 20,
                    ),
                  ),
                if (icon != null) const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    entry.key,
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                ),
                Text(
                  '${entry.value} habits',
                  style: TextStyle(
                    fontSize: 14,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: AppTheme.accentColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.accentColor,
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  int _getBestOverallStreak(habits) {
    if (habits.isEmpty) return 0;
    return habits.map((h) => h.bestStreak).reduce((a, b) => a > b ? a : b);
  }

  String _getTimeAgo(DateTime dateTime) {
    final difference = DateTime.now().difference(dateTime);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} years ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} months ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} days ago';
    } else {
      return 'today';
    }
  }
}
