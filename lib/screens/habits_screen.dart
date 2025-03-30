import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/habits_provider.dart';
import '../services/premium_service.dart';
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
    final premiumService = Provider.of<PremiumService>(context);

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
            child: RepaintBoundary(
              child: _getScreenForIndex(_selectedNavIndex),
            ),
          ),

          // Ad banner at the bottom (only for free users)
          if (!premiumService.isPremium) AdService.showBannerAd(context),
        ],
      ),
      // Functional bottom navigation bar
      bottomNavigationBar: RepaintBoundary(
        child: Container(
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
      ),
    );
  }

  Widget _getScreenForIndex(int index) {
    switch (index) {
      case 0:
        return const _HabitsGridView();
      case 1:
        return const HabitsListView();
      case 2:
        return const HabitsDetailsView();
      default:
        return const _HabitsGridView();
    }
  }

  Widget _buildNavItem(IconData icon, int index) {
    final isSelected = _selectedNavIndex == index;
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: () {
        setState(() {
          _selectedNavIndex = index;
        });
      },
      borderRadius: BorderRadius.circular(32),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? (isDarkMode ? Colors.grey[850] : Colors.grey[200])
              : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Icon(
          icon,
          color: isSelected
              ? AppTheme.accentColor
              : (isDarkMode ? Colors.grey[500] : Colors.grey[600]),
          size: 24,
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
                      'Upgrade to Premium',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text(
                      'Maybe Later',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // X button for closing the dialog
            Positioned(
              right: 0,
              top: 0,
              child: IconButton(
                icon: const Icon(Icons.close, size: 20),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
