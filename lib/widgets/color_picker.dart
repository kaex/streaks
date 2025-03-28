import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ColorPicker extends StatelessWidget {
  final Color selectedColor;
  final Function(Color) onColorSelected;

  const ColorPicker({
    super.key,
    required this.selectedColor,
    required this.onColorSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final borderColor = isDarkMode ? Colors.white : Colors.black;
    final checkColor = isDarkMode ? Colors.white : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12.0),
      child: Wrap(
        spacing: 12.0,
        runSpacing: 12.0,
        children: AppTheme.themeColors.map((color) {
          final isSelected = color.value == selectedColor.value;
          // Check if the color is light
          final isLightColor = color.computeLuminance() > 0.5;
          final iconColor = isLightColor ? Colors.black : Colors.white;

          return GestureDetector(
            onTap: () => onColorSelected(color),
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(color: borderColor, width: 3)
                    : null,
              ),
              child: isSelected
                  ? Center(
                      child: Icon(
                        Icons.check,
                        color: iconColor,
                        size: 24,
                      ),
                    )
                  : null,
            ),
          );
        }).toList(),
      ),
    );
  }
}
