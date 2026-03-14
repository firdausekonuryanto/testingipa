import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConfig {
  static final String _stage = dotenv.env['APPSTAGE'] ?? 'local';

  static String get baseUrl {
    if (_stage == 'production') {
      return dotenv.env['PRODBASEURL']!;
    }
    return dotenv.env['DEVBASEURL']!;
  }

  static String get baseImageUrl {
    if (_stage == 'production') {
      return dotenv.env['PRODBASEIMAGE']!;
    }
    return dotenv.env['DEVBASEIMAGE']!;
  }
}

// helper api service
class Api {
  static String url(String route) => "${AppConfig.baseUrl}$route";
}
