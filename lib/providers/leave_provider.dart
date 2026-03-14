import 'dart:io';

import 'package:flutter/material.dart';
import 'package:internusa_group/models/leave.dart';
import 'package:internusa_group/services/leave_service.dart';

class LeaveProvider extends ChangeNotifier {
  final LeaveService _leaveService = LeaveService();

  LeaveResponse? _leaveResponse;
  LeaveResponse? get leaveResponse => _leaveResponse;

  List<Leave> get leaves => _leaveResponse?.leaves ?? [];
  List<LeaveResume> get resume => _leaveResponse?.resume ?? [];

  String? _error;
  String? get error => _error;

  bool get isLoading => _isLoading;
  bool get isSuccess => _isSuccess;
  bool _isLoading = false;
  bool _isSuccess = false;

  Future<void> getLeaves() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _leaveResponse = await _leaveService.fetchLeaves();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createLeave({
    required String leaveType,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
    File? imageFile,
  }) async {
    _isLoading = true;
    _error = null;
    _isSuccess = false;
    notifyListeners();

    try {
      await _leaveService.createLeave(
        leaveType: leaveType,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
        imageFile: imageFile,
      );
      _isSuccess = true;
    } catch (e) {
      _error = e.toString();
      _isSuccess = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void reset() {
    _isSuccess = false;
    _error = null;
    notifyListeners();
  }
}
