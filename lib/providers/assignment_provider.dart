import 'package:flutter/material.dart';
import '../services/assignment_service.dart';

class AssignmentProvider extends ChangeNotifier {
  final AssignmentService _assignmentService = AssignmentService();
  List<Map<String, dynamic>> _assignment = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Map<String, dynamic>> get assignment => _assignment;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchAssignment(int? userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _assignment = await _assignmentService.getMyAssignment(userId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
