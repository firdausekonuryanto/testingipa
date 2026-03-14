import 'package:internusa_group/providers/app_notification_provider.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:in_app_update/in_app_update.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/providers/update_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/providers/attendance_provider.dart';
import 'package:internusa_group/providers/work_schedule_provider.dart';

import 'package:internusa_group/models/attendance.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/widgets/menu_grid.dart';
import 'package:internusa_group/widgets/loading/loading_widget.dart';

import 'package:internusa_group/screens/home/widgets/header_content.dart';
import 'package:internusa_group/screens/home/widgets/header_gradient.dart';
import 'package:internusa_group/screens/home/widgets/attendance_card.dart';
import 'package:internusa_group/screens/home/widgets/history_section.dart';

import 'package:internusa_group/services/realtime_service.dart';

enum NotificationFilter { unread, read }

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic> todayScheduleSubmit = {};
  List<Map<String, String>> workSchedule = [];
  List<Attendance> historyAttendance = [];
  bool showAll = false;
  int countNotification = 0;

  final RealtimeService realtime = RealtimeService();
  bool _realtimeConnected = false;
  bool _isInitializingRealtime = false;
  int? employeeId;

  @override
  void initState() {
    super.initState();
    checkForUpdate();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _refreshAll();
      await _initRealtime();
    });
  }

  @override
  void dispose() {
    realtime.disconnect();
    _realtimeConnected = false;
    super.dispose();
  }

  Future<void> _initRealtime() async {
    if (_realtimeConnected || _isInitializingRealtime) {
      return;
    }

    _isInitializingRealtime = true;

    final notifProvider = context.read<AppNotificationProvider>();

    if (employeeId == null) {
      _isInitializingRealtime = false;
      return;
    }

    try {
      await realtime.connect(
        employeeId: employeeId.toString(),
        onNotification: (data) {
          notifProvider.insertRealtime(data);
          setState(() => countNotification++);
          notifProvider.getNotifications();
        },
      );

      _realtimeConnected = true;
    } catch (e) {
      debugPrint("❌ Realtime init failed: $e");
    } finally {
      _isInitializingRealtime = false;
    }
  }

  Future<void> checkForUpdate() async {
    try {
      final info = await InAppUpdate.checkForUpdate();

      if (info.updateAvailability == UpdateAvailability.updateAvailable) {
        await InAppUpdate.performImmediateUpdate();
      }
    } catch (e) {
      print("Terjadi kesalahan saat update: $e");
    }
  }

  Future<void> _refreshAll() async {
    NotificationFilter _filter = NotificationFilter.unread;
    final auth = context.read<AuthProvider>();
    await auth.getCurrentUser();

    final notifProvider = context.read<AppNotificationProvider>();
    await notifProvider.getNotifications();

    final provider = context.read<AppNotificationProvider>();

    final notifications = provider.notifications
        .where(
            (e) => _filter == NotificationFilter.unread ? !e.isRead : e.isRead)
        .toList();

    countNotification = notifications.length;
    final user = auth.currentUser;
    employeeId = user?.employee?.id;

    if (user != null) {
      final attendanceProvider = context.read<AttendanceProvider>();

      await Future.wait([
        attendanceProvider.fetchWorkSchedules(),
        attendanceProvider.fetchTodayAttendances(),
        attendanceProvider.fetchAllAttendances(),
        context.read<WorkScheduleProvider>().fetchTodaySchedules(),
      ]);

      setState(() {
        todayScheduleSubmit = attendanceProvider.todayAttendances;
        workSchedule = attendanceProvider.workSchedule;

        final list = attendanceProvider.attendances;
        historyAttendance = list.length > 7 ? list.sublist(0, 7) : list;
      });
    }
  }

  void toggleHistory() {
    final attendanceProvider = context.read<AttendanceProvider>();
    final list = attendanceProvider.attendances;

    setState(() {
      showAll = !showAll;
      if (showAll) {
        historyAttendance = list;
      } else {
        historyAttendance = list.length > 7 ? list.sublist(0, 7) : list;
      }
    });
  }

  String? formatTime(dynamic value) {
    if (value == null) return null;

    try {
      final dt =
          value is DateTime ? value : DateTime.tryParse(value.toString());
      if (dt == null) return null;
      return DateFormat('HH:mm').format(dt);
    } catch (e) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(10),
      body: Consumer2<AuthProvider, WorkScheduleProvider>(
        builder: (context, auth, schedule, _) {
          if (auth.isLoading) {
            return const LoadingWidget();
          }

          if (auth.error != null) {
            return _errorState(auth.error!, onRetry: () {
              auth.getCurrentUser();
              schedule.fetchTodaySchedules();
            });
          }

          final user = auth.currentUser;
          if (user == null) {
            return _errorState('User data not available', onRetry: () {
              auth.getCurrentUser();
              schedule.fetchTodaySchedules();
            });
          }

          final employeeName = user.employee?.name ?? user.username;
          final department = user.employee?.company?.name ?? 'Department';
          final positionName = user.employee?.position?.name ?? '—';

          return RefreshIndicator(
            onRefresh: _refreshAll,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  HeaderGradient(
                      child: Column(
                    children: [
                      HeaderContent(
                        countNotif: countNotification,
                        department: department,
                        name: employeeName.toUpperCase(),
                        position: positionName,
                        avatarLetter: employeeName.isNotEmpty
                            ? employeeName[0].toUpperCase()
                            : 'U',
                        onBellTap: () async {
                          await Navigator.pushNamed(
                              context, RoutesNames.notification);
                          await _refreshAll();
                        },
                      ),
                      Padding(
                        padding: EdgeInsets.fromLTRB(0, 16, 0, 0),
                        child: AttendanceCard(
                          dateText:
                              'Hari ini · ${DateFormat('dd MMM yyyy').format(DateTime.now())}',
                          workHourText: workSchedule.isNotEmpty &&
                                  workSchedule[0]['shift_start'] != 'null'
                              ? '${workSchedule[0]['shift_start'] ?? ''} - ${workSchedule[0]['shift_end'] ?? ''}'
                              : '',
                          checkIn:
                              formatTime(todayScheduleSubmit['clockIn']) ?? '-',
                          checkOut:
                              formatTime(todayScheduleSubmit['clockOut']) ??
                                  '-',
                        ),
                      ),
                    ],
                  )),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                      child: MenuGrid(
                        items: [
                          // MenuItemData(
                          //   icon: Icons.access_time,
                          //   bgIcon: AppColors.myLightYellow,
                          //   colorIcon: AppColors.myYellow,
                          //   label: 'LapRetail',
                          //   onTap: () => Navigator.pushNamed(
                          //       context, RoutesNames.laporanRetail),
                          // ),
                          // MenuItemData(
                          //   icon: Icons.event_note,
                          //   bgIcon: AppColors.myLightYellow,
                          //   colorIcon: AppColors.checkOut,
                          //   label: 'LapODP',
                          //   onTap: () => Navigator.pushNamed(
                          //       context, RoutesNames.laporanOdp),
                          // ),
                          MenuItemData(
                            icon: Icons.bar_chart_rounded,
                            bgIcon: AppColors.myLightGreen,
                            colorIcon: AppColors.checkIn,
                            label: 'KPI',
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, RoutesNames.kpi);
                              await _refreshAll();
                            },
                          ),
                          MenuItemData(
                            icon: Icons.work_outline_rounded,
                            bgIcon: AppColors.myLightRed,
                            colorIcon: AppColors.checkOut,
                            label: 'Salary',
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, RoutesNames.salary);
                              await _refreshAll();
                            },
                          ),
                          MenuItemData(
                            icon: Icons.watch_later,
                            bgIcon: AppColors.primary,
                            colorIcon: AppColors.primaryDark,
                            label: 'Cuti',
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, RoutesNames.leave);
                              await _refreshAll();
                            },
                          ),
                          // MenuItemData(
                          //   icon: Icons.stop_circle,
                          //   bgIcon: AppColors.myOrange,
                          //   colorIcon: AppColors.textPrimary,
                          //   label: 'TusLang',
                          //   onTap: () => Navigator.pushNamed(
                          //       context, RoutesNames.productSubscription),
                          // ),
                          MenuItemData(
                            icon: Icons.grid_view_rounded,
                            bgIcon: AppColors.myLightYellow,
                            colorIcon: AppColors.myPurple,
                            label: 'Report',
                            onTap: () async {
                              await Navigator.pushNamed(
                                  context, RoutesNames.indexdynamicfrom);
                              await _refreshAll();
                            },
                          ),
                        ],
                      )),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
                    child: HistorySection(
                      onSeeAll: toggleHistory,
                      items: historyAttendance,
                      showAll: showAll,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorState(String message, {required VoidCallback onRetry}) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(message, style: TextStyle(color: AppColors.error)),
          SizedBox(height: 12.h),
          ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
        ],
      ),
    );
  }
}
