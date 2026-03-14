import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/kpi.dart';

class KpiService {
  final Dio _dio = Dio();

  KpiService() {
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
  Future<List<listKpi>> getListKpi(int userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.assignmentById(userId)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => listKpi.fromJson(json)).toList();
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load listKpi data');
      }
    } catch (e) {
      throw Exception('Failed to load listKpi data: $e');
    }
  }

  Future<KpiResponse> getKpi(int userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.kpiScoreById(userId)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        return KpiResponse.fromJson(response.data);
      } else {
        String errorMessage =
            response.data['message'] ?? 'Failed to load KPI. No success key.';
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Terjadi kesalahan saat memuat KPI: $e');
      throw Exception('Failed to load KPI: $e');
    }
  }
}
