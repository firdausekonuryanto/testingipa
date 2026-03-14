import 'package:dio/dio.dart';
import 'package:internusa_group/models/app_notification.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';

class AppNotificationService {
  late final Dio _dio;

  AppNotificationService() {
    _dio = Dio(
      BaseOptions(
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
        },
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await Tokenmanager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
      ),
    );
  }

  // ================= GET NOTIFICATIONS =================
  Future<List<AppNotification>> getNotifications() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.notifications));

      final data = response.data;

      if (data == null) {
        throw Exception('Empty response from server');
      }

      if (data['success'] != true) {
        throw Exception(data['message'] ?? 'Failed to load notifications');
      }

      final List list = data['data'] ?? [];

      return list.map((json) => AppNotification.fromJson(json)).toList();
    } on DioException catch (e) {
      throw Exception(e.response?.data?['message'] ??
          'Network error while fetching notifications');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }

  // ================= MARK READ =================
  Future<void> markNotificationRead(int id) async {
    final response = await _dio.post(Api.url(ApiRoutes.notificationsRead(id)));

    if (response.statusCode != 200) {
      throw Exception('Failed to mark notification as read');
    }
  }
}
