import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/customer.dart';

class CustomerService {
  final Dio _dio = Dio();

  CustomerService() {
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

  Future<List<Customer>> getAllCustomers(int? userId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.customerById(userId!)),
      );

      if (response.data != null &&
          response.data is Map &&
          response.data['success'] == true) {
        final List<dynamic> list = response.data['data'] ?? [];
        return list.map((json) => Customer.fromJson(json)).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load customers');
      }
    } catch (e) {
      throw Exception('Failed to load customers: $e');
    }
  }

  Future<Map<String, dynamic>> getFormData() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.customerFormData));

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

  /// Add customer
  Future<bool> addCustomer(Map<String, dynamic> payload, int? userId) async {
    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.customerStore),
        data: payload,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error addCustomer: $e");
      return false;
    }
  }

  Future<bool> addCustomerOnly(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.customerOnlyStore),
        data: payload,
      );

      return response.statusCode == 200 || response.statusCode == 201;
    } catch (e) {
      print("Error addCustomer: $e");
      return false;
    }
  }
}
