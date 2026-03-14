import 'package:flutter/foundation.dart';
import 'package:internusa_group/models/work_product.dart';
import 'package:internusa_group/services/workproduct_service.dart';

class WorkproductProvider extends ChangeNotifier {
  final WorkproductService _workproductService = WorkproductService();

  // State
  List<WorkProducts> _workproducts = [];
  Map<String, dynamic>? _formData;
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WorkProducts> get workproducts => _workproducts;
  Map<String, dynamic>? get formData => _formData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchWorkproducts(int? userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workproducts = await _workproductService.getAllWorkProducts(userId!);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchFormData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _formData = await _workproductService.getFormData();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> addWorkproduct(WorkProducts workproduct, int? userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _workproductService.addWorkProducts(workproduct);
      if (success && userId != null) {
        await fetchWorkproducts(userId);
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
}
