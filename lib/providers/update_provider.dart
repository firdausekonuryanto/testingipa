import 'package:flutter/material.dart';
import 'package:internusa_group/models/app_update_info.dart';
import 'package:internusa_group/services/update_service.dart';
import 'package:internusa_group/utils/dialogs.dart';

import 'dart:io';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path/path.dart' as p;

class UpdateProvider extends ChangeNotifier {
  final UpdateService _updateService = UpdateService();

  bool _isChecking = false;
  bool get isChecking => _isChecking;

  double _downloadProgress = 0.0;
  double get downloadProgress => _downloadProgress;
  bool _isDownloading = false;
  bool get isDownloading => _isDownloading;

  Future<void> checkForUpdate(BuildContext context) async {
    _isChecking = true;
    notifyListeners();

    try {
      final updateInfo = await _updateService.checkForUpdate();

      if (updateInfo != null) {
        _showUpdateDialog(context, updateInfo);
      }
    } finally {
      _isChecking = false;
      notifyListeners();
    }
  }

  void _showUpdateDialog(
    BuildContext context,
    AppUpdateInfo info,
  ) {
    AppDialogs.showUpdateDialog(
      context: context,
      version: info.latestVersionName,
      notes: info.notes,
      isMandatory: info.isMandatory,
      onDownload: () async {
        await _downloadAndInstallApk(context, info.downloadUrl, 'update.apk');
      },
    );
  }

  Future<void> _downloadAndInstallApk(
    BuildContext context,
    String url,
    String filename,
  ) async {
    if (_isDownloading) return;

    try {
      _isDownloading = true;
      _downloadProgress = 0.0;
      notifyListeners();
      // debugPrint('🚀 Memulai proses download & install APK');

      if (Platform.isAndroid &&
          (await Permission.manageExternalStorage.isDenied)) {
        final status = await Permission.manageExternalStorage.request();
        if (!status.isGranted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Izin penyimpanan ditolak')),
          );
          _isDownloading = false;
          notifyListeners();
          return;
        }
      }

      final Directory? extDir = await getExternalStorageDirectory();
      if (extDir == null)
        throw Exception('Gagal mengambil eksternal storage directory');
      final saveDirPath = extDir.path;
      final savePath = p.join(saveDirPath, filename);
      final directory = Directory(saveDirPath);
      if (!await directory.exists()) await directory.create(recursive: true);

      AppDialogs.showDownloadProgressDialog(
        context: context,
        progress: _downloadProgress,
        progressNotifier: this,
      );

      await _updateService.downloadApk(
        url: url,
        savePath: savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            _downloadProgress = received / total;
            notifyListeners();
          }
        },
      );

      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Download selesai')),
      );

      final file = File(savePath);
      if (!await file.exists())
        throw Exception('File tidak ditemukan setelah download');

      await OpenFilex.open(file.path);
    } catch (e, st) {
      if (Navigator.canPop(context)) Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('❌ Gagal download/install APK: $e')),
      );
      // debugPrint('❌ Gagal download/install APK: $e');
      // debugPrint('🧩 Stacktrace:\n$st');
    } finally {
      _isDownloading = false;
      notifyListeners();
    }
  }
}
