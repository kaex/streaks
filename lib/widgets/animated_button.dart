import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AnimatedButton extends StatefulWidget {
  final Widget child;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? splashColor;
  final Color? highlightColor;
  final EdgeInsetsGeometry padding;
  final BorderRadius borderRadius;
  final bool enableHapticFeedback;
  final Duration animationDuration;

  const AnimatedButton({
    Key? key,
    required this.child,
    required this.onTap,
    this.backgroundColor,
    this.splashColor,
    this.highlightColor,
    this.padding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius = const BorderRadius.all(Radius.circular(12)),
    this.enableHapticFeedback = true,
    this.animationDuration = const Duration(milliseconds: 150),
  }) : super(key: key);

  @override
  State<AnimatedButton> createState() => _AnimatedButtonState();
}

class _AnimatedButtonState extends State<AnimatedButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: widget.animationDuration,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
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

  void _handleTapDown(TapDownDetails details) {
    setState(() {
      _isPressed = true;
    });
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  void _handleTapCancel() {
    setState(() {
      _isPressed = false;
    });
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: child,
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            if (widget.enableHapticFeedback) {
              HapticFeedback.mediumImpact();
            }
            widget.onTap();
          },
          onTapDown: _handleTapDown,
          onTapUp: _handleTapUp,
          onTapCancel: _handleTapCancel,
          borderRadius: widget.borderRadius,
          splashColor:
              widget.splashColor ?? theme.primaryColor.withOpacity(0.1),
          highlightColor:
              widget.highlightColor ?? theme.primaryColor.withOpacity(0.05),
          child: Ink(
            padding: widget.padding,
            decoration: BoxDecoration(
              color: widget.backgroundColor ?? theme.primaryColor,
              borderRadius: widget.borderRadius,
              boxShadow: _isPressed
                  ? [
                      BoxShadow(
                        color: (widget.backgroundColor ?? theme.primaryColor)
                            .withOpacity(0.4),
                        blurRadius: 5,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: widget.child,
          ),
        ),
      ),
    );
  }
}

// A convenient button with text
class AnimatedTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color? backgroundColor;
  final Color? textColor;
  final bool fullWidth;
  final IconData? icon;
  final double fontSize;
  final FontWeight fontWeight;

  const AnimatedTextButton({
    Key? key,
    required this.text,
    required this.onTap,
    this.backgroundColor,
    this.textColor,
    this.fullWidth = false,
    this.icon,
    this.fontSize = 16,
    this.fontWeight = FontWeight.bold,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedButton(
      onTap: onTap,
      backgroundColor: backgroundColor ?? theme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        width: fullWidth ? double.infinity : null,
        alignment: fullWidth ? Alignment.center : null,
        child: Row(
          mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              fullWidth ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            if (icon != null) ...[
              Icon(
                icon,
                color: textColor ?? Colors.white,
                size: fontSize + 2,
              ),
              const SizedBox(width: 8),
            ],
            Text(
              text,
              style: TextStyle(
                color: textColor ?? Colors.white,
                fontSize: fontSize,
                fontWeight: fontWeight,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
