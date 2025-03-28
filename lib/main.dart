import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/habits_provider.dart';
import 'models/theme_provider.dart';
import 'screens/habits_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HabitsProvider()),
        ChangeNotifierProvider(create: (context) => ThemeProvider()),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
        return FutureBuilder<void>(
          // This ensures the theme has been loaded from preferences
          future: themeProvider.initialized,
          builder: (context, snapshot) {
            // Show a loading screen in the theme colors while waiting for the theme to load
            if (snapshot.connectionState != ConnectionState.done) {
              // Use the default dark theme as fallback during loading
              final defaultTheme = ThemeData.dark().copyWith(
                scaffoldBackgroundColor: Colors.black,
                colorScheme: ColorScheme.dark(
                  primary: AppTheme.accentColor,
                ),
              );
              return MaterialApp(
                theme: defaultTheme,
                home: const Scaffold(
                  body: Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              );
            }

            // Main app with loaded theme
            return MaterialApp(
              title: 'Streaks',
              debugShowCheckedModeBanner: false,
              theme: AppTheme.lightTheme(),
              darkTheme: AppTheme.darkTheme(),
              themeMode: themeProvider.themeMode,
              home: const HabitsScreen(), // Use home instead of initialRoute
              routes: {
                '/settings': (context) => const SettingsScreen(),
              },
            );
          },
        );
      }),
    );
  }
}
