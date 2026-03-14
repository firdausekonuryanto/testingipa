import 'package:flutter/material.dart';
import 'package:internusa_group/services/reset_password_service.dart';

class SendEmailProvider extends ChangeNotifier {
  final SendEmailService _service = SendEmailService();

  bool isLoading = false;
  String? errorMessage;
  bool sent = false;

  Future<void> sendResetLink(String email) async {
    // debugPrint("🔵 [Provider] sendResetLink() dipanggil");
    // debugPrint("📩 Email: $email");

    try {
      isLoading = true;
      errorMessage = null;
      sent = false;
      notifyListeners();
      // debugPrint("⏳ [Provider] isLoading = true");

      final result = await _service.sendResetLink(email);

      // debugPrint("🟢 [Provider] Result dari service: $result");

      sent = result;
      // if (sent) debugPrint("✅ [Provider] Link reset berhasil dikirim");
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("🔴 [Provider] Error: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
      // debugPrint("⚪ [Provider] isLoading = false, notifyListeners() dipanggil");
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String confirmPassword,
  }) async {
    // debugPrint("🔵 [Provider] resetPassword() dipanggil");

    try {
      isLoading = true;
      errorMessage = null;
      notifyListeners();
      // debugPrint("⏳ [Provider] isLoading = true");

      final result = await _service.resetPassword(
        email: email,
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      );

      // if (result) {
      // debugPrint("🟢 [Provider] Password berhasil direset");
      // } else {
      // debugPrint("⚠️ [Provider] Reset gagal tanpa error message");
      // }
    } catch (e) {
      errorMessage = e.toString();
      debugPrint("🔴 [Provider] Error: $errorMessage");
    } finally {
      isLoading = false;
      notifyListeners();
      // debugPrint("⚪ [Provider] isLoading = false");
    }
  }
}
