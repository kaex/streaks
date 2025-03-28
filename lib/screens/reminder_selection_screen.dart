import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ReminderSelectionScreen extends StatefulWidget {
  final List<bool> selectedDays;
  final TimeOfDay? selectedTime;

  const ReminderSelectionScreen({
    Key? key,
    required this.selectedDays,
    this.selectedTime,
  }) : super(key: key);

  @override
  State<ReminderSelectionScreen> createState() =>
      _ReminderSelectionScreenState();
}

class _ReminderSelectionScreenState extends State<ReminderSelectionScreen> {
  late List<bool> _selectedDays;
  late TimeOfDay? _selectedTime;
  final List<String> _daysOfWeek = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun'
  ];

  @override
  void initState() {
    super.initState();
    _selectedDays = List.from(widget.selectedDays);
    _selectedTime = widget.selectedTime ?? TimeOfDay(hour: 12, minute: 0);
  }

  @override
  Widget build(BuildContext context) {
    // Check if all days are selected
    final allSelected = _selectedDays.every((day) => day);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
    final inputBgColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey : Colors.grey[700];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        title: Text(
          'Reminder',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: textColor),
          onPressed: () {
            Navigator.pop(context, {
              'days': _selectedDays,
              'time': _selectedTime,
            });
          },
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Days section
          Padding(
            padding: EdgeInsets.only(left: 16, top: 16, bottom: 8),
            child: Text(
              'Days',
              style: TextStyle(
                fontSize: 16,
                color: subtitleColor,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(7, (index) {
                return _buildDayButton(index);
              }),
            ),
          ),

          // Select all/Deselect all option
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0, top: 8.0),
              child: GestureDetector(
                onTap: () {
                  setState(() {
                    _selectedDays = List.filled(7, !allSelected);
                  });
                },
                child: Text(
                  allSelected ? 'Deselect all' : 'Select all',
                  style: TextStyle(
                    color: AppTheme.accentColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),

          // Time selector
          Padding(
            padding: EdgeInsets.only(left: 16, top: 24, bottom: 8),
            child: Text(
              'Time',
              style: TextStyle(
                fontSize: 16,
                color: subtitleColor,
              ),
            ),
          ),
          GestureDetector(
            onTap: () => _selectTime(context),
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: inputBgColor,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Pick a time',
                    style: TextStyle(
                      fontSize: 16,
                      color: textColor,
                    ),
                  ),
                  Text(
                    _formatTime(_selectedTime!),
                    style: TextStyle(
                      fontSize: 16,
                      color: AppTheme.accentColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayButton(int index) {
    final isSelected = _selectedDays[index];
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final unselectedBgColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final unselectedTextColor = isDarkMode ? Colors.grey : Colors.grey[700];

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedDays[index] = !_selectedDays[index];
        });
      },
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : unselectedBgColor,
          borderRadius: BorderRadius.circular(12),
        ),
        alignment: Alignment.center,
        child: Text(
          _daysOfWeek[index],
          style: TextStyle(
            color: isSelected ? Colors.white : unselectedTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final timePickerBgColor =
        isDarkMode ? const Color(0xFF151515) : Colors.white;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime!,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppTheme.accentColor,
              brightness: isDarkMode ? Brightness.dark : Brightness.light,
            ),
            timePickerTheme: TimePickerThemeData(
              backgroundColor: timePickerBgColor,
              hourMinuteShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodShape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              dayPeriodColor: const Color(0xFF2A2A2A),
              dayPeriodTextColor: Colors.white,
              hourMinuteColor: const Color(0xFF2A2A2A),
              hourMinuteTextColor: Colors.white,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }
}
