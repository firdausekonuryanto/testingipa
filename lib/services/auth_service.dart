import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/user.dart';

class AuthService {
  final Dio _dio = Dio();
  String? cachedToken;

  AuthService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = cachedToken ?? await getToken();
          if (token != null) {
            cachedToken = token;
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
      ),
    );
  }

  // Login method
  Future<User> login(String login, String password) async {
    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.login),
        data: {'login': login, 'password': password},
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.data['success'] == true) {
        final userData = response.data['data'];
        // Save token ke SharedPreferences
        await saveToken(userData['access_token']);
        // Save token ke SharedPreferences
        await Tokenmanager.savedUser(
            Map<String, dynamic>.from(userData['user']));

        return User.fromJson(
            Map<String, dynamic>.from(response.data['data']['user']));
      } else {
        throw Exception(response.data['message'] ?? 'Login failed');
      }
    } on DioException catch (e) {
      if (e.response != null && e.response!.data != null) {
        final msg = e.response!.data['message'] ?? 'Login failed';
        throw Exception(msg);
      } else {
        throw Exception('Network error: ${e.message}');
      }
    }
  }

  // get profile user
  Future<User> getCurrentUser() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.authme));

      if (response.data['success'] == true) {
        final userData = response.data['data']['user'];
        return User.fromJson(Map<String, dynamic>.from(userData));
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to get user profile');
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw Exception('Authentication token expired or invalid');
      }
      throw Exception('Network error occurred: ${e.message}');
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Logout method
  Future<void> logout() async {
    try {
      await _dio.post(Api.url(ApiRoutes.logout));
    } catch (e) {
      await clearToken();
      await Tokenmanager.clearUser();
    } finally {
      await clearToken();
      cachedToken = null;
      await Tokenmanager.clearUser();
    }
  }

  //update profile
  Future<void> updateProfilePicture(String filePath) async {
    try {
      FormData formData = FormData.fromMap({
        'picture': await MultipartFile.fromFile(filePath,
            filename: filePath.split('/').last),
      });

      final response = await _dio.post(
        Api.url(ApiRoutes.updateprofilepicture),
        data: formData,
        options: Options(
          headers: {
            'Content-Type': 'multipart/form-data',
          },
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.data['status'] == 'success') {
        final userData = response.data['data']['user'];
        final updatedUser = User.fromJson(Map<String, dynamic>.from(userData));
        await Tokenmanager.savedUser(updatedUser.toJson());
      }
    } on DioException catch (e) {
      throw Exception('Upload failed: ${e.message}');
    }
  }

  // Check if token exists
  Future<bool> hasToken() async {
    return await Tokenmanager.hasToken();
  }

  // Get token
  Future<String?> getToken() async {
    return await Tokenmanager.getToken();
  }

  Future<void> saveToken(String token) async {
    await Tokenmanager.savedToken(token);
  }

  Future<void> clearToken() async {
    await Tokenmanager.clearToken();
  }

  Future<User> updateProfile({
    required String name,
    required String email,
    required String phone,
    required String address,
  }) async {
    try {
      final response = await _dio.put(
        Api.url(ApiRoutes.updateprofile),
        data: {
          "name": name,
          "email": email,
          "phone": phone,
          "address": address,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.data['status'] == 'success') {
        final userData = response.data['data']['user'];
        final updatedUser = User.fromJson(Map<String, dynamic>.from(userData));

        await Tokenmanager.savedUser(updatedUser.toJson());

        return updatedUser;
      } else {
        throw Exception(
            "Failed to update profile: ${response.data['message']}");
      }
    } on DioException catch (e) {
      throw Exception("Dio error: ${e.response?.data ?? e.message}");
    }
  }

  Future<User> updateProfileAccount({
    required String username,
    required String email,
    String? password,
  }) async {
    try {
      final response = await _dio.put(
        Api.url(ApiRoutes.updateprofileaccount),
        data: {
          'username': username,
          'email': email,
          if (password != null) 'password': password,
        },
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200) {
        final updatedUser = User.fromJson(
          Map<String, dynamic>.from(response.data['data']),
        );

        return updatedUser;
      } else {
        throw Exception("Failed to update profile: ${response.data}");
      }
    } catch (e) {
      rethrow;
    }
  }
}
