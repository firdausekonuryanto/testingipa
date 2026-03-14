import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safe_device/safe_device.dart';
import 'package:flutter/services.dart';

import 'package:internusa_group/screens/attendance/attendance_screen.dart';
import 'package:internusa_group/screens/attendance/attendance_statistic_screen.dart';
import 'package:internusa_group/providers/attendance_provider.dart';
import 'package:internusa_group/utils/theme.dart';

class AttendanceSelectScreen extends StatefulWidget {
  const AttendanceSelectScreen({super.key});

  @override
  State<AttendanceSelectScreen> createState() => _AttendanceSelectScreenState();
}

class _AttendanceSelectScreenState extends State<AttendanceSelectScreen> {
  List<Map<String, String>> _workSchedule = [];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      checkMockLocation();
    });

    final attendanceProvider = context.read<AttendanceProvider>();
    final tempSchedule = attendanceProvider.workSchedule;
    _workSchedule = tempSchedule;
  }

  String _getScheduleValue(String key) {
    if (_workSchedule.isNotEmpty) {
      return _workSchedule[0][key] ?? "";
    }
    return "keterangan";
  }

  Future<void> checkMockLocation() async {
    try {
      bool isMockLocation = await SafeDevice.isMockLocation;

      if (isMockLocation) {
        if (mounted) _showWarningDialog();
      } else {
        bool isDevMode = await SafeDevice.isDevelopmentModeEnable;
        if (isDevMode && mounted) {
          print("Developer Mode is ON");
        }
      }
    } catch (e) {
      print("Error checking location: $e");
    }
  }

  void _showWarningDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.r),
            ),
            title: Row(
              children: [
                Icon(Icons.warning_amber_rounded,
                    color: Colors.red, size: 28.sp),
                SizedBox(width: 10.w),
                Expanded(
                  child: Text(
                    "Lokasi Palsu Terdeteksi",
                    style:
                        TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Sistem mendeteksi Anda menggunakan aplikasi Fake GPS atau Mock Location.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(fontSize: AppDimens.fontBody),
                ),
                SizedBox(height: 16.h),
                Text(
                  "Silakan matikan aplikasi tersebut untuk melakukan absensi. Aplikasi akan ditutup untuk menjaga validitas data.",
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                      fontSize: AppDimens.fontBody,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: Text(
                  "EXIT APP",
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Color>>(
      valueListenable: AppColors.gradientNotifier,
      builder: (context, colors, _) {
        return DefaultTabController(
          length: 2,
          child: Scaffold(
            appBar: AppBar(
              elevation: 0,
              leadingWidth: 72,
              leading: Container(
                margin: EdgeInsets.only(left: 16.r),
                child: Padding(
                  padding: EdgeInsets.all(6.r),
                  child: const CircleAvatar(
                    backgroundColor: AppColors.textLight,
                    child: Icon(
                      Icons.fingerprint,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
              flexibleSpace: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [AppColors.textPrimary, AppColors.textPrimary]
                        : colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
              ),
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _getScheduleValue('employee_name').toUpperCase(),
                    style: TextStyle(
                      fontSize: AppDimens.fontHeading,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  RichText(
                    text: TextSpan(
                        style: TextStyle(
                          fontSize: AppDimens.fontBody,
                          color: Colors.white70,
                        ),
                        children: [
                          if (_workSchedule.isNotEmpty) ...[
                            const TextSpan(
                              text: 'Group : ',
                            ),
                            TextSpan(
                              text:
                                  '${_getScheduleValue('shift_template_name')}',
                              style: TextStyle(
                                fontSize: AppDimens.fontBody,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                              ),
                            ),
                          ] else ...[
                            const TextSpan(
                              text: 'Jadwal belum diatur, ',
                            ),
                            TextSpan(
                              text: ' Konfirm ke Admin',
                              style: TextStyle(
                                fontSize: AppDimens.fontBody,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textLight,
                              ),
                            ),
                          ],
                        ]),
                  ),
                ],
              ),
              bottom: TabBar(
                labelColor: AppColors.textLight,
                unselectedLabelColor: Colors.white70,
                indicatorWeight: 3,
                tabs: [
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.how_to_reg, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Presensi',
                          style: TextStyle(fontSize: AppDimens.fontBody),
                        ),
                      ],
                    ),
                  ),
                  Tab(
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.bar_chart, size: 20.sp),
                        SizedBox(width: 8.w),
                        Text(
                          'Statistik',
                          style: TextStyle(fontSize: AppDimens.fontBody),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            body: const TabBarView(
              children: [
                AttendanceScreen(),
                AttendanceStatisticScreen(),
              ],
            ),
          ),
        );
      },
    );
  }
}
