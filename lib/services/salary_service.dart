import 'package:dio/dio.dart';
import 'package:internusa_group/models/salary.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';

class SalaryService {
  final Dio _dio = Dio();

  SalaryService() {
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

  /// Get all salary
  Future<List<Salary>> getAllSalary(int userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.salaryById(userId)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['status'] == "success") {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => Salary.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load salary data');
      }
    } catch (e) {
      throw Exception('Failed to load salary data: $e');
    }
  }
}
