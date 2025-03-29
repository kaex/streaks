import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;
  bool _isLoading = true;
  static const String _premiumStatusKey = 'isPremiumUser';
  static const String _productId = 'streaks_premium_unlimited';
  static const int _freeHabitLimit = 3;

  // In-app purchase variables
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;

  PremiumProvider() {
    _loadPremiumStatus();
    _initInAppPurchase();
  }

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  int get freeHabitLimit => _freeHabitLimit;
  List<ProductDetails> get products => _products;
  bool get isStoreAvailable => _isAvailable;

  // Check if user can add more habits
  bool canAddMoreHabits(int currentHabitCount) {
    if (isPremium) return true;
    return currentHabitCount < _freeHabitLimit;
  }

  Future<void> _loadPremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isPremium = prefs.getBool(_premiumStatusKey) ?? false;
    } catch (e) {
      print('Error loading premium status: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _savePremiumStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_premiumStatusKey, _isPremium);
    } catch (e) {
      print('Error saving premium status: $e');
    }
  }

  // Initialize in-app purchase
  Future<void> _initInAppPurchase() async {
    final bool available = await _inAppPurchase.isAvailable();
    _isAvailable = available;

    if (available) {
      await _loadProducts();

      // Set up the listener for purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;

      purchaseUpdated.listen((purchaseDetailsList) {
        _listenToPurchaseUpdated(purchaseDetailsList);
      });
    }

    notifyListeners();
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({_productId});

      if (response.notFoundIDs.isNotEmpty) {
        print('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> buyPremium() async {
    if (_products.isEmpty) {
      print('No products available');
      return;
    }

    try {
      final ProductDetails productDetails = _products.first;
      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
      );

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      print('Error purchasing premium: $e');
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      if (purchaseDetails.status == PurchaseStatus.pending) {
        // Show a loading UI
      } else if (purchaseDetails.status == PurchaseStatus.purchased ||
          purchaseDetails.status == PurchaseStatus.restored) {
        // Handle successful purchase
        _setPremium(true);
      } else if (purchaseDetails.status == PurchaseStatus.error) {
        print('Error purchasing: ${purchaseDetails.error}');
      }

      if (purchaseDetails.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchaseDetails);
      }
    }
  }

  // For testing - manually toggle premium status
  Future<void> _setPremium(bool value) async {
    _isPremium = value;
    await _savePremiumStatus();
    notifyListeners();
  }

  // For testing purposes only
  Future<void> togglePremiumStatus() async {
    await _setPremium(!_isPremium);
  }

  // Restore purchases from the store
  Future<void> restorePurchases() async {
    await _inAppPurchase.restorePurchases();
  }
}
