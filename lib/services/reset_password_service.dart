import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/routes/api_routes.dart';

class SendEmailService {
  final Dio _dio = Dio();

  SendEmailService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // debugPrint(
          //     "🌐 [Service] REQUEST -> ${options.method} ${options.uri}");
          // debugPrint("📦 Data: ${options.data}");
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // debugPrint(
          //     "🟢 [Service] RESPONSE (${response.statusCode}) -> ${response.data}");
          return handler.next(response);
        },
        onError: (error, handler) {
          debugPrint("🔴 [Service] ERROR: ${error.message}");
          if (error.response != null) {
            debugPrint("📄 Error Response: ${error.response?.data}");
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<bool> sendResetLink(String email) async {
    // debugPrint("📨 [Service] sendResetLink() memproses email: $email");

    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.sendResetLink),
        data: {"email": email},
      );

      if (response.data['status'] == 'success') {
        // debugPrint("✅ [Service] Status success");
        return true;
      } else {
        // debugPrint(
        //     "⚠️ [Service] API mengembalikan error: ${response.data['message']}");
        throw Exception(response.data['message']);
      }
    } catch (e) {
      debugPrint("🔴 [Service] Exception ditangkap: $e");
      throw Exception("Failed to send reset link: $e");
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    // debugPrint("📨 [Service] resetPassword() memproses...");

    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.resetPassword),
        data: {
          "email": email,
          "token": token,
          "password": password,
          "password_confirmation": confirmPassword,
        },
      );

      if (response.data['status'] == 'success') {
        // debugPrint("🟢 [Service] Password berhasil direset");
        return true;
      } else {
        // debugPrint(
        //     "⚠️ [Service] API mengembalikan error: ${response.data['message']}");
        throw Exception(response.data['message']);
      }
    } catch (e) {
      debugPrint("🔴 [Service] Exception ditangkap: $e");
      throw Exception("Failed to reset password: $e");
    }
  }
}
