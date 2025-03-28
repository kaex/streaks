import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class IntervalSelectionScreen extends StatefulWidget {
  final String initialInterval;

  const IntervalSelectionScreen({
    Key? key,
    required this.initialInterval,
  }) : super(key: key);

  @override
  State<IntervalSelectionScreen> createState() =>
      _IntervalSelectionScreenState();
}

class _IntervalSelectionScreenState extends State<IntervalSelectionScreen> {
  late String _selectedInterval;

  @override
  void initState() {
    super.initState();
    _selectedInterval = widget.initialInterval;
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
    final containerBgColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final dividerColor =
        isDarkMode ? const Color(0xFF2A2A2A) : const Color(0xFFE0E0E0);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey : Colors.grey[600];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        title: Text(
          'Streak Goal',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () => Navigator.pop(context, _selectedInterval),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Interval',
              style: TextStyle(
                fontSize: 16,
                color: subtitleColor,
              ),
            ),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: containerBgColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              children: [
                _buildIntervalOption('None', 'none'),
                Divider(height: 1, color: dividerColor),
                _buildIntervalOption('Daily', 'daily'),
                Divider(height: 1, color: dividerColor),
                _buildIntervalOption('Week', 'weekly'),
                Divider(height: 1, color: dividerColor),
                _buildIntervalOption('Month', 'monthly'),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildIntervalOption(String label, String value) {
    final isSelected = _selectedInterval == value;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      title: Text(
        label,
        style: TextStyle(
          fontSize: 18,
          color: textColor,
        ),
      ),
      trailing: isSelected
          ? Icon(
              Icons.check,
              color: AppTheme.accentColor,
            )
          : null,
      onTap: () {
        setState(() {
          _selectedInterval = value;
        });

        // Wait a moment to show the selection before popping
        Future.delayed(const Duration(milliseconds: 200), () {
          Navigator.pop(context, _selectedInterval);
        });
      },
    );
  }
}
