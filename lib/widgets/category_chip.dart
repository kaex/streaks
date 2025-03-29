import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class CategoryChip extends StatefulWidget {
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
  State<CategoryChip> createState() => _CategoryChipState();
}

class _CategoryChipState extends State<CategoryChip>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _opacityAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _opacityAnimation = Tween<double>(begin: 1.0, end: 0.8).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFEEEEEE);
    final textColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    IconData? icon = _getCategoryIcon(widget.label);

    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Opacity(
              opacity: _opacityAnimation.value,
              child: child,
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected ? AppTheme.accentColor : backgroundColor,
            borderRadius: BorderRadius.circular(20),
            boxShadow: widget.isSelected
                ? [
                    BoxShadow(
                      color: AppTheme.accentColor.withOpacity(0.4),
                      blurRadius: 5,
                      spreadRadius: 1,
                    )
                  ]
                : null,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null)
                AnimatedPadding(
                  duration: const Duration(milliseconds: 250),
                  padding: EdgeInsets.only(
                    right: widget.isSelected ? 8 : 6,
                  ),
                  child: Icon(
                    icon,
                    size: widget.isSelected ? 20 : 18,
                    color: widget.isSelected ? Colors.white : textColor,
                  ),
                ),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 250),
                style: TextStyle(
                  color: widget.isSelected ? Colors.white : textColor,
                  fontWeight:
                      widget.isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: widget.isSelected ? 14 : 13,
                ),
                child: Text(widget.label),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData? _getCategoryIcon(String label) {
    switch (label) {
      case 'All':
        return Icons.apps;
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
