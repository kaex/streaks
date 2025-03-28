import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Dark theme colors
  static const Color backgroundColor = Color(0xFF000000); // True black
  static const Color surfaceColor = Color(0xFF111111); // Nearly black
  static const Color cardColor = Color(0xFF151515); // Slightly lighter black
  static const Color accentColor = Color(0xFF8A2BE2); // Purple accent
  static const Color secondaryColor = Color(0xFFFF6B6B); // Reddish secondary
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFFB0B0B0);

  // Light theme colors
  static const Color lightBackgroundColor = Color(0xFFF7F8FA);
  static const Color lightSurfaceColor = Color(0xFFFFFFFF);
  static const Color lightCardColor = Color(0xFFFFFFFF);
  static const Color lightTextColor = Color(0xFF121212);
  static const Color lightSecondaryTextColor = Color(0xFF7A7A7A);

  // Color palette similar to HabitKit
  static List<Color> themeColors = [
    const Color(0xFFFF6B6B), // Red
    const Color(0xFFFF9E7D), // Peach
    const Color(0xFFFFD166), // Yellow
    const Color(0xFFB8E986), // Light Green
    const Color(0xFF06D6A0), // Teal
    const Color(0xFF4FC1E9), // Light Blue
    const Color(0xFF5E81F4), // Blue
    const Color(0xFF8A2BE2), // Purple (default)
    const Color(0xFFD264B6), // Pink
    const Color(0xFF667EEA), // Indigo
    const Color(0xFF24C6DC), // Cyan
    const Color(0xFF7F8C8D), // Gray
    const Color(0xFF2ECC71), // Green
    const Color(0xFFE74C3C), // Bright Red
    const Color(0xFFFA8231), // Orange
    const Color(0xFFBDC3C7), // Silver
  ];

  static ThemeData darkTheme() {
    return ThemeData.dark().copyWith(
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: accentColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: backgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: textColor),
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.copyWith(
              titleLarge: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              titleMedium: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
              bodyLarge: const TextStyle(
                fontSize: 16,
                color: textColor,
              ),
              bodyMedium: const TextStyle(
                fontSize: 14,
                color: secondaryTextColor,
              ),
            ),
      ),
      cardTheme: CardTheme(
        color: cardColor,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: cardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: secondaryTextColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF222222),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: cardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: const TextStyle(color: secondaryTextColor),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      colorScheme: ColorScheme.dark(
        primary: accentColor,
        secondary: secondaryColor,
        background: backgroundColor,
        surface: surfaceColor,
        brightness: Brightness.dark,
      ),
    );
  }

  static ThemeData lightTheme() {
    return ThemeData.light().copyWith(
      scaffoldBackgroundColor: lightBackgroundColor,
      primaryColor: accentColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lightBackgroundColor,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: lightTextColor,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(color: lightTextColor),
        foregroundColor: lightTextColor,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
              titleLarge: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: lightTextColor,
              ),
              titleMedium: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: lightTextColor,
              ),
              bodyLarge: TextStyle(
                fontSize: 16,
                color: lightTextColor,
              ),
              bodyMedium: TextStyle(
                fontSize: 14,
                color: lightSecondaryTextColor,
              ),
            ),
      ),
      cardTheme: CardTheme(
        color: lightCardColor,
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: lightCardColor,
        selectedItemColor: accentColor,
        unselectedItemColor: lightSecondaryTextColor,
        showSelectedLabels: false,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        elevation: 4,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accentColor,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: accentColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accentColor,
        ),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFFEEEEEE),
        thickness: 1,
      ),
      inputDecorationTheme: InputDecorationTheme(
        fillColor: lightCardColor,
        filled: true,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 16,
        ),
        hintStyle: TextStyle(color: lightSecondaryTextColor),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: lightSurfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
      ),
      colorScheme: ColorScheme.light(
        primary: accentColor,
        secondary: secondaryColor,
        background: lightBackgroundColor,
        surface: lightSurfaceColor,
        brightness: Brightness.light,
      ),
      switchTheme: SwitchThemeData(
        thumbColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return accentColor;
          }
          return Colors.grey.shade400;
        }),
        trackColor: MaterialStateProperty.resolveWith<Color>((states) {
          if (states.contains(MaterialState.selected)) {
            return accentColor.withOpacity(0.5);
          }
          return Colors.grey.shade300;
        }),
      ),
    );
  }
}
