import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

    return RepaintBoundary(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12.0),
        child: Wrap(
          spacing: 12.0,
          runSpacing: 12.0,
          children: AppTheme.themeColors.map((color) {
            final isSelected = color.value == selectedColor.value;
            // Check if the color is light
            final isLightColor = color.computeLuminance() > 0.5;
            final iconColor = isLightColor ? Colors.black : Colors.white;

            return _ColorOption(
              color: color,
              isSelected: isSelected,
              iconColor: iconColor,
              borderColor: borderColor,
              onTap: () {
                HapticFeedback.selectionClick();
                onColorSelected(color);
              },
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _ColorOption extends StatefulWidget {
  final Color color;
  final bool isSelected;
  final Color iconColor;
  final Color borderColor;
  final VoidCallback onTap;

  const _ColorOption({
    required this.color,
    required this.isSelected,
    required this.iconColor,
    required this.borderColor,
    required this.onTap,
  });

  @override
  State<_ColorOption> createState() => _ColorOptionState();
}

class _ColorOptionState extends State<_ColorOption>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  // Precalculated shadow
  late BoxShadow _selectedShadow;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.85).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    if (widget.isSelected) {
      _controller.value = 0.5;
    }

    // Create shadow based on color once
    _updateShadow();
  }

  void _updateShadow() {
    _selectedShadow = BoxShadow(
      color: widget.color.withOpacity(0.7),
      blurRadius: 12,
      spreadRadius: 2,
    );
  }

  @override
  void didUpdateWidget(_ColorOption oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }

    if (widget.color != oldWidget.color) {
      _updateShadow();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) {
          setState(() {
            _isPressed = true;
          });
          _controller.forward();
        },
        onTapUp: (_) {
          setState(() {
            _isPressed = false;
          });
          if (!widget.isSelected) {
            _controller.reverse();
          }
        },
        onTapCancel: () {
          setState(() {
            _isPressed = false;
          });
          if (!widget.isSelected) {
            _controller.reverse();
          }
        },
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value + (widget.isSelected ? 0.1 : 0),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: widget.color,
                  shape: BoxShape.circle,
                  border: widget.isSelected
                      ? Border.all(color: widget.borderColor, width: 3)
                      : null,
                  boxShadow: (_isPressed || widget.isSelected)
                      ? [_selectedShadow]
                      : null,
                ),
                child: widget.isSelected
                    ? Center(
                        child: Icon(
                          Icons.check,
                          color: widget.iconColor,
                          size: 24,
                        ),
                      )
                    : null,
              ),
            );
          },
        ),
      ),
    );
  }
}
