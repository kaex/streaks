import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class PremiumProvider with ChangeNotifier {
  bool _isPremium = false;
  bool _isLoading = true;
  bool _isPurchasePending = false;
  static const String _premiumStatusKey = 'isPremiumUser';
  static const String _productId = 'lifetime_premium';
  static const int _freeHabitLimit = 3;

  // In-app purchase variables
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  bool _isAvailable = false;
  StreamSubscription<List<PurchaseDetails>>? _subscription;

  PremiumProvider() {
    _loadPremiumStatus();
    _initInAppPurchase();
  }

  bool get isPremium => _isPremium;
  bool get isLoading => _isLoading;
  bool get isPurchasePending => _isPurchasePending;
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
      print('Premium status loaded: $_isPremium');
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
      print('Premium status saved: $_isPremium');
    } catch (e) {
      print('Error saving premium status: $e');
    }
  }

  // Initialize in-app purchase
  Future<void> _initInAppPurchase() async {
    final bool available = await _inAppPurchase.isAvailable();
    _isAvailable = available;
    print('In-app purchase available: $available');

    if (available) {
      await _loadProducts();

      // Set up the listener for purchase updates
      final Stream<List<PurchaseDetails>> purchaseUpdated =
          _inAppPurchase.purchaseStream;

      _subscription = purchaseUpdated.listen(
        _listenToPurchaseUpdated,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          print('Purchase stream error: $error');
        },
      );
    } else {
      print('In-app purchase not available');
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

      if (_products.isNotEmpty) {
        print(
            'Product loaded: ${_products.first.id} - ${_products.first.title} - ${_products.first.price}');
      } else {
        print('No products available');
      }

      notifyListeners();
    } catch (e) {
      print('Error loading products: $e');
    }
  }

  Future<void> buyPremium() async {
    if (_products.isEmpty) {
      print('No products available for purchase');
      return;
    }

    try {
      _isPurchasePending = true;
      notifyListeners();

      final ProductDetails productDetails = _products.first;
      print(
          'Purchasing product: ${productDetails.id} - ${productDetails.price}');

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );

      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
    } catch (e) {
      _isPurchasePending = false;
      notifyListeners();
      print('Error purchasing premium: $e');
      rethrow; // Allow UI to handle the error
    }
  }

  void _listenToPurchaseUpdated(List<PurchaseDetails> purchaseDetailsList) {
    print('Purchase updated: ${purchaseDetailsList.length} purchases');

    for (final PurchaseDetails purchaseDetails in purchaseDetailsList) {
      print(
          'Purchase status: ${purchaseDetails.status} for ${purchaseDetails.productID}');

      if (purchaseDetails.status == PurchaseStatus.pending) {
        _isPurchasePending = true;
        notifyListeners();
      } else {
        _isPurchasePending = false;

        if (purchaseDetails.status == PurchaseStatus.purchased ||
            purchaseDetails.status == PurchaseStatus.restored) {
          print('Purchase successful or restored');
          _setPremium(true);
        } else if (purchaseDetails.status == PurchaseStatus.error) {
          print('Error purchasing: ${purchaseDetails.error?.message}');
        }

        if (purchaseDetails.pendingCompletePurchase) {
          print('Completing purchase');
          _inAppPurchase.completePurchase(purchaseDetails);
        }

        notifyListeners();
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
    print('Attempting to restore purchases');
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Error restoring purchases: $e');
      rethrow;
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}
