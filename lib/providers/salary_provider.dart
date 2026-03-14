import 'package:flutter/foundation.dart';
import '../models/salary.dart';
import '../services/salary_service.dart';

class SalaryProvider extends ChangeNotifier {
  final SalaryService _salaryService = SalaryService();

  // State
  List<Salary> _salary = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Salary> get salary => _salary;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchSalary(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _salary = await _salaryService.getAllSalary(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
