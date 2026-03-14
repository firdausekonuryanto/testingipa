import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/work_product.dart';

class WorkproductService {
  final Dio _dio = Dio();

  WorkproductService() {
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

  Future<List<WorkProducts>> getAllWorkProducts(int userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.workProductById(userId)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];

        return list.map((json) {
          try {
            return WorkProducts.fromJson(json);
          } catch (e) {
            print('Error saat mengonversi JSON ke WorkProducts: $e');
            return WorkProducts.fromJson(json);
          }
        }).toList();
      } else {
        String errorMessage = response.data['message'] ??
            'Failed to load work Product. No success key.';
        print('Kesalahan dari server: $errorMessage. User ID: $userId');
        throw Exception(errorMessage);
      }
    } catch (e) {
      print('Terjadi kesalahan saat memuat work product: $e');
      throw Exception('Failed to load work Product: $e');
    }
  }

  Future<Map<String, dynamic>> getFormData() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.workProductFormData));

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        final Map<String, dynamic> data =
            Map<String, dynamic>.from(response.data['data']);
        return data;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load form data');
      }
    } catch (e) {
      throw Exception('Failed to load form data: $e');
    }
  }

  Future<bool> addWorkProducts(WorkProducts workproducts) async {
    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.workProductStore),
        data: workproducts.toJson(),
      );

      return response.statusCode == 201 || response.data['success'] == true;
    } catch (e) {
      throw Exception('Failed to add work product: $e');
    }
  }
}
