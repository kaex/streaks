import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const CategoryChip({
    Key? key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFEEEEEE);
    final textColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    IconData? icon = _getCategoryIcon(label);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (icon != null)
              Padding(
                padding: const EdgeInsets.only(right: 6),
                child: Icon(
                  icon,
                  size: 18,
                  color: isSelected ? Colors.white : textColor,
                ),
              ),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : textColor,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData? _getCategoryIcon(String label) {
    switch (label) {
      case 'Fitness':
        return Icons.directions_bike;
      case 'Health':
        return Icons.favorite;
      case 'Nutrition':
        return Icons.restaurant;
      case 'Art':
        return Icons.brush;
      case 'Finances':
        return Icons.attach_money;
      case 'Social':
        return Icons.people;
      case 'Study':
        return Icons.school;
      case 'Work':
        return Icons.work;
      case 'Morning':
        return Icons.wb_sunny;
      case 'Day':
        return Icons.wb_cloudy;
      case 'Evening':
        return Icons.nights_stay;
      case 'Other':
        return Icons.apps;
      default:
        return null;
    }
  }
}
