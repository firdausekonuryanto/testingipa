import 'package:flutter/foundation.dart';
import '../models/customer.dart';
import '../services/customer_service.dart';

class CustomerServiceProvider extends ChangeNotifier {
  final CustomerService _customerService = CustomerService();

  // State
  List<Customer> _customers = [];
  Map<String, dynamic>? _formData;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Customer> get customers => _customers;
  Map<String, dynamic>? get formData => _formData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchCustomers(int? userId) async {
    _isLoading = true;
    _error = null;

    try {
      _customers = await _customerService.getAllCustomers(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<Map<String, dynamic>> fetchFormData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _formData = await _customerService.getFormData();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
    return _formData ?? {};
  }

  Future<bool> addCustomer(Map<String, dynamic> payload, int? userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _customerService.addCustomer(payload, userId);
      if (success && userId != null) {
        await fetchCustomers(userId);
      }
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> addCustomerOnly(Map<String, dynamic> payload) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // print("menjalankan provider customer onlyh : ");
      // print("baca payload : $payload");
      final success = await _customerService.addCustomerOnly(payload);
      // print("menjalankan provider customer onlyh : ring 2");
      _isLoading = false;
      notifyListeners();
      return success;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }
}
