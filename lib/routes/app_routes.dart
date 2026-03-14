import 'package:flutter/material.dart';
import 'package:internusa_group/routes/namedroutes.dart';
import 'package:internusa_group/screens/forgot_password/new_password_screen.dart';
import 'package:internusa_group/screens/main_screen.dart';
import 'package:internusa_group/screens/login/login_screen.dart';
import 'package:internusa_group/screens/laporan_retail/laporan_retail_screeen.dart';
import 'package:internusa_group/screens/laporan_retail/create_laporan_retail_screen.dart';
import 'package:internusa_group/screens/laporan_retail/view_laporan_retail_screen.dart';
import 'package:internusa_group/screens/laporan_odp/laporan_odp_screen.dart';
import 'package:internusa_group/screens/laporan_odp/create_laporan_odp_screen.dart';
import 'package:internusa_group/screens/laporan_odp/view_laporan_odp_screen.dart';
import 'package:internusa_group/screens/notification/notification_screen.dart';
import 'package:internusa_group/screens/report/create_dynamic_form_screen.dart';
import 'package:internusa_group/screens/report/edit_dynamic_form_screen.dart';
import 'package:internusa_group/screens/report/index_dynamic_form_screen.dart';
import 'package:internusa_group/screens/report/select_dynamic_form_screen.dart';
import 'package:internusa_group/screens/report/show_dynamic_form_screen.dart';
import 'package:internusa_group/screens/salary/salary_screen.dart';
import 'package:internusa_group/screens/kpi/kpi_screen.dart';
import 'package:internusa_group/screens/forgot_password/forgot_password_screen.dart';
import 'package:internusa_group/screens/profile/edit_profile._screen.dart';
import 'package:internusa_group/screens/profile/settings_theme_screen.dart';
import 'package:internusa_group/screens/attendance/attendance_detail_screen.dart';
import 'package:internusa_group/screens/task/task_screen.dart';
import 'package:internusa_group/screens/task/Task_create_screen.dart';
import 'package:internusa_group/screens/leave/leave_screen.dart';
import 'package:internusa_group/screens/leave/create_leave_screen.dart';
import 'package:internusa_group/screens/product_subscription/product_subscription_screen.dart';
import 'package:internusa_group/screens/product_subscription/create-product-subscription_screen.dart';

Map<String, WidgetBuilder> getAppRoutes(Function(ThemeMode) onThemeChanged) {
  return {
    RoutesNames.home: (context) => const MainScreen(),
    RoutesNames.resetPasswordScreen: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return NewPasswordScreen(
        email: args['email'],
        token: args['token'],
      );
    },
    RoutesNames.login: (context) => const LoginScreen(),
    RoutesNames.laporanRetail: (context) => const LaporanRetailScreen(),
    RoutesNames.createLaporanRetail: (context) =>
        const CreateLaporanRetailScreen(),
    RoutesNames.viewLaporanRetail: (context) => const ViewLaporanRetailScreen(),
    RoutesNames.laporanOdp: (context) => const LaporanOdpScreen(),
    RoutesNames.viewLaporanOdp: (context) => const ViewLaporanOdpScreen(),
    RoutesNames.createLaporanOdp: (context) => const CreateLaporanOdpScreen(),
    RoutesNames.salary: (context) => const SalaryScreen(),
    RoutesNames.kpi: (context) => const KpiScreen(),
    RoutesNames.forgotPassword: (context) => const ForgotPassowordScreen(),
    RoutesNames.editProfile: (context) => const EditProfileScreen(),
    RoutesNames.attendanceDetail: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return AttendanceDetailScreen(
        item: args['item'],
        minutesLate: args['minutesLate'],
        minutesEarly: args['minutesEarly'],
      );
    },
    RoutesNames.task: (context) {
      final args = ModalRoute.of(context)!.settings.arguments;
      return TaskScreen(item: args);
    },
    RoutesNames.leave: (context) => const LeaveScreen(),
    RoutesNames.createLeave: (context) => const LeaveCreateScreen(),
    RoutesNames.createTask: (context) => const TaskCreateScreen(),
    RoutesNames.settingsTheme: (context) => SettingsThemeScreen(
          onThemeChanged: (ThemeMode mode) async {
            await onThemeChanged(mode);
          },
        ),
    RoutesNames.productSubscription: (context) =>
        const ProductSubscriptionScreen(),
    RoutesNames.createProductSubscription: (context) =>
        const CreateProductSubscriptionScreen(),
    RoutesNames.indexdynamicfrom: (context) => const IndexDynamicFormScreen(),
    RoutesNames.selectdynamicfrom: (context) => const SelectDynamicFormScreen(),
    RoutesNames.createdynamicfrom: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final int formId = args['formId'];
      return CreateDynamicFormScreen(formId: formId);
    },
    RoutesNames.editdynamicfrom: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      final int formId = args['formId'];
      final int id = args['id'];
      return EditDynamicFormScreen(formId: formId, id: id);
    },
    RoutesNames.showdynamicfrom: (context) {
      final args =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      return ShowDynamicFormScreen(response: args['response']);
    },
    RoutesNames.notification: (context) => const NotificationScreen(),
  };
}
