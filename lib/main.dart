import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart'; // Added for performance optimization
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'models/habits_provider.dart';
import 'models/theme_provider.dart';
import 'models/notification_manager.dart';
import 'services/premium_service.dart';
import 'services/purchase_service.dart';
import 'services/ad_service.dart';
import 'screens/habits_screen.dart';
import 'screens/settings_screen.dart';
import 'theme/app_theme.dart';

void main() async {
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Optimize rendering performance
  // Disable the error reporting overlay which can cause rendering issues
  ErrorWidget.builder = (FlutterErrorDetails details) => Container();

  // Fix orientation to portrait only to avoid expensive rebuilds
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // Initialize ad service
  await AdService().initialize();

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
        ChangeNotifierProvider(create: (context) => NotificationManager()),
        Provider<PurchaseService>(create: (context) => PurchaseService()),
        ChangeNotifierProxyProvider<PurchaseService, PremiumService>(
          create: (context) => PremiumService(
              Provider.of<PurchaseService>(context, listen: false)),
          update: (context, purchaseService, previousPremiumService) =>
              previousPremiumService ?? PremiumService(purchaseService),
        ),
      ],
      child: Consumer<ThemeProvider>(builder: (context, themeProvider, _) {
        return FutureBuilder<void>(
          // This ensures the theme has been loaded from preferences
          future: themeProvider.initialized,
          builder: (context, snapshot) {
            // Show a loading screen in the theme colors while waiting for the theme to load
            if (snapshot.connectionState != ConnectionState.done) {
              // Get platform brightness to match system theme during loading
              final Brightness platformBrightness =
                  MediaQuery.platformBrightnessOf(context);
              final bool isSystemDarkMode =
                  platformBrightness == Brightness.dark;

              // Use theme that matches system preference during loading
              final loadingTheme = isSystemDarkMode
                  ? ThemeData.dark().copyWith(
                      scaffoldBackgroundColor: Colors.black,
                      colorScheme: ColorScheme.dark(
                        primary: AppTheme.accentColor,
                      ),
                    )
                  : ThemeData.light().copyWith(
                      scaffoldBackgroundColor: AppTheme.lightBackgroundColor,
                      colorScheme: ColorScheme.light(
                        primary: AppTheme.accentColor,
                      ),
                    );

              return MaterialApp(
                theme: loadingTheme,
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
              theme: AppTheme.lightTheme().copyWith(
                appBarTheme: AppTheme.lightTheme().appBarTheme.copyWith(
                      scrolledUnderElevation: 0,
                    ),
              ),
              darkTheme: AppTheme.darkTheme().copyWith(
                appBarTheme: AppTheme.darkTheme().appBarTheme.copyWith(
                      scrolledUnderElevation: 0,
                    ),
              ),
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
