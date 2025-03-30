import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';

// Add a helper extension for AppTheme
extension AppThemeExtension on AppTheme {
  static bool isDarkMode(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark;
  }
}

class ProgressChart extends StatefulWidget {
  final List<Habit> habits;
  final List<DateTime> dates;
  final String habitId;

  const ProgressChart({
    super.key,
    required this.habits,
    required this.dates,
    required this.habitId,
  });

  @override
  State<ProgressChart> createState() => _ProgressChartState();
}

class _ProgressChartState extends State<ProgressChart> {
  late List<FlSpot> _spots;
  late double _maxY;
  late Color _lineColor;
  late Habit _habit;

  @override
  void initState() {
    super.initState();
    _updateChartData();
  }

  @override
  void didUpdateWidget(ProgressChart oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.habitId != widget.habitId ||
        oldWidget.habits != widget.habits ||
        oldWidget.dates != widget.dates) {
      _updateChartData();
    }
  }

  void _updateChartData() {
    _habit = widget.habits.firstWhere((h) => h.id == widget.habitId);
    _lineColor = _habit.color;
    _calculateSpots();
  }

  void _calculateSpots() {
    _spots = [];
    final Map<String, int> dateCompletionMap = {};

    // First calculate completions per date
    for (int i = 0; i < widget.dates.length; i++) {
      final date = widget.dates[i];
      final dateKey = DateFormat('yyyy-MM-dd').format(date);

      // Count completions for this date
      final dateTime = DateTime(date.year, date.month, date.day);
      final isCompleted = _habit.completionDates[dateTime] ?? false;
      final completions = isCompleted ? 1 : 0;

      dateCompletionMap[dateKey] = completions;
    }

    // Then create spots from the map
    int maxCompletions = 0;
    for (int i = 0; i < widget.dates.length; i++) {
      final date = widget.dates[i];
      final dateKey = DateFormat('yyyy-MM-dd').format(date);
      final completions = dateCompletionMap[dateKey] ?? 0;

      if (completions > maxCompletions) {
        maxCompletions = completions;
      }

      _spots.add(FlSpot(i.toDouble(), completions.toDouble()));
    }

    _maxY = maxCompletions > 0 ? (maxCompletions + 1).toDouble() : 1.0;
  }

  @override
  Widget build(BuildContext context) {
    if (_spots.isEmpty) {
      return const Center(child: Text('No data available'));
    }

    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white70 : Colors.black54;

    return RepaintBoundary(
      child: Padding(
        padding: const EdgeInsets.only(right: 16, top: 16),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: false,
              horizontalInterval: 1,
              getDrawingHorizontalLine: (value) {
                return FlLine(
                  color: isDarkMode ? Colors.white10 : Colors.black12,
                  strokeWidth: 1,
                );
              },
            ),
            titlesData: FlTitlesData(
              show: true,
              rightTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(showTitles: false),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 30,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value.toInt() < 0 ||
                        value.toInt() >= widget.dates.length) {
                      return const SizedBox.shrink();
                    }
                    final date = widget.dates[value.toInt()];
                    return Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Text(
                        DateFormat('d').format(date),
                        style: TextStyle(
                          color: textColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    );
                  },
                ),
              ),
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    if (value == 0) {
                      return const SizedBox.shrink();
                    }
                    return Text(
                      value.toInt().toString(),
                      style: TextStyle(
                        color: textColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    );
                  },
                  reservedSize: 40,
                ),
              ),
            ),
            borderData: FlBorderData(
              show: false,
            ),
            minX: 0,
            maxX: (widget.dates.length - 1).toDouble(),
            minY: 0,
            maxY: _maxY,
            lineBarsData: [
              LineChartBarData(
                spots: _spots,
                isCurved: true,
                color: _lineColor,
                barWidth: 3,
                isStrokeCapRound: true,
                dotData: FlDotData(
                  show: true,
                  getDotPainter: (spot, percent, barData, index) {
                    return FlDotCirclePainter(
                      radius: 4,
                      color: _lineColor,
                      strokeWidth: 1,
                      strokeColor: AppThemeExtension.isDarkMode(context)
                          ? Colors.black
                          : Colors.white,
                    );
                  },
                ),
                belowBarData: BarAreaData(
                  show: true,
                  color: _lineColor.withOpacity(0.2),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
