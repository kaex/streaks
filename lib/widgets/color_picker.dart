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
      _controller.value =
          0.5; // Start halfway through the animation if selected
    }
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
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
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
                boxShadow: [
                  if (_isPressed || widget.isSelected)
                    BoxShadow(
                      color: widget.color.withOpacity(0.7),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                ],
              ),
              child: widget.isSelected
                  ? TweenAnimationBuilder<double>(
                      tween: Tween<double>(begin: 0, end: 1),
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.elasticOut,
                      builder: (context, value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Icon(
                            Icons.check,
                            color: widget.iconColor,
                            size: 24,
                          ),
                        );
                      },
                    )
                  : null,
            ),
          );
        },
      ),
    );
  }
}
