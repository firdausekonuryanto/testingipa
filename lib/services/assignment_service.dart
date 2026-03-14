import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/assignment.dart';

class AssignmentService {
  final Dio _dio = Dio();

  AssignmentService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await Tokenmanager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioError e, handler) {
          print("Dio Error: ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Assignment>> getAllAssignment(int? userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.assignmentById(userId!)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) {
          try {
            return Assignment.fromJson(json);
          } catch (e) {
            return Assignment.fromJson(json);
          }
        }).toList();
      } else {
        String errorMessage = response.data['message'] ??
            'Failed to load Assignment. No success key.';
        print('Kesalahan dari server: $errorMessage. User ID: $userId');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Terjadi kesalahan saat memuat Assignment: $e');
      throw Exception('Failed to load Assignment: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getMyAssignment(int? userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.assignmentTask(userId!)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.cast<Map<String, dynamic>>();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}
