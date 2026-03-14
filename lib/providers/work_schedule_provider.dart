import 'package:flutter/foundation.dart';
import '../models/work_schedule.dart';
import '../services/work_schedule_service.dart';

class WorkScheduleProvider extends ChangeNotifier {
  final WorkScheduleService _workScheduleService = WorkScheduleService();
  List<WorkSchedule> _todaySchedules = [];
  List<Map<String, dynamic>> _todayShift = [];
  WorkSchedule? _selectedSchedule;
  List<WorkSchedule> _employeeSchedules = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<WorkSchedule> get todaySchedules => _todaySchedules;
  List<Map<String, dynamic>> get todayShift => _todayShift;
  WorkSchedule? get selectedSchedule => _selectedSchedule;
  List<WorkSchedule> get employeeSchedules => _employeeSchedules;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchTodaySchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todaySchedules = await _workScheduleService.getTodaySchedules();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTodayShift(int employeeId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _todayShift = await _workScheduleService.getTodayShift(employeeId);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchScheduleByEmployeeId(int employeeId, {String? date}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedSchedule = await _workScheduleService.getScheduleByEmployeeId(
        employeeId,
        date: date,
      );
    } catch (e) {
      _error = e.toString();
      _selectedSchedule = null; // Reset selected schedule on error
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchEmployeeSchedules(
      {String? startDate, String? endDate}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _employeeSchedules = await _workScheduleService.getEmployeeSchedules(
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> createWorkSchedule({
    required int employeeId,
    required dynamic shiftId,
    required int shiftTemplateId,
    required String scheduleDate,
    required String status,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _workScheduleService.createOrUpdateWorkSchedule(
        employeeId: employeeId,
        shiftId: shiftId,
        shiftTemplateId: shiftTemplateId,
        scheduleDate: scheduleDate,
        status: status,
      );
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
