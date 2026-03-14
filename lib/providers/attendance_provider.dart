import 'dart:io';
import 'package:flutter/material.dart';
import '../models/attendance.dart';
import '../models/work_schedule.dart';
import '../services/attendance_service.dart';

class AttendanceProvider extends ChangeNotifier {
  final AttendanceService _attendanceService = AttendanceService();

  List<Map<String, String>> _workSchedule = [];
  List<Map<String, String>> get workSchedule => _workSchedule;
  List<Attendance> _attendances = [];
  List<Attendance> get attendances => _attendances;
  List<AttendanceMontly> get attendancesMontly => _attendancesMontly;
  List<AttendanceMontly> _attendancesMontly = [];

  Map<String, dynamic> _todayAttendances = {};
  Map<String, dynamic> get todayAttendances => _todayAttendances;

  Attendance? _currentAttendance;
  Attendance? get currentAttendance => _currentAttendance;
  WorkSchedule? _currentSchedule;
  WorkSchedule? get currentSchedule => _currentSchedule;
  AttendanceMontly? _attendanceMontly;
  AttendanceMontly? get attendanceMontly => _attendanceMontly;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String _todayDate = '';
  String? get error => _error;
  String get todayDate => _todayDate;

  int _todayCount = 0;
  int get todayCount => _todayCount;

  Future<void> fetchWorkSchedules() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _workSchedule = await _attendanceService.getWorkSchedules();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchAllAttendances() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendances = await _attendanceService.getAllAttendances();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMontlyAttendances() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceMontly = await _attendanceService.getMontlyAttendances();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchMontlyAttendancesByDate(DateTime date) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _attendanceMontly =
          await _attendanceService.getMontlyAttendancesByDate(date);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchTodayAttendances(
      {bool? hasClockIn, bool? hasClockOut}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _attendanceService.getTodayAttendances(
        hasClockIn: hasClockIn,
        hasClockOut: hasClockOut,
      );
      _todayAttendances = result;
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> clockIn({
    required File clockInImage,
    double? latitude,
    double? longitude,
    required DateTime timestamp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final attendance = await _attendanceService.clockIn(
        workScheduleId: _currentSchedule?.id,
        clockInImage: clockInImage,
        latitude: latitude,
        longitude: longitude,
      );

      _currentAttendance = attendance;
      _currentSchedule = attendance.workSchedule;
      await fetchTodayAttendances();
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clockOut({
    required File clockOutImage,
    double? latitude,
    double? longitude,
    required DateTime timestamp,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentAttendance = await _attendanceService.clockOut(
        clockOutImage: clockOutImage,
        latitude: latitude,
        longitude: longitude,
      );
      await fetchTodayAttendances();
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  bool hasClockInToday() {
    return _currentAttendance?.clockIn != null;
  }

  bool hasClockOutToday() {
    return _currentAttendance?.clockOut != null;
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }

  void setCurrentSchedule(WorkSchedule? schedule) {
    _currentSchedule = schedule;
    notifyListeners();
  }

  bool canClockIn() {
    return !hasClockInToday() && _currentSchedule != null;
  }

  Future<AttendanceNote> addNote({
    required String notes,
    required String attendanceType,
  }) async {
    if (_currentAttendance == null) {
      throw Exception('No current attendance selected');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final note = await _attendanceService.addAttendanceNote(
        attendanceId: _currentAttendance!.id,
        notes: notes,
        attendanceType: attendanceType,
      );

      await fetchTodayAttendances();

      return note;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<List<AttendanceNote>> getAttendanceNotes() async {
    if (_currentAttendance == null) {
      throw Exception('No current attendance selected');
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final notes = await _attendanceService.getAttendanceNotes(
        _currentAttendance!.id,
      );
      return notes;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
