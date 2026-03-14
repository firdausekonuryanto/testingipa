import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:internusa_group/models/app_update_info.dart';

import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/utils/constans.dart';

class UpdateService {
  final Dio _dio = Dio();

  UpdateService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await Tokenmanager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
            // debugPrint('🟢 Token ditambahkan ke header');
          }
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          // debugPrint('❌ DioError: ${e.message}');
          if (e.response != null) {
            // debugPrint('🔹 Status code: ${e.response?.statusCode}');
            // debugPrint('🔹 Response data: ${e.response?.data}');
          }
          return handler.next(e);
        },
      ),
    );
  }

  Future<AppUpdateInfo?> checkForUpdate() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersionCode = int.tryParse(packageInfo.buildNumber) ?? 0;
      // debugPrint('📱 Versi saat ini: $currentVersionCode');

      final response = await _dio.get(Api.url(ApiRoutes.appVersion));
      if (response.statusCode != 200 || response.data == null) return null;

      final data = response.data['data'];
      if (data == null) return null;

      final latestVersionCode =
          int.tryParse(data['version_code'].toString()) ?? 0;
      final latestVersionName = data['version_name'] ?? '';
      final downloadUrl = data['download_url'] ?? '';
      final notes = data['changelog'] ?? '-';
      final isMandatory = data['is_mandatory'] ?? false;

      // debugPrint('🆕 Versi terbaru: $latestVersionCode ($latestVersionName)');

      if (latestVersionCode > currentVersionCode) {
        return AppUpdateInfo(
          latestVersionCode: latestVersionCode,
          latestVersionName: latestVersionName,
          downloadUrl: _convertDropboxLink(downloadUrl),
          notes: notes,
          isMandatory: isMandatory,
          currentVersionCode: currentVersionCode,
        );
      } else {
        // debugPrint('✅ Sudah versi terbaru');
        return null;
      }
    } catch (e, st) {
      // debugPrint('❌ Error checkForUpdate: $e');
      // debugPrint('🧩 Stacktrace: $st');
      return null;
    }
  }

  String _convertDropboxLink(String url) {
    if (url.contains('dropbox.com')) {
      final converted = url.replaceAll('?dl=0', '?dl=1');
      // debugPrint('🔁 Dropbox link dikonversi ke direct download: $converted');
      return converted;
    }
    return url;
  }

  Future<String> downloadApk({
    required String url,
    required String savePath,
    required Function(int received, int total) onReceiveProgress,
  }) async {
    // debugPrint('🚀 Memulai proses download APK dari: $url');
    final dio = Dio();

    await dio.download(
      url,
      savePath,
      onReceiveProgress: onReceiveProgress,
      options: Options(
          receiveTimeout: const Duration(seconds: 0), followRedirects: true),
    );
    return savePath;
  }
}
