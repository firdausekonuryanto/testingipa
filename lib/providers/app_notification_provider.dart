import 'package:flutter/material.dart';
import 'package:internusa_group/models/app_notification.dart';
import 'package:internusa_group/services/app_notification_service.dart';

class AppNotificationProvider extends ChangeNotifier {
  final AppNotificationService _service = AppNotificationService();

  List<AppNotification> _notifications = [];
  List<AppNotification> get notifications => _notifications;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  int get unreadCount => _notifications.where((e) => !e.isRead).length;

  // ================= FETCH =================
  Future<void> getNotifications({bool refresh = false}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final result = await _service.getNotifications();

      _notifications = result;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  int getNotificationCount() {
    return _notifications.length;
  }

  // ================= MARK READ LOCAL =================
  void markAsReadLocal(int id) {
    final index = _notifications.indexWhere((e) => e.id == id);

    if (index != -1) {
      _notifications[index] = _notifications[index].copyWith(
        isRead: true,
        readAt: DateTime.now(),
      );
      notifyListeners();
    }
  }

  // ================= MARK READ (API + LOCAL) =================
  Future<void> markAsRead(int id) async {
    try {
      // optimistic update (FAST UX)
      markAsReadLocal(id);

      // call backend
      await _service.markNotificationRead(id);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void insertRealtime(Map<String, dynamic> json) {
    try {
      final notif = AppNotification.fromJson(json);

      _notifications.insert(0, notif);
      notifyListeners();
    } catch (e) {
      debugPrint('Insert realtime error: $e');
    }
  }

  bool get isEmpty => _notifications.isEmpty;
}
