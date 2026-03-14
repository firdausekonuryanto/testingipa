import 'package:flutter/material.dart';
import '../models/product.dart';
import '../models/customer_Subscription.dart';
import '../services/master_service.dart';

class MasterProvider with ChangeNotifier {
  final MasterService _masterService = MasterService();

  List<Product> _products = [];
  List<CustomerSubscription> _customers = [];

  bool _isLoading = false;

  List<Product> get products => _products;
  List<CustomerSubscription> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await _masterService.getProducts();
    } catch (e) {
      debugPrint(" Error loading products: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await _masterService.getCustomers();
    } catch (e) {
      debugPrint(" Error loading customers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refreshAll() async {
    _isLoading = true;
    notifyListeners();

    try {
      final results = await Future.wait([
        _masterService.getProducts(),
        _masterService.getCustomers(),
      ]);

      _products = results[0] as List<Product>;
      _customers = results[1] as List<CustomerSubscription>;
    } catch (e) {
      debugPrint(" Error refreshing master data: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
