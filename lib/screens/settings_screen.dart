import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';
import '../models/theme_provider.dart';
import '../utils/webview_utils.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final String _appVersion = '1.0.0';

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: ListView(
        children: [
          const SizedBox(height: 16),

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
            onTap: () {
              _showComingSoonDialog('Notification Settings');
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
            onTap: () {
              _showComingSoonDialog('Rate App');
            },
          ),

          const Divider(),

          // Legal Section
          _buildSectionHeader('Legal'),
          _buildSettingItem(
            icon: Icons.privacy_tip,
            title: 'Privacy Policy',
            subtitle: 'How we handle your data',
            onTap: () {
              context.openPrivacyPolicy();
            },
          ),
          _buildSettingItem(
            icon: Icons.description,
            title: 'Terms of Service',
            subtitle: 'Legal terms for using Streaks',
            onTap: () {
              context.openTermsOfService();
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
      'Check out Streaks - Habit Tracker, the best app to build and maintain habits!',
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
}
