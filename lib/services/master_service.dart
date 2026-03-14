import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/product.dart';
import '../models/customer_Subscription.dart';

class MasterService {
  final Dio _dio = Dio();

  MasterService() {
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

  Future<List<Product>> getProducts() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.masterProduct));

      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data;
        return data.map((e) => Product.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load products');
      }
    } catch (e) {
      throw Exception('Error fetching products: $e');
    }
  }

  Future<List<CustomerSubscription>> getCustomers() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.masterCustomer));
      if (response.statusCode == 200) {
        final List data = response.data['data'] ?? response.data;
        return data.map((e) => CustomerSubscription.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load customers');
      }
    } catch (e) {
      throw Exception('Error fetching customers: $e');
    }
  }
}
