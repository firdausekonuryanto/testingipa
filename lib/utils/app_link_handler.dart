import 'package:flutter/material.dart';
import 'package:internusa_group/routes/namedroutes.dart';
import 'package:internusa_group/main.dart';

class AppLinkHandler {
  static void handle(Uri uri) {
    try {
      final host = uri.host;
      final query = uri.queryParameters;

      // debugPrint(" - scheme : ${uri.scheme}");
      // debugPrint(" - host   : $host");
      // debugPrint(" - path   : ${uri.path}");
      // debugPrint(" - query  : $query");

      if (host == "reset-password") {
        final token = query["token"];
        final email = query["email"];

        // debugPrint("Token → $token");
        // debugPrint("Email → $email");

        if (token != null && email != null) {
          // debugPrint("🔐 Navigasi ke ResetPasswordScreen");

          navigatorKey.currentState?.pushNamed(
            RoutesNames.resetPasswordScreen,
            arguments: {
              "token": token,
              "email": email,
            },
          );
          return;
        }
      }

      // debugPrint("⚠ Deep link tidak dikenal");
    } catch (e) {
      debugPrint("❌ ERROR AppLinkHandler: $e");
    }
  }
}
