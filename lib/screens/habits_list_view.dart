import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:provider/provider.dart';
import '../models/habits_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/habit_list_item.dart';
import '../widgets/category_chip.dart';
import 'habit_details_screen.dart';
import 'new_habit_screen.dart';

class HabitsListView extends StatefulWidget {
  const HabitsListView({Key? key}) : super(key: key);

  @override
  State<HabitsListView> createState() => _HabitsListViewState();
}

class _HabitsListViewState extends State<HabitsListView> {
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
                  Icons.format_list_bulleted,
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
                ElevatedButton(
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

        // Show categories filter chip and list
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
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: filteredHabits.length,
                        itemBuilder: (context, index) {
                          final habit = filteredHabits[index];
                          return AnimationConfiguration.staggeredList(
                            position: index,
                            duration: const Duration(milliseconds: 375),
                            child: SlideAnimation(
                              verticalOffset: 50.0,
                              child: FadeInAnimation(
                                child: Padding(
                                  padding: const EdgeInsets.only(bottom: 12.0),
                                  child: HabitListItem(
                                    habit: habit,
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              HabitDetailsScreen(
                                            habitId: habit.id!,
                                          ),
                                        ),
                                      );
                                    },
                                    onToggle: () {
                                      habitsProvider
                                          .toggleHabitCompletion(habit.id!);
                                    },
                                  ),
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
