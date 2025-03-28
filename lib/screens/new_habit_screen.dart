import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/habit.dart';
import '../models/habits_provider.dart';
import '../theme/app_theme.dart';
import '../utils/icon_utils.dart';
import '../widgets/color_picker.dart';
import '../widgets/icon_picker.dart';
import 'interval_selection_screen.dart';
import 'reminder_selection_screen.dart';
import '../widgets/category_chip.dart';

class NewHabitScreen extends StatefulWidget {
  final String? habitId;

  const NewHabitScreen({super.key, this.habitId});

  @override
  State<NewHabitScreen> createState() => _NewHabitScreenState();
}

class _NewHabitScreenState extends State<NewHabitScreen> {
  final _formKey = GlobalKey<FormState>();
  late String _title;
  late String _description;
  late DateTime _startDate;
  late List<bool> _reminderDays;
  late TimeOfDay? _reminderTime;
  late String _interval;
  late Color _selectedColor;
  late String _selectedIconName;
  late int _streakGoal;
  late Set<String> _selectedCategories;

  late TextEditingController _titleController;
  late TextEditingController _descriptionController;

  bool _isEditing = false;
  late Habit? _existingHabit;

  @override
  void initState() {
    super.initState();

    _title = '';
    _description = '';
    _startDate = DateTime.now();
    _reminderDays = List.filled(7, false);
    _reminderTime = null;
    _interval = 'daily';
    _selectedColor = AppTheme.themeColors[4]; // Default to red
    _selectedIconName = 'book';
    _streakGoal = 1;
    _selectedCategories = {};

    _titleController = TextEditingController();
    _descriptionController = TextEditingController();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  void _initializeData() {
    if (widget.habitId != null) {
      final habitsProvider =
          Provider.of<HabitsProvider>(context, listen: false);
      _existingHabit = habitsProvider.getHabitById(widget.habitId!);

      if (_existingHabit != null) {
        _isEditing = true;

        _title = _existingHabit!.title;
        _titleController.text = _title;

        _description = _existingHabit!.description;
        _descriptionController.text = _description;

        _startDate = _existingHabit!.startDate;
        _reminderDays = List.from(_existingHabit!.reminderDays);
        _reminderTime = _existingHabit!.reminderTime;
        _interval = _existingHabit!.interval;
        _selectedColor = _existingHabit!.color;
        _selectedIconName = _existingHabit!.iconName;
        _streakGoal = _existingHabit!.streakGoal;

        if (_existingHabit!.categories != null) {
          _selectedCategories = Set.from(_existingHabit!.categories!);
        }

        setState(() {});
      }
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final scaffoldBgColor =
        isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
    final inputBgColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Scaffold(
      backgroundColor: scaffoldBgColor,
      appBar: AppBar(
        backgroundColor: scaffoldBgColor,
        title: Text(
          _isEditing ? 'Edit Habit' : 'New Habit',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: textColor,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.close, color: textColor),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      floatingActionButton: SizedBox(
        height: 50,
        width: 300,
        child: FloatingActionButton.extended(
          onPressed: _saveHabit,
          backgroundColor: AppTheme.accentColor,
          label: Text(
            _isEditing ? 'Save Changes' : 'Save',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Form fields
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name field
                    _buildSectionLabel('Name'),
                    TextFormField(
                      controller: _titleController,
                      decoration: InputDecoration(
                        hintText: 'Habit name',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        hintStyle: TextStyle(color: subtitleColor),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a title';
                        }
                        return null;
                      },
                      onSaved: (value) {
                        _title = value!;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Description field
                    _buildSectionLabel('Description'),
                    TextFormField(
                      controller: _descriptionController,
                      decoration: InputDecoration(
                        hintText: 'What will you do?',
                        filled: true,
                        fillColor: inputBgColor,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.all(16),
                        hintStyle: TextStyle(color: subtitleColor),
                      ),
                      style: TextStyle(
                        fontSize: 16,
                        color: textColor,
                      ),
                      maxLines: 3,
                      onSaved: (value) {
                        _description = value ?? '';
                      },
                    ),
                    const SizedBox(height: 24),

                    // Streak Goal & Reminder in a row
                    Row(
                      children: [
                        // Streak Goal
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Streak Goal'),
                              _buildSelectionContainer(
                                _getIntervalText(),
                                suffixIcon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  _showIntervalSelector();
                                },
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 16),
                        // Reminder
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildSectionLabel('Reminder'),
                              _buildSelectionContainer(
                                _getReminderText(),
                                suffixIcon: const Icon(
                                  Icons.chevron_right,
                                  color: Colors.grey,
                                ),
                                onTap: () {
                                  _showReminderSelector();
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Categories
                    _buildSectionLabel('Categories'),
                    _buildSelectionContainer(
                      _categoriesDisplayText,
                      suffixIcon: const Icon(
                        Icons.chevron_right,
                        color: Colors.grey,
                      ),
                      onTap: () {
                        _showCategoriesBottomSheet(context);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Completions per day
                    _buildSectionLabel('Completions Per Day'),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                            decoration: BoxDecoration(
                              color: inputBgColor,
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  '$_streakGoal / Day',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: textColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          Icons.remove,
                          onPressed: () {
                            if (_streakGoal > 1) {
                              setState(() {
                                _streakGoal--;
                              });
                            }
                          },
                        ),
                        const SizedBox(width: 12),
                        _buildIconButton(
                          Icons.add,
                          onPressed: () {
                            setState(() {
                              _streakGoal++;
                            });
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // Icon Selection
                    _buildSectionLabel('Icon'),
                    SizedBox(
                      height: 180, // Fixed height for scrollable grid
                      child: IconPicker(
                        selectedIconName: _selectedIconName,
                        onIconSelected: (iconName) {
                          setState(() {
                            _selectedIconName = iconName;
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Color Selection
                    _buildSectionLabel('Color'),
                    ColorPicker(
                      selectedColor: _selectedColor,
                      onColorSelected: (color) {
                        setState(() {
                          _selectedColor = color;
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionLabel(String text) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final subtitleColor = isDarkMode ? Colors.grey[400] : Colors.grey[700];

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 16,
          color: subtitleColor,
        ),
      ),
    );
  }

  Widget _buildSelectionContainer(
    String text, {
    required VoidCallback onTap,
    Widget? suffixIcon,
  }) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputBgColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final textColor = isDarkMode ? Colors.white : Colors.black;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: inputBgColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: textColor,
              ),
            ),
            if (suffixIcon != null) suffixIcon,
          ],
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon, {required VoidCallback onPressed}) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final inputBgColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFF5F5F5);
    final iconColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      decoration: BoxDecoration(
        color: inputBgColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: IconButton(
        icon: Icon(icon),
        onPressed: onPressed,
        color: iconColor,
      ),
    );
  }

  String get _categoriesDisplayText {
    if (_selectedCategories.isEmpty) {
      return 'None';
    } else if (_selectedCategories.length == 1) {
      return _selectedCategories.first;
    } else {
      return '${_selectedCategories.length} categories';
    }
  }

  void _showCategoriesBottomSheet(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final modalBgColor = isDarkMode ? const Color(0xFF111111) : Colors.white;
    final headerTextColor = isDarkMode ? Colors.white : Colors.black;
    final subtitleColor = isDarkMode ? Colors.grey : Colors.grey[600];

    final categories = [
      {'name': 'Art', 'icon': Icons.brush},
      {'name': 'Finances', 'icon': Icons.attach_money},
      {'name': 'Fitness', 'icon': Icons.directions_bike},
      {'name': 'Health', 'icon': Icons.favorite},
      {'name': 'Nutrition', 'icon': Icons.restaurant},
      {'name': 'Social', 'icon': Icons.people},
      {'name': 'Study', 'icon': Icons.school},
      {'name': 'Work', 'icon': Icons.work},
      {'name': 'Other', 'icon': Icons.apps},
      {'name': 'Morning', 'icon': Icons.wb_sunny},
      {'name': 'Day', 'icon': Icons.wb_cloudy},
      {'name': 'Evening', 'icon': Icons.nights_stay},
    ];

    Set<String> tempSelectedCategories = Set.from(_selectedCategories);

    showModalBottomSheet(
      context: context,
      backgroundColor: modalBgColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(builder: (context, setModalState) {
          return Container(
            padding: const EdgeInsets.all(24),
            height: MediaQuery.of(context).size.height * 0.7,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Categories',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: headerTextColor,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Pick one or multiple categories that your habit fits in',
                  style: TextStyle(
                    fontSize: 16,
                    color: subtitleColor,
                  ),
                ),
                const SizedBox(height: 20),
                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: categories.map((category) {
                    final isSelected =
                        tempSelectedCategories.contains(category['name']);
                    final isDarkMode =
                        Theme.of(context).brightness == Brightness.dark;
                    final backgroundColor =
                        isSelected ? AppTheme.accentColor : Colors.transparent;
                    final textColor = isSelected
                        ? Colors.white
                        : (isDarkMode ? Colors.grey[400] : Colors.grey[700]);
                    final border = isSelected
                        ? null
                        : Border.all(
                            color: isDarkMode
                                ? Colors.grey[800]!
                                : Colors.grey[300]!,
                            width: 1,
                          );

                    return GestureDetector(
                      onTap: () {
                        setModalState(() {
                          if (isSelected) {
                            tempSelectedCategories.remove(category['name']);
                          } else {
                            tempSelectedCategories
                                .add(category['name'] as String);
                          }
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: backgroundColor,
                          borderRadius: BorderRadius.circular(16),
                          border: border,
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              category['icon'] as IconData,
                              size: 18,
                              color: textColor,
                            ),
                            const SizedBox(width: 8),
                            Text(
                              category['name'] as String,
                              style: TextStyle(
                                fontSize: 16,
                                color: textColor,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedCategories = tempSelectedCategories;
                      });
                      Navigator.pop(context);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        });
      },
    );
  }

  void _saveHabit() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final habit = Habit(
        id: _isEditing ? _existingHabit!.id : null,
        title: _title,
        description: _description,
        startDate: _startDate,
        reminderDays: _reminderDays,
        reminderTime: _reminderTime,
        interval: _interval,
        color: _selectedColor,
        iconName: _selectedIconName,
        streakGoal: _streakGoal,
        categories: _selectedCategories.isNotEmpty
            ? _selectedCategories.toList()
            : null,
        completionDates: _isEditing ? _existingHabit!.completionDates : null,
      );

      final habitsProvider =
          Provider.of<HabitsProvider>(context, listen: false);

      if (_isEditing) {
        habitsProvider.updateHabit(habit, context: context);
      } else {
        habitsProvider.addHabit(habit, context: context);
      }

      Navigator.pop(context);
    }
  }

  String _getIntervalText() {
    // Implement the logic to get the formatted interval text
    switch (_interval) {
      case 'daily':
        return 'Daily';
      case 'weekly':
        return 'Week';
      case 'monthly':
        return 'Month';
      case 'none':
      default:
        return 'None';
    }
  }

  void _showIntervalSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => IntervalSelectionScreen(
          initialInterval: _interval,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _interval = result;
      });
    }
  }

  String _getReminderText() {
    if (_reminderTime == null || _reminderDays.every((day) => !day)) {
      return 'None';
    }

    final activeDays = _reminderDays.where((day) => day).length;
    final timeStr = _formatTime(_reminderTime!);

    if (activeDays == 7) {
      return 'Daily, $timeStr';
    } else if (activeDays == 1) {
      final dayIndex = _reminderDays.indexOf(true);
      final dayName =
          ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'][dayIndex];
      return '$dayName, $timeStr';
    } else {
      return '$activeDays days, $timeStr';
    }
  }

  String _formatTime(TimeOfDay time) {
    final hour = time.hourOfPeriod == 0 ? 12 : time.hourOfPeriod;
    final minute = time.minute.toString().padLeft(2, '0');
    final period = time.period == DayPeriod.am ? 'AM' : 'PM';
    return '$hour:$minute $period';
  }

  void _showReminderSelector() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ReminderSelectionScreen(
          selectedDays: _reminderDays,
          selectedTime: _reminderTime,
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _reminderDays = result['days'];
        _reminderTime = result['time'];
      });
    }
  }
}
