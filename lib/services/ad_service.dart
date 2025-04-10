import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:provider/provider.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import '../services/premium_service.dart';

class AdService {
  static final AdService _instance = AdService._internal();
  bool _initialized = false;

  // Test ad unit IDs for development
  static const String _testBannerAdUnitId =
      'ca-app-pub-3940256099942544/6300978111';

  // Real ad unit IDs for production
  static const String _iosBannerAdUnitId =
      'ca-app-pub-8036540167045476/8204489731';
  static const String _androidBannerAdUnitId =
      'ca-app-pub-8036540167045476/8204489731';

  factory AdService() {
    return _instance;
  }

  AdService._internal();

  Future<void> initialize() async {
    if (!_initialized) {
      await MobileAds.instance.initialize();
      _initialized = true;
    }
  }

  String get bannerAdUnitId {
    // Use test ad unit ID for development in debug mode
    if (kDebugMode) {
      return _testBannerAdUnitId;
    }

    // For production
    if (Platform.isAndroid) {
      return _androidBannerAdUnitId;
    } else if (Platform.isIOS) {
      return _iosBannerAdUnitId;
    } else {
      throw UnsupportedError('Unsupported platform');
    }
  }

  // Create a banner ad
  BannerAd createBannerAd() {
    return BannerAd(
      adUnitId: bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          print('Banner ad loaded: ${ad.adUnitId}');
        },
        onAdFailedToLoad: (ad, error) {
          print('Banner ad failed to load: ${error.message}');
          ad.dispose();
        },
      ),
    );
  }

  // Widget to display banner ad if user is not premium
  static Widget showBannerAd(BuildContext context) {
    final premiumService = Provider.of<PremiumService>(context);

    if (premiumService.isPremium) {
      return const SizedBox.shrink(); // No ad for premium users
    }

    // Use RepaintBoundary to prevent this widget from causing parent rebuilds
    return RepaintBoundary(
      child: FutureBuilder<void>(
        future: AdService().initialize(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return _BannerAdWidget();
          } else {
            return const SizedBox(height: 50); // Placeholder while loading
          }
        },
      ),
    );
  }
}

// Create a stateful widget for banner ad to prevent memory leaks
class _BannerAdWidget extends StatefulWidget {
  @override
  State<_BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<_BannerAdWidget> {
  BannerAd? _bannerAd;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _bannerAd = AdService().createBannerAd()..load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_bannerAd == null) {
      return const SizedBox(height: 50);
    }

    return Container(
      height: 50, // Standard banner height
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
