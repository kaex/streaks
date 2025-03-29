import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/habits_provider.dart';
import '../models/premium_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_card.dart';
import '../widgets/category_chip.dart';
import '../services/ad_service.dart';
import 'habit_details_screen.dart';
import 'new_habit_screen.dart';
import 'habits_list_view.dart';
import 'habits_details_view.dart';
import 'settings_screen.dart';
import 'premium_screen.dart';

class HabitsScreen extends StatefulWidget {
  const HabitsScreen({super.key});

  @override
  State<HabitsScreen> createState() => _HabitsScreenState();
}

class _HabitsScreenState extends State<HabitsScreen> {
  int _selectedNavIndex = 0;

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? const Color(0xFF151515) : const Color(0xFFEEEEEE);
    final premiumProvider = Provider.of<PremiumProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: RichText(
          text: TextSpan(
            children: [
              TextSpan(
                text: 'Streaks',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: isDarkMode ? Colors.white : Colors.black,
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Settings button
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              width: 46,
              height: 46,
              child: IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  Navigator.pushNamed(context, '/settings');
                },
              ),
            ),
          ),
          // Add button
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(12),
              ),
              width: 46,
              height: 46,
              child: IconButton(
                icon: const Icon(Icons.add),
                onPressed: () async {
                  final habitsProvider =
                      Provider.of<HabitsProvider>(context, listen: false);

                  try {
                    // Check if user can add more habits
                    if (await habitsProvider.canAddHabit(context)) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewHabitScreen(),
                        ),
                      );
                    } else {
                      // Show premium upgrade dialog
                      _showPremiumDialog(context);
                    }
                  } catch (e) {
                    print('Error checking if user can add habit: $e');
                    // Show premium upgrade dialog on error
                    _showPremiumDialog(context);
                  }
                },
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Main content area that takes most of the space
          Expanded(
            child: _getScreenForIndex(_selectedNavIndex),
          ),

          // Ad banner at the bottom (only for free users)
          if (!premiumProvider.isPremium) AdService.showBannerAd(context),
        ],
      ),
      // Functional bottom navigation bar
      bottomNavigationBar: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1A1A1A) : Colors.white,
          borderRadius: BorderRadius.circular(32),
          boxShadow: [
            if (!isDarkMode)
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
          ],
        ),
        height: 60,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildNavItem(Icons.grid_view, 0),
            _buildNavItem(Icons.format_list_bulleted, 1),
            _buildNavItem(Icons.format_align_left, 2),
          ],
        ),
      ),
    );
  }

  void _showPremiumDialog(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final dialogBgColor =
        isDarkMode ? AppTheme.cardColor : AppTheme.lightCardColor;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        backgroundColor: dialogBgColor,
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            // Dialog content
            Container(
              padding: const EdgeInsets.fromLTRB(24, 24, 24, 24),
              width: double.infinity,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(
                      height: 20), // Add space at the top for the X button
                  const Text(
                    'Upgrade to Premium',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Free users can only create 3 habits. Upgrade to premium for unlimited habits and to remove ads.',
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to premium screen
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const PremiumScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      minimumSize: const Size(double.infinity, 45),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: const Text(
                      'Upgrade Now',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            ),

            // Close button positioned at top-left
            Positioned(
              left: 12,
              top: 12,
              child: InkWell(
                onTap: () => Navigator.of(context).pop(),
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: isDarkMode
                        ? Colors.black26
                        : Colors.black.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: isDarkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = index == _selectedNavIndex;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? Colors.white
              : isDarkMode
                  ? Colors.grey[500]
                  : Colors.grey[700],
        ),
      ),
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return _HabitsScreenContent(); // Grid view (default)
      case 1:
        return HabitsListView(); // List view
      case 2:
        return HabitsDetailsView(); // Stats/details view
      default:
        return _HabitsScreenContent();
    }
  }
}

class _HabitsScreenContent extends StatefulWidget {
  @override
  State<_HabitsScreenContent> createState() => _HabitsScreenContentState();
}

class _HabitsScreenContentState extends State<_HabitsScreenContent> {
  String _selectedCategory = 'All';

  @override
  Widget build(BuildContext context) {
    return Consumer<HabitsProvider>(
      builder: (context, habitsProvider, child) {
        if (habitsProvider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        final allHabits = habitsProvider.habits;
        final filteredHabits = _selectedCategory == 'All'
            ? allHabits
            : allHabits.where((habit) {
                return habit.categories != null &&
                    habit.categories!.contains(_selectedCategory);
              }).toList();

        if (allHabits.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.calendar_today_outlined,
                  size: 80,
                  color: Colors.grey[600],
                ),
                const SizedBox(height: 16),
                Text(
                  'No habits yet',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[400],
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap the + button to add your first habit',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: 300,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const NewHabitScreen(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentColor,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(28),
                      ),
                    ),
                    child: const Text(
                      'Create Habit',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }

        // Get all unique categories from habits
        final Set<String> categories = {'All'};
        for (var habit in allHabits) {
          if (habit.categories != null) {
            categories.addAll(habit.categories!);
          }
        }

        // Show categories filter chip
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category filter
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: categories.map((category) {
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: CategoryChip(
                        label: category,
                        isSelected: _selectedCategory == category,
                        onTap: () {
                          setState(() {
                            _selectedCategory = category;
                          });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),

            // Habits list
            Expanded(
              child: AnimationLimiter(
                child: filteredHabits.isEmpty
                    ? Center(
                        child: Text(
                          'No habits in this category',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.only(top: 8, bottom: 100),
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: HabitCard(
                                  habit: habit,
                                  onToggleCompletion: (habitId) {
                                    habitsProvider
                                        .toggleHabitCompletion(habitId);
                                  },
                                  onTap: (habitId) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            HabitDetailsScreen(
                                                habitId: habitId),
                                      ),
                                    );
                                  },
                                  onDelete: (habitId) {
                                    showDialog(
                                      context: context,
                                      builder: (BuildContext context) {
                                        return AlertDialog(
                                          title: const Text('Delete Habit'),
                                          content: const Text(
                                            'Are you sure you want to delete this habit? This action cannot be undone.',
                                          ),
                                          actions: [
                                            TextButton(
                                              onPressed: () =>
                                                  Navigator.pop(context),
                                              child: const Text('Cancel'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                habitsProvider
                                                    .deleteHabit(habitId);
                                                Navigator.pop(context);
                                              },
                                              child: const Text(
                                                'Delete',
                                                style: TextStyle(
                                                    color: Colors.red),
                                              ),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  onEdit: (habitId) {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            NewHabitScreen(habitId: habitId),
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                      ),
              ),
            ),
          ],
        );
      },
    );
  }
}
