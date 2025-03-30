import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'purchase_service.dart';

class PremiumService extends ChangeNotifier {
  bool _isPremium = false;
  bool _isLoading = true;
  static const String _premiumKey = 'is_premium';
  static const String _themeKey = 'selected_theme';
  static const int maxFreeHabits = 3;
  final PurchaseService _purchaseService;
  late SharedPreferences _prefs;

  PremiumService(this._purchaseService) {
    _loadPremiumStatus();
    _setupPurchaseListener();
  }

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  List<ProductDetails> get products => _purchaseService.products;
  bool get isStoreAvailable => _purchaseService.isAvailable;
  String get selectedTheme => _prefs.getString(_themeKey) ?? 'dark';

  void _setupPurchaseListener() {
    // Listen for purchase updates to properly handle purchase completion
    Stream<List<PurchaseDetails>> purchaseUpdated =
        InAppPurchase.instance.purchaseStream;
    purchaseUpdated.listen((purchaseDetailsList) {
      _processPurchaseUpdates(purchaseDetailsList);
    });
  }

  void _processPurchaseUpdates(
      List<PurchaseDetails> purchaseDetailsList) async {
    for (final purchase in purchaseDetailsList) {
      // Only update premium status when purchase is actually successful
      if (purchase.status == PurchaseStatus.purchased ||
          purchase.status == PurchaseStatus.restored) {
        // Activate premium
        await setPremiumStatus(true);
        debugPrint('Premium status set to true based on successful purchase');
      }
      // Complete the purchase regardless of status
      if (purchase.pendingCompletePurchase) {
        await InAppPurchase.instance.completePurchase(purchase);
      }
    }
  }

  // Check if user can add more habits
  bool canAddMoreHabits(int currentHabitCount) {
    if (isPremium) return true;
    return currentHabitCount < maxFreeHabits;
  }

  Future<void> _loadPremiumStatus() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _isPremium = _prefs.getBool(_premiumKey) ?? false;
      debugPrint('Premium status loaded: $_isPremium');
    } catch (e) {
      debugPrint('Error loading premium status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> setPremiumStatus(bool isPremium) async {
    _isPremium = isPremium;
    await _prefs.setBool(_premiumKey, isPremium);
    debugPrint('Premium status saved: $_isPremium');
    notifyListeners();
  }

  Future<void> setTheme(String themeKey) async {
    await _prefs.setString(_themeKey, themeKey);
    notifyListeners();
  }

  Future<bool> upgradeToPremium() async {
    final success = await _purchaseService.purchase();
    // Don't immediately set premium status here, let the purchase listener handle it
    // Only when the purchase is confirmed as successful will premium be activated
    return success;
  }

  Future<bool> restorePurchases() async {
    return await _purchaseService.restorePurchases();
    // Let the purchase listener handle setting premium status
  }

  // For debug/testing only
  Future<void> togglePremiumStatus() async {
    await setPremiumStatus(!_isPremium);
  }

  static Map<String, String> get themeNames => {
        'dark': 'Classic Dark',
        'midnight': 'Midnight Blue',
        'amoled': 'AMOLED Black',
        'twilight': 'Twilight',
        'rose': 'Rose Gold',
        'lavender': 'Soft Lavender',
        'midnight_rose': 'Midnight Rose',
        'pearl': 'Pearl White',
      };

  static Map<String, ThemeData> getThemes() {
    return {
      'dark': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1E1E1E),
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white.withOpacity(0.7),
          surface: const Color(0xFF252525),
        ),
      ),
      'midnight': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0A1929),
        colorScheme: ColorScheme.dark(
          primary: Colors.blue[300]!,
          secondary: Colors.blue[200]!,
          surface: const Color(0xFF0F2438),
        ),
      ),
      'amoled': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: Colors.black,
        colorScheme: ColorScheme.dark(
          primary: Colors.white,
          secondary: Colors.white.withOpacity(0.7),
          surface: const Color(0xFF121212),
        ),
      ),
      'twilight': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2D1B36),
        colorScheme: ColorScheme.dark(
          primary: Colors.purple[200]!,
          secondary: Colors.purple[100]!,
          surface: const Color(0xFF382241),
        ),
      ),
      'rose': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2D2326),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFB0C1),
          secondary: const Color(0xFFFFB0C1).withOpacity(0.7),
          surface: const Color(0xFF362A2D),
        ),
      ),
      'lavender': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF2B2634),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFE2C4FF),
          secondary: const Color(0xFFE2C4FF).withOpacity(0.7),
          surface: const Color(0xFF332E3D),
        ),
      ),
      'midnight_rose': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF1A1721),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFF0A3BC),
          secondary: const Color(0xFFF0A3BC).withOpacity(0.7),
          surface: const Color(0xFF241E2C),
        ),
      ),
      'pearl': ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF292929),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFFFF0F3),
          secondary: const Color(0xFFFFF0F3).withOpacity(0.7),
          surface: const Color(0xFF333333),
        ),
      ),
    };
  }

  static Map<String, String> get premiumFeatures => {
        'unlimited_habits': 'Track unlimited habits without restrictions',
        'ad_free_experience': 'Enjoy a clean, ad-free experience',
        'advanced_statistics': 'Gain deeper insights into your progress',
        'custom_themes': 'Personalize your app with premium themes',
      };

  @override
  void dispose() {
    _purchaseService.dispose();
    super.dispose();
  }
}
