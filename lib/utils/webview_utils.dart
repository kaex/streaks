import 'package:flutter/material.dart';
import '../widgets/webview_screen.dart';

extension WebViewUtils on BuildContext {
  /// Opens a WebView screen with the specified URL and title
  void openWebView({required String url, required String title}) {
    Navigator.push(
      this,
      MaterialPageRoute(
        builder: (context) => WebViewScreen(
          title: title,
          url: url,
        ),
      ),
    );
  }

  /// Opens the Privacy Policy in a WebView
  void openPrivacyPolicy() {
    openWebView(
      url: 'https://baransel.dev/privacy.html',
      title: 'Privacy Policy',
    );
  }

  /// Opens the Terms of Service in a WebView
  void openTermsOfService() {
    openWebView(
      url: 'https://baransel.dev/terms.html',
      title: 'Terms of Service',
    );
  }
}
