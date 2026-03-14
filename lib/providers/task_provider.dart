import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import '../models/task.dart';
import '../models/task_report.dart';
import '../services/task_service.dart';

class TaskProvider extends ChangeNotifier {
  final TaskService _taskService = TaskService();
  List<Task> _tasks = [];
  Task? _currentTask;
  List<TaskReport> _taskReports = [];
  bool _isLoading = false;
  String? _error;

  // Filter states
  bool _showTodayOnly = false;
  String? _currentStatus;
  String? _selectedDate;

  // Getters
  List<Task> get tasks => _tasks;
  Task? get currentTask => _currentTask;
  List<TaskReport> get taskReports => _taskReports;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get showTodayOnly => _showTodayOnly;
  String? get currentStatus => _currentStatus;
  String? get selectedDate => _selectedDate;

  Future<void> fetchAllTasks({
    String? status,
    bool? today,
    String? assignDate,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _tasks = await _taskService.getAllTasks(
        status: status ?? _currentStatus,
        today: today ?? _showTodayOnly,
        assignDate: assignDate ?? _selectedDate,
      );

      // Update filter states
      if (status != null) _currentStatus = status;
      if (today != null) _showTodayOnly = today;
      if (assignDate != null) _selectedDate = assignDate;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void toggleTodayFilter() {
    _showTodayOnly = !_showTodayOnly;
    _selectedDate = null; // Clear selected date when toggling today
    fetchAllTasks();
  }

  void setDateFilter(String date) {
    _selectedDate = date;
    _showTodayOnly = false; // Clear today filter when selecting specific date
    fetchAllTasks();
  }

  void setStatusFilter(String? status) {
    _currentStatus = status;
    fetchAllTasks();
  }

  void clearFilters() {
    _showTodayOnly = false;
    _currentStatus = null;
    _selectedDate = null;
    fetchAllTasks();
  }

  Future<void> fetchTaskDetail(int taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _currentTask = await _taskService.getTaskDetail(taskId);
    } catch (e) {
      _error = e.toString();
      _currentTask = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchTaskReports(int taskId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final reports = await _taskService.getTaskReports(taskId);
      _taskReports = reports;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _taskReports = [];
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<TaskReport> createTaskReport({
    required int taskId,
    required String content,
    String? reasonNotCompleted,
    required XFile? imageBefore,
    required XFile? imageAfter,
  }) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final report = await _taskService.createTaskReport(
        taskId: taskId,
        content: content,
        reasonNotCompleted: reasonNotCompleted,
        imageBefore: imageBefore,
        imageAfter: imageAfter,
      );

      await fetchTaskReports(taskId);

      return report;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> updateReason(List<int> taskIds, String reason) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool result = await _taskService.updateReason(taskIds, reason);

      if (result) {
        // Kalau mau refresh data assignment, bisa aktifkan ini
        // await fetchAssignment(userId);
      }

      _isLoading = false;
      notifyListeners();
      return result;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  void setCurrentTask(Task task) {
    _currentTask = task;
    notifyListeners();
  }

  void resetError() {
    _error = null;
    notifyListeners();
  }

  void clearCurrentTask() {
    _currentTask = null;
    _taskReports = [];
    notifyListeners();
  }
}
