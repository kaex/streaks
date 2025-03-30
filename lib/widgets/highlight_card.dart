import 'package:flutter/material.dart';

class HighlightCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const HighlightCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    // Smaller font size for values
    final valueFontSize = size.width < 360 ? 28.0 : 36.0;

    // Theme-aware colors
    final cardBackgroundColor =
        isDarkMode ? const Color(0xFF1A1A1A) : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Card(
      margin: const EdgeInsets.all(3.0), // More compact margin
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      color: cardBackgroundColor,
      elevation: isDarkMode ? 0 : 2,
      shadowColor: isDarkMode ? null : Colors.black.withOpacity(0.1),
      child: Container(
        height: 110, // Slightly reduce height
        padding: const EdgeInsets.all(14.0),
        child: Stack(
          children: [
            // Top-right icon container
            Positioned(
              top: 0,
              right: 0,
              child: Container(
                height: 42,
                width: 42,
                decoration: BoxDecoration(
                  color: color
                      .withOpacity(0.2), // Use colored background with opacity
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 20,
                ),
              ),
            ),

            // Large value and title at the bottom
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: valueFontSize,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: subtitleColor,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
