import 'package:flutter/material.dart';

class IconUtils {
  static Map<String, IconData> iconMap = {
    'book': Icons.menu_book_rounded,
    'workout': Icons.fitness_center_rounded,
    'water': Icons.local_drink_rounded,
    'meditation': Icons.self_improvement_rounded,
    'sleep': Icons.bedtime_rounded,
    'diet': Icons.restaurant_rounded,
    'code': Icons.code_rounded,
    'study': Icons.school_rounded,
    'finance': Icons.account_balance_wallet_rounded,
    'walk': Icons.directions_walk_rounded,
    'run': Icons.directions_run_rounded,
    'bike': Icons.directions_bike_rounded,
    'swim': Icons.pool_rounded,
    'music': Icons.music_note_rounded,
    'language': Icons.language_rounded,
    'art': Icons.brush_rounded,
    'pill': Icons.medication_rounded,
    'clean': Icons.cleaning_services_rounded,
    'journal': Icons.note_alt_rounded,
    'photo': Icons.photo_camera_rounded,
    'coffee': Icons.coffee_rounded,
    'goal': Icons.emoji_events_rounded,
    'social': Icons.people_rounded,
    'heart': Icons.favorite_rounded,
    'calm': Icons.spa_rounded,
    'travel': Icons.flight_rounded,
    'write': Icons.edit_rounded,
    'reminder': Icons.alarm_rounded,
    'reading': Icons.auto_stories_rounded,
    'family': Icons.family_restroom_rounded,
    'cooking': Icons.soup_kitchen_rounded,
    'shopping': Icons.shopping_cart_rounded,
    'todo': Icons.checklist_rounded,
    'nature': Icons.forest_rounded,
    'movie': Icons.movie_rounded,
    'game': Icons.sports_esports_rounded,
    'savings': Icons.savings_rounded,
    'hydrate': Icons.water_drop_rounded,
    'mindfulness': Icons.psychology_rounded,
    'stretch': Icons.accessibility_new_rounded,
    'no_screens': Icons.phone_android_rounded,
    'no_alcohol': Icons.no_drinks_rounded,
    'no_smoking': Icons.smoke_free_rounded,
    'vitamins': Icons.medication_liquid_rounded,
    'dental': Icons.clean_hands_rounded,
    'call': Icons.call_rounded,
  };

  static IconData getIconData(String iconName) {
    return iconMap[iconName] ?? Icons.star_rounded;
  }

  static List<String> getAllIconNames() {
    return iconMap.keys.toList();
  }
}
