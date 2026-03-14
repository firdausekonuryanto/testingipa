import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/providers/attendance_provider.dart';
import 'package:internusa_group/screens/attendance/attendance_calender_screen.dart';

class AttendanceStatisticScreen extends StatefulWidget {
  const AttendanceStatisticScreen({super.key});

  @override
  State<AttendanceStatisticScreen> createState() =>
      _AttendanceStatisticScreenState();
}

class _AttendanceStatisticScreenState extends State<AttendanceStatisticScreen> {
  bool showPresent = false;
  bool showAbsent = false;
  bool showOffsite = false;
  DateTime _currentDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AttendanceProvider>().fetchMontlyAttendances();
    });
  }

  Widget _buildRow({
    required String title,
    required String value,
    required bool expanded,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 14.h, horizontal: 16.w),
        child: Row(
          children: [
            Text(title, style: TextStyle(fontSize: AppDimens.fontBody)),
            const Spacer(),
            Text(value, style: const TextStyle(color: AppColors.textSecondary)),
            SizedBox(width: 6.w),
            Icon(
              expanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDates(List<String> dates) {
    if (dates.isEmpty) {
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
        child: Text(
          'No data',
          style: TextStyle(
              fontSize: AppDimens.fontBody, color: AppColors.textSecondary),
        ),
      );
    }

    return Column(
      children: dates
          .map(
            (date) => Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  date,
                  style: TextStyle(fontSize: AppDimens.fontBody),
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  PreferredSize _buildAppBar(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    String monthName =
        DateFormat('MMMM', 'id_ID').format(_currentDate).toUpperCase();
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight + 20),
      child: Padding(
        padding: EdgeInsets.only(top: 20.r),
        child: AppBar(
          elevation: 0,
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? Colors.transparent
              : AppColors.textLight,
          surfaceTintColor: Colors.transparent,
          title: RichText(
            text: TextSpan(
              style: TextStyle(
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.background
                    : AppColors.textPrimary,
              ),
              children: [
                TextSpan(
                  text: 'LAPORAN ',
                  style: TextStyle(
                    fontSize: AppDimens.fontTitle,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                TextSpan(
                  text: '(${monthName} ${_currentDate.year})',
                  style: TextStyle(
                    fontSize: AppDimens.fontBody,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AttendanceCalenderScreen(),
                  ),
                );
              },
              icon: Icon(
                Icons.calendar_today,
                color: colorScheme.primary,
              ),
              label: Text(
                'Kalender',
                style: TextStyle(
                  color: colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<String> _formatDates(List<String> dates) {
    return dates.map((d) {
      final date = DateTime.parse(d);
      return DateFormat('dd MMM yyyy').format(date);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator());
        }

        if (provider.error != null) {
          return Center(child: Text(provider.error!));
        }

        if (provider.attendanceMontly == null) {
          return const Center(child: Text('Data tidak tersedia'));
        }

        final data = provider.attendanceMontly!;
        final theme = Theme.of(context);
        final colorScheme = theme.colorScheme;
        return Scaffold(
          backgroundColor: colorScheme.surface,
          appBar: _buildAppBar(context),
          body: ListView(
            children: [
              _buildRow(
                title: 'Kehadiran',
                value: '${data.qtyPresent} Hari',
                expanded: showPresent,
                onTap: () {
                  setState(() => showPresent = !showPresent);
                },
              ),
              if (showPresent) _buildDates(_formatDates(data.present)),
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.textPrimary.withOpacity(0.1),
                      blurRadius: 2.r,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              _buildRow(
                title: 'Tidak Hadir',
                value: '${data.qtyAbsent} Hari',
                expanded: showAbsent,
                onTap: () {
                  setState(() => showAbsent = !showAbsent);
                },
              ),
              if (showAbsent) _buildDates(_formatDates(data.absent)),
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.textPrimary.withOpacity(0.1),
                      blurRadius: 2.r,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              _buildRow(
                title: 'Diluar Kantor',
                value: '${data.qtyOffsite} Kali',
                expanded: showOffsite,
                onTap: () {
                  setState(() => showOffsite = !showOffsite);
                },
              ),
              if (showOffsite) _buildDates(_formatDates(data.offsite)),
              Container(
                height: 1,
                width: double.infinity,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white.withOpacity(0.1)
                          : AppColors.textPrimary.withOpacity(0.1),
                      blurRadius: 2.r,
                      spreadRadius: 0,
                      offset: const Offset(0, 1),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: EdgeInsets.all(16.r),
                child: Text(
                  "Rata - rata durasi kerja : ${data.averageInMonth}",
                  style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppDimens.fontBody),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
