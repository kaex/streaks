import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../utils/date_utils.dart';

class ProgressChart extends StatelessWidget {
  final Habit habit;

  const ProgressChart({
    super.key,
    required this.habit,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final monthLabels = AppDateUtils.getMonthLabelsForLast3Months();
    final last3Months = monthLabels.keys.toList();

    // Theme-aware colors
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final gridLineColor = isDarkMode
        ? Colors.grey.withOpacity(0.15)
        : Colors.grey.withOpacity(0.25);
    final textColor = isDarkMode ? Colors.grey[400] : Colors.grey[600];
    final tooltipBgColor = isDarkMode
        ? Colors.black.withOpacity(0.8)
        : Colors.white.withOpacity(0.9);
    final tooltipTextColor =
        isDarkMode ? habit.color : habit.color.withOpacity(0.8);

    // Create data points for the chart
    final completionData = _createCompletionData();

    // Calculate max Y value with a small buffer
    final maxY = completionData.isEmpty
        ? 1.0
        : (completionData.map((e) => e.y).reduce((a, b) => a > b ? a : b) + 1);

    return Container(
      height: 240,
      padding: const EdgeInsets.all(16),
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
      child: LineChart(
        LineChartData(
          backgroundColor: cardBackgroundColor,
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            checkToShowHorizontalLine: (value) => value % 1 == 0,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: gridLineColor,
                strokeWidth: 0.5,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return FlLine(
                color: gridLineColor,
                strokeWidth: 0.5,
                dashArray: [5, 5],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  if (value == completionData.last.x) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: habit.color.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          maxY.toInt().toString(),
                          style: TextStyle(
                            color: habit.color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 30,
              ),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (double value, TitleMeta meta) {
                  if (value.toInt() >= 0 &&
                      value.toInt() < last3Months.length) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        last3Months[value.toInt()],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 14,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  // Only show 0 and max value
                  if (value == 0 || value == maxY.floor()) {
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      child: Text(
                        value.toInt().toString(),
                        style: TextStyle(
                          color: textColor,
                          fontSize: 12,
                        ),
                      ),
                    );
                  }
                  return const SizedBox.shrink();
                },
                reservedSize: 20,
              ),
            ),
          ),
          borderData: FlBorderData(
            show: false,
          ),
          minX: 0,
          maxX: last3Months.length.toDouble() - 1,
          minY: 0,
          maxY: maxY,
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: tooltipBgColor,
              getTooltipItems: (touchedSpots) {
                return touchedSpots.map((spot) {
                  final month = last3Months[spot.x.toInt()];
                  return LineTooltipItem(
                    '${spot.y.toInt()} in $month',
                    TextStyle(
                      color: tooltipTextColor,
                      fontWeight: FontWeight.bold,
                    ),
                  );
                }).toList();
              },
            ),
            touchSpotThreshold: 20,
            getTouchedSpotIndicator: (barData, spotIndexes) {
              return spotIndexes.map((spotIndex) {
                return TouchedSpotIndicatorData(
                  FlLine(
                    color: habit.color,
                    strokeWidth: 2,
                    dashArray: [3, 3],
                  ),
                  FlDotData(
                    getDotPainter: (spot, percent, barData, index) {
                      return FlDotCirclePainter(
                        radius: 6,
                        color: habit.color,
                        strokeWidth: 2,
                        strokeColor: isDarkMode
                            ? Colors.white
                            : Colors.white.withOpacity(0.8),
                      );
                    },
                  ),
                );
              }).toList();
            },
          ),
          lineBarsData: [
            LineChartBarData(
              spots: completionData,
              isCurved: true,
              curveSmoothness: 0.3,
              color: habit.color,
              barWidth: 3,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  // Only show dots for the first and last points
                  bool isFirstOrLast =
                      index == 0 || index == completionData.length - 1;
                  return FlDotCirclePainter(
                    radius: isFirstOrLast ? 5 : 0,
                    color: habit.color,
                    strokeWidth: 2,
                    strokeColor: isDarkMode
                        ? Colors.white
                        : Colors.white.withOpacity(0.8),
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    habit.color.withOpacity(0.4),
                    habit.color.withOpacity(0.0),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<FlSpot> _createCompletionData() {
    final spots = <FlSpot>[];
    final monthLabels = AppDateUtils.getMonthLabelsForLast3Months();
    final monthNumbers = monthLabels.values.toList();

    // Count completions for each month
    final monthlyCompletions = <int, int>{};
    for (var i = 0; i < monthNumbers.length; i++) {
      monthlyCompletions[i] = 0;
    }

    // Count completions for each month
    habit.completionDates.forEach((date, completed) {
      if (completed) {
        for (var i = 0; i < monthNumbers.length; i++) {
          if (date.month == monthNumbers[i]) {
            monthlyCompletions[i] = (monthlyCompletions[i] ?? 0) + 1;
            break;
          }
        }
      }
    });

    // Create spots for the chart
    for (var i = 0; i < monthNumbers.length; i++) {
      spots.add(FlSpot(i.toDouble(), monthlyCompletions[i]?.toDouble() ?? 0));
    }

    return spots;
  }
}
