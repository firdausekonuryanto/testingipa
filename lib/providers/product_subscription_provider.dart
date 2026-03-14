import 'dart:io';

import 'package:flutter/material.dart';
import '../models/product_subscription.dart';
import '../services/product_subscription_service.dart';

class ProductSubscriptionProvider extends ChangeNotifier {
  final ProductSubscriptionService _service = ProductSubscriptionService();

  List<ProductSubscription> _subscriptions = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductSubscription> get subscriptions => _subscriptions;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchSubscriptions() async {
    _isLoading = true;
    notifyListeners();

    try {
      _subscriptions = await _service.fetchSubscriptions();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createSubscription({
    required int productId,
    required int userId,
    required String name,
    required String phone,
    required String address,
    required String serialNumber,
    required String subscriptionPackage,
    required String terminationReason,
    File? modemPhoto,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _service.createSubscription(
        productId: productId,
        name: name,
        phone: phone,
        address: address,
        serialNumber: serialNumber,
        subscriptionPackage: subscriptionPackage,
        terminationReason: terminationReason,
        modemPhoto: modemPhoto,
      );

      await fetchSubscriptions();
    } catch (e) {
      debugPrint('Error createSubscription: $e');
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
