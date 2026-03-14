import 'dart:io';
import 'package:internusa_group/models/product_subscription.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:dio/dio.dart';
import '../utils/constans.dart';

class ProductSubscriptionService {
  final Dio _dio = Dio();

  ProductSubscriptionService() {
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

  Future<List<ProductSubscription>> fetchSubscriptions() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.productSubscription));

      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final data = response.data as Map<String, dynamic>;

        if (data['success'] == true && data['data'] is List) {
          final List<dynamic> list = data['data'];
          return list
              .map((json) {
                try {
                  return ProductSubscription.fromJson(json);
                } catch (e, stacktrace) {
                  print('Gagal parsing item: $e\n$stacktrace');
                  return null;
                }
              })
              .whereType<ProductSubscription>()
              .toList();
        } else {
          throw Exception('Format data tidak sesuai');
        }
      } else {
        throw Exception(
            'Request gagal: ${response.statusCode} ${response.statusMessage}');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.message ??
          'Terjadi kesalahan koneksi.';
      print('Dio error: $message');
      throw Exception('Gagal memuat data subscription: $message');
    } catch (e, stacktrace) {
      print('Unexpected error: $e\n$stacktrace');
      throw Exception('Gagal memuat data subscription: $e');
    }
  }

  Future<void> createSubscription({
    required int productId,
    required String name,
    required String phone,
    required String address,
    required String serialNumber,
    required String subscriptionPackage,
    required String terminationReason,
    File? modemPhoto,
  }) async {
    try {
      final formData = FormData.fromMap({
        'product_id': productId,
        'name': name,
        'phone': phone,
        'address': address,
        'serial_number': serialNumber,
        'subscription_package': subscriptionPackage,
        'termination_reason': terminationReason,
        if (modemPhoto != null)
          'modem_photo': await MultipartFile.fromFile(
            modemPhoto.path,
            filename: modemPhoto.path.split('/').last,
          ),
      });

      final response = await _dio.post(Api.url(ApiRoutes.productSubscription),
          data: formData);

      if (response.statusCode != 200 ||
          (response.data['success'] != true &&
              response.data['status'] != 'success')) {
        throw Exception(response.data['message'] ?? 'Gagal menyimpan data');
      }
    } on DioException catch (e) {
      final message = e.response?.data?['message'] ??
          e.message ??
          'Terjadi kesalahan koneksi.';
      throw Exception('Gagal membuat subscription: $message');
    } catch (e) {
      throw Exception('Unexpected error: $e');
    }
  }
}
