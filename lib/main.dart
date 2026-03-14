import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/routes/app_routes.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:app_links/app_links.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
// Providers
import 'package:internusa_group/providers/assignment_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/providers/attendance_provider.dart';
import 'package:internusa_group/providers/customerservice_provider.dart';
import 'package:internusa_group/providers/kpi_provider.dart';
import 'package:internusa_group/providers/leave_provider.dart';
import 'package:internusa_group/providers/master_provider.dart';
import 'package:internusa_group/providers/product_subscription_provider.dart';
import 'package:internusa_group/providers/salary_provider.dart';
import 'package:internusa_group/providers/task_provider.dart';
import 'package:internusa_group/providers/work_schedule_provider.dart';
import 'package:internusa_group/providers/workproduct_provider.dart';
import 'package:internusa_group/providers/dynamic_form_provider.dart';
import 'package:internusa_group/providers/update_provider.dart';
import 'package:internusa_group/providers/reset_password_provider.dart';
import 'package:internusa_group/providers/app_notification_provider.dart';

// Utils
import 'package:internusa_group/providers/theme_controller.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/wrapper/auth_wrapper.dart';
import 'package:internusa_group/utils/app_link_handler.dart';

final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

/// Notifier global untuk tema
final ValueNotifier<ThemeMode> themeModeNotifier =
    ValueNotifier<ThemeMode>(ThemeMode.system);
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

Future<void> main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  await dotenv.load(fileName: ".env");

  Intl.defaultLocale = 'id_ID';
  await initializeDateFormatting('id_ID', null);

  final prefs = await SharedPreferences.getInstance();
  final savedMode = prefs.getString('theme_mode') ?? 'system';
  final theme = _stringToThemeMode(savedMode);
  themeModeNotifier.value = theme;

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => WorkScheduleProvider()),
        ChangeNotifierProvider(create: (_) => AttendanceProvider()),
        ChangeNotifierProvider(create: (_) => TaskProvider()),
        ChangeNotifierProvider(create: (_) => CustomerServiceProvider()),
        ChangeNotifierProvider(create: (_) => WorkproductProvider()),
        ChangeNotifierProvider(create: (_) => SalaryProvider()),
        ChangeNotifierProvider(create: (_) => KpiProvider()),
        ChangeNotifierProvider(create: (_) => AssignmentProvider()),
        ChangeNotifierProvider(create: (_) => LeaveProvider()),
        ChangeNotifierProvider(create: (_) => ProductSubscriptionProvider()),
        ChangeNotifierProvider(create: (_) => MasterProvider()),
        ChangeNotifierProvider(create: (_) => ThemeController()),
        ChangeNotifierProvider(create: (_) => DynamicFormProvider()),
        ChangeNotifierProvider(create: (_) => UpdateProvider()),
        ChangeNotifierProvider(create: (_) => SendEmailProvider()),
        ChangeNotifierProvider(create: (_) => AppNotificationProvider()),
      ],
      child: MyApp(initialThemeMode: theme),
    ),
  );
}

ThemeMode _stringToThemeMode(String mode) {
  switch (mode) {
    case 'light':
      return ThemeMode.light;
    case 'dark':
      return ThemeMode.dark;
    default:
      return ThemeMode.system;
  }
}

String _themeModeToString(ThemeMode mode) {
  switch (mode) {
    case ThemeMode.light:
      return 'light';
    case ThemeMode.dark:
      return 'dark';
    default:
      return 'system';
  }
}

class MyApp extends StatefulWidget {
  final ThemeMode initialThemeMode;
  const MyApp({super.key, required this.initialThemeMode});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late ValueNotifier<ThemeMode> _themeModeNotifier;
  AppLinks? _appLinks;

  @override
  void initState() {
    super.initState();
    _themeModeNotifier = ValueNotifier(widget.initialThemeMode);
    _appLinks = AppLinks();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      initAppLinks();
    });
  }

  /// INITIALIZE APP LINKS
  Future<void> initAppLinks() async {
    try {
      _appLinks = AppLinks();

      final Uri? initial = await _appLinks!.getInitialLink();

      if (initial != null) {
        AppLinkHandler.handle(initial);
      }

      _appLinks!.uriLinkStream.listen(
        (Uri uri) {
          AppLinkHandler.handle(uri);
        },
        onError: (err) => debugPrint("Stream error: $err"),
      );
    } catch (e) {
      debugPrint("initAppLinks ERROR: $e");
    }
  }

  Future<void> _setThemeMode(ThemeMode mode) async {
    // debugPrint(' Mengubah tema ke: ${_themeModeToString(mode)}');
    _themeModeNotifier.value = mode;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('theme_mode', _themeModeToString(mode));
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return ValueListenableBuilder(
          valueListenable: AppColors.gradientNotifier,
          builder: (_, colors, __) {
            return ValueListenableBuilder<ThemeMode>(
              valueListenable: _themeModeNotifier,
              builder: (_, themeMode, __) {
                return AnimatedTheme(
                  duration: const Duration(milliseconds: 300),
                  data:
                      themeMode == ThemeMode.dark ? darkTheme() : lightTheme(),
                  child: MaterialApp(
                    navigatorKey: navigatorKey,
                    debugShowCheckedModeBanner: false,
                    title: 'Internusa Group',
                    theme: lightTheme(),
                    darkTheme: darkTheme(),
                    themeMode: themeMode,
                    navigatorObservers: [routeObserver],
                    home: Container(
                      decoration: BoxDecoration(
                        color: themeMode == ThemeMode.dark
                            ? AppColors.textPrimary
                            : AppColors.background,
                      ),
                      child: const AuthWrapper(),
                    ),
                    routes: getAppRoutes(_setThemeMode),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}
