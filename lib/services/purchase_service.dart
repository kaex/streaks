import 'package:flutter/material.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:async';

class PurchaseService {
  static const String productId = 'lifetime_premium';
  final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  List<ProductDetails> _products = [];
  StreamSubscription<List<PurchaseDetails>>? _subscription;
  bool _isAvailable = false;

  PurchaseService() {
    _init();
  }

  List<ProductDetails> get products => _products;
  bool get isAvailable => _isAvailable;

  Future<void> _init() async {
    final available = await _inAppPurchase.isAvailable();
    _isAvailable = available;

    if (available) {
      await _loadProducts();

      // Set up subscription for purchase updates
      final purchaseUpdated = _inAppPurchase.purchaseStream;
      _subscription = purchaseUpdated.listen(
        _processPurchases,
        onDone: () {
          _subscription?.cancel();
        },
        onError: (error) {
          debugPrint('Purchase stream error: $error');
        },
      );
    }
  }

  Future<void> _loadProducts() async {
    try {
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails({productId});

      if (response.notFoundIDs.isNotEmpty) {
        debugPrint('Products not found: ${response.notFoundIDs}');
      }

      _products = response.productDetails;
    } catch (e) {
      debugPrint('Error loading products: $e');
    }
  }

  Future<bool> purchase() async {
    if (_products.isEmpty) {
      return false;
    }

    try {
      final ProductDetails productDetails = _products.first;

      final PurchaseParam purchaseParam = PurchaseParam(
        productDetails: productDetails,
        applicationUserName: null,
      );

      return await _inAppPurchase.buyNonConsumable(
          purchaseParam: purchaseParam);
    } catch (e) {
      debugPrint('Error purchasing product: $e');
      return false;
    }
  }

  void _processPurchases(List<PurchaseDetails> purchaseDetails) {
    for (final purchase in purchaseDetails) {
      if (purchase.status == PurchaseStatus.pending) {
        // Wait for purchase to complete
      } else if (purchase.status == PurchaseStatus.purchased) {
        _showSuccessMessage();
      } else if (purchase.status == PurchaseStatus.restored) {
        _showSuccessMessage();
      } else if (purchase.status == PurchaseStatus.error) {
        debugPrint('Purchase error: ${purchase.error?.message}');
      }

      if (purchase.pendingCompletePurchase) {
        _inAppPurchase.completePurchase(purchase);
      }
    }
  }

  void _showSuccessMessage() {
    // Show a success message using a global key or through a service
    debugPrint('Purchase successful! Thank you for supporting Streaks!');
  }

  Future<bool> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
      return true;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
  }
}
