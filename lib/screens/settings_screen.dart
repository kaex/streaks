import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:url_launcher/url_launcher.dart';
import '../theme/app_theme.dart';
import '../models/theme_provider.dart';
import '../models/notification_manager.dart';
import '../services/premium_service.dart';
import '../utils/webview_utils.dart';
import 'notification_settings_screen.dart';
import 'premium_screen.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final backgroundColor =
        isDarkMode ? Colors.black : AppTheme.lightBackgroundColor;
    final textColor = isDarkMode ? Colors.white : Colors.black;

    final themeProvider = Provider.of<ThemeProvider>(context);
    final notificationManager = Provider.of<NotificationManager>(context);
    final premiumService = Provider.of<PremiumService>(context);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        scrolledUnderElevation: 0, // Prevent color change when scrolling
        elevation: 0,
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

          // Premium Status Banner
          if (premiumService.isPremium)
            Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple.shade300, Colors.purple.shade700],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.stars,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Premium User',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Thank you for supporting Streaks!',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          // Premium Option (for non-premium users)
          if (!premiumService.isPremium)
            _buildSettingItem(
              icon: Icons.stars,
              title: 'Upgrade to Premium',
              subtitle: 'Unlock unlimited habits and remove ads',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const PremiumScreen(),
                  ),
                );
              },
            ),

          // App Settings Section
          _buildSectionHeader('App Settings'),
          _buildSettingItem(
            icon: Icons.dark_mode,
            title: 'Dark Mode',
            subtitle: 'Toggle between light and dark theme',
            trailing: Switch(
              value: themeProvider.isDarkMode,
              activeColor: AppTheme.accentColor,
              onChanged: (value) {
                themeProvider.setDarkMode(value);
              },
            ),
          ),
          _buildSettingItem(
            icon: Icons.notifications,
            title: 'Notifications',
            subtitle: 'Manage reminder notifications',
            trailing: const Icon(Icons.chevron_right, color: Colors.grey),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const NotificationSettingsScreen(),
                ),
              );
            },
          ),

          const Divider(),

          // Share & Support Section
          _buildSectionHeader('Share & Support'),
          _buildSettingItem(
            icon: Icons.share,
            title: 'Share App',
            subtitle: 'Share Streaks with friends and family',
            onTap: _shareApp,
          ),
          _buildSettingItem(
            icon: Icons.star,
            title: 'Rate App',
            subtitle: 'Leave a review on the app store',
            onTap: _openRateApp,
          ),

          const Divider(),

          // Legal Section
          _buildSectionHeader('Legal'),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () async {
              await _launchUrl(
                  'https://www.freeprivacypolicy.com/live/streaks');
            },
          ),
          _buildSettingItem(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Legal terms for using Streaks',
            onTap: () async {
              await _launchUrl(
                  'https://www.termsandconditionsgenerator.com/live.php?token=streaks');
            },
          ),

          const Divider(),

          // About Section
          _buildSectionHeader('About'),
          _buildSettingItem(
            icon: Icons.info,
            title: 'Version',
            subtitle: _appVersion,
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: Text(
        title,
        style: TextStyle(
          color: AppTheme.accentColor,
          fontSize: 14,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildSettingItem({
    required IconData icon,
    required String title,
    required String subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    final isDarkMode = Provider.of<ThemeProvider>(context).isDarkMode;

    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: isDarkMode ? const Color(0xFF1E1E1E) : const Color(0xFFEEEEEE),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentColor,
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[500],
        ),
      ),
      trailing: trailing ??
          (onTap != null
              ? const Icon(Icons.chevron_right, color: Colors.grey)
              : null),
      onTap: onTap,
    );
  }

  void _shareApp() {
    Share.share(
      'Check out Streaks - Habit Tracker, the best app to build and maintain habits! http://play.google.com/store/apps/details?id=com.baransel.dev.streaks.habit.tracker',
    );
  }

  void _openRateApp() async {
    final InAppReview inAppReview = InAppReview.instance;

    try {
      // Check if the device can open the in-app review dialog
      if (await inAppReview.isAvailable()) {
        // Request a review
        await inAppReview.requestReview();
      } else {
        // If in-app review is not available, open the store listing
        await inAppReview.openStoreListing(
          appStoreId: '6473364753', // Your iOS App Store ID
          microsoftStoreId: 'your-microsoft-store-id', // Optional
        );
      }
    } catch (e) {
      // Fallback to a thank you dialog in case of any errors
      _showReviewFallbackDialog();
    }
  }

  void _showReviewFallbackDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Thank You!'),
        content: const Text(
          'Your feedback helps us improve Streaks. Thank you for taking the time to review our app!',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showComingSoonDialog(String feature, [String? message]) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('$feature Coming Soon'),
        content: Text(message ??
            'The $feature functionality will be available in a future update.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // Show a snackbar if the URL couldn't be launched
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not open $urlString')),
        );
      }
    }
  }
}
