import 'package:flutter/material.dart';
import '../models/habit.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';
import '../utils/share_utils.dart';
import 'dart:math' as Math;

class ShareCustomizationScreen extends StatefulWidget {
  final Habit habit;

  const ShareCustomizationScreen({
    super.key,
    required this.habit,
  });

  @override
  State<ShareCustomizationScreen> createState() =>
      _ShareCustomizationScreenState();
}

class _ShareCustomizationScreenState extends State<ShareCustomizationScreen> {
  // Customization options
  bool _isDarkTheme = true;
  Color _selectedColor = Colors.red;
  bool _showCompletionIndicator = true;
  bool _showDescription = true;
  bool _showStreak = true;

  @override
  void initState() {
    super.initState();
    _selectedColor = widget.habit.color;

    // Make sure we're using a color from our grid
    _selectedColor = _findClosestColor(_selectedColor);
  }

  // Find the closest color in our color grid to the provided color
  Color _findClosestColor(Color targetColor) {
    // Define colors similar to those in the color grid
    final colors = _getColorPalette();

    // If the color is already in our grid, use it
    for (final color in colors) {
      if (color.value == targetColor.value) {
        return color;
      }
    }

    // Otherwise find the closest match
    double minDistance = double.infinity;
    Color closestColor = colors.first;

    for (final color in colors) {
      double distance = _colorDistance(color, targetColor);
      if (distance < minDistance) {
        minDistance = distance;
        closestColor = color;
      }
    }

    return closestColor;
  }

  // Calculate distance between two colors (RGB distance formula)
  double _colorDistance(Color a, Color b) {
    double rDiff = (a.red - b.red).toDouble();
    double gDiff = (a.green - b.green).toDouble();
    double bDiff = (a.blue - b.blue).toDouble();
    return Math.sqrt(rDiff * rDiff + gDiff * gDiff + bDiff * bDiff);
  }

  // Get the color palette used in the grid
  List<Color> _getColorPalette() {
    return [
      const Color(0xFFF76C6C), // Red
      const Color(0xFFFF9E7D), // Orange
      const Color(0xFFFFD166), // Yellow
      const Color(0xFFF4E04D), // Light Yellow
      const Color(0xFFB8E986), // Light Green
      const Color(0xFF06D6A0), // Teal
      const Color(0xFF4FC1E9), // Light Blue
      const Color(0xFF5E81F4), // Blue
      const Color(0xFF8A2BE2), // Purple
      const Color(0xFFD264B6), // Pink
      const Color(0xFFFF7E79), // Coral
      const Color(0xFF7F8C8D), // Gray
      const Color(0xFF95A5A6), // Light Gray
      const Color(0xFFBDC3C7), // Silver
      const Color(0xFFFF66FF), // Bright Pink
      const Color(0xFFFF5A84), // Hot Pink
      const Color(0xFFFF6B6B), // Light Red
      const Color(0xFF9EB0B8), // Slate
      const Color(0xFF8795A1), // Medium Gray
      const Color(0xFF718096), // Dark Gray
      const Color(0xFFA0AEC0), // Cool Gray
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        title: Text(
          'Share Habit',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.share, color: textColor),
            onPressed: () {
              ShareUtils.shareHabitSummary(
                context,
                widget.habit,
                themeIsDark: _isDarkTheme,
                customColor: _selectedColor,
                showCompletionIndicator: _showCompletionIndicator,
                showDescription: _showDescription,
                showStreak: _showStreak,
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Preview
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _selectedColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Habit card
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.all(16),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        // Top row with icon, title and completion indicator
                        Row(
                          children: [
                            // Icon
                            Container(
                              height: 50,
                              width: 50,
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                IconUtils.getIconData(widget.habit.iconName),
                                color: Colors.white,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 16),
                            // Title and description
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    widget.habit.title,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  if (_showDescription &&
                                      widget.habit.description.isNotEmpty)
                                    Text(
                                      widget.habit.description,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        color: Colors.white70,
                                      ),
                                    ),
                                ],
                              ),
                            ),
                            // Completion indicator
                            if (_showCompletionIndicator)
                              Container(
                                height: 42,
                                width: 42,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(
                                  Icons.check,
                                  color: _selectedColor,
                                  size: 24,
                                ),
                              ),
                          ],
                        ),

                        // Streak grid
                        if (_showStreak)
                          Padding(
                            padding: const EdgeInsets.only(top: 16),
                            child: SizedBox(
                              height: 100,
                              child: GridView.builder(
                                physics: const NeverScrollableScrollPhysics(),
                                gridDelegate:
                                    const SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: 25,
                                  crossAxisSpacing: 3,
                                  mainAxisSpacing: 3,
                                  childAspectRatio: 1,
                                ),
                                itemCount:
                                    75, // 3 rows x 25 columns for preview
                                itemBuilder: (ctx, index) {
                                  final today = DateTime.now();
                                  final dayOffset = 75 - 1 - index;
                                  final date = DateTime(today.year, today.month,
                                      today.day - dayOffset);
                                  final isCompleted =
                                      widget.habit.completionDates[date] ==
                                          true;

                                  return Container(
                                    decoration: BoxDecoration(
                                      color: isCompleted
                                          ? Colors.white.withOpacity(0.9)
                                          : Colors.black.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(2),
                                    ),
                                    child: isCompleted
                                        ? Center(
                                            child: Container(
                                              width: 2,
                                              height: 2,
                                              decoration: BoxDecoration(
                                                color: _selectedColor,
                                                shape: BoxShape.circle,
                                              ),
                                            ),
                                          )
                                        : null,
                                  );
                                },
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  // HabitKit branding at the bottom
                  Padding(
                    padding: const EdgeInsets.only(right: 16, bottom: 12),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              const Icon(
                                Icons.auto_awesome,
                                size: 12,
                                color: Colors.white,
                              ),
                              const SizedBox(width: 4),
                              const Text(
                                'Streaks - Habit Tracker',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

            // Appearance Section
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Appearance',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
            ),

            // Color Selector
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Color',
                    style: TextStyle(
                      fontSize: 16,
                      color: subtitleColor,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildColorGrid(),
                ],
              ),
            ),

            // Toggle switches
            _buildToggleSwitch(
                'Show Completion Indicator', _showCompletionIndicator,
                onChanged: (value) {
              setState(() {
                _showCompletionIndicator = value;
              });
            }),

            _buildToggleSwitch('Show Description', _showDescription,
                onChanged: (value) {
              setState(() {
                _showDescription = value;
              });
            }),

            _buildToggleSwitch('Show Streak', _showStreak, onChanged: (value) {
              setState(() {
                _showStreak = value;
              });
            }),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildColorGrid() {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.white : Colors.black;

    // Use the common color palette
    final colors = _getColorPalette();

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: colors.map((color) {
        final isSelected = color.value == _selectedColor.value;
        final isLightColor = color.computeLuminance() > 0.5;
        final iconColor = isLightColor ? Colors.black : Colors.white;

        return GestureDetector(
          onTap: () {
            setState(() {
              _selectedColor = color;
            });
          },
          child: Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(10),
              border:
                  isSelected ? Border.all(color: borderColor, width: 2) : null,
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: iconColor,
                    size: 18,
                  )
                : null,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildToggleSwitch(String label, bool value,
      {required Function(bool) onChanged}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: textColor,
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: Colors.white,
            activeTrackColor: AppTheme.accentColor,
            inactiveThumbColor: Colors.grey,
            inactiveTrackColor: Colors.grey.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
