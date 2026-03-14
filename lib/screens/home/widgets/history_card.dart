import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/attendance.dart';
import 'package:internusa_group/routes/namedroutes.dart';
import 'package:internusa_group/utils/theme.dart';

import 'package:intl/intl.dart';

class HistoryCard extends StatelessWidget {
  final Attendance item;
  const HistoryCard({required this.item});

  bool _isLate(String? shiftInString, String? clockInString) {
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final shiftIn = DateTime.tryParse('$dateString $shiftInString');
    final clockIn = DateTime.tryParse('$dateString $clockInString');

    if (shiftIn == null || clockIn == null) {
      return false;
    }

    return clockIn.isAfter(shiftIn);
  }

  bool _isEarly(String? shiftOutString, String? clockOutString) {
    final now = DateTime.now();
    final dateString =
        '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';

    final shiftOut = DateTime.tryParse('$dateString $shiftOutString');
    final clockOut = DateTime.tryParse('$dateString $clockOutString');

    if (shiftOut == null || clockOut == null) {
      return false;
    }

    return clockOut.isBefore(shiftOut);
  }

  Widget _timeRow({
    required IconData icon,
    required String label,
    required String? time,
    bool isLate = false,
    required Color color,
  }) {
    final displayTime = (time == null || time.isEmpty) ? '-' : time;
    final iconColor = color;

    return Row(
      children: [
        Icon(icon, size: 18.sp, color: iconColor),
        SizedBox(width: 6.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: AppDimens.fontCaption,
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              displayTime,
              style: TextStyle(
                fontSize: AppDimens.fontTitle,
                color: color,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat('dd MMM yyyy').format(item.createdAt);
    if (item.shiftIn == null && item.shiftOut == null) {
      return GestureDetector(
        onTap: () => {},
        child: Container(
          margin: EdgeInsets.only(bottom: 16.r),
          padding: EdgeInsets.all(16.r),
          decoration: BoxDecoration(
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.textSecondary.withOpacity(0.10)
                : AppColors.surface,
            borderRadius: BorderRadius.circular(14.r),
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                          fontWeight: FontWeight.w900,
                          fontSize: AppDimens.fontBody),
                    ),
                  ),
                  Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                    decoration: BoxDecoration(
                      color: AppColors.textSecondary,
                      borderRadius: BorderRadius.circular(20.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.warning_amber_rounded,
                          color: Colors.yellow[600],
                          size: AppDimens.fontBody,
                        ),
                        SizedBox(width: 4.w),
                        Text(
                          "Jadwal belum Diset",
                          style: TextStyle(
                            color: AppColors.background,
                            fontWeight: FontWeight.w700,
                            fontSize: AppDimens.fontCaption,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _timeRow(
                    icon: Icons.login,
                    label: 'Jam Masuk',
                    time: item.clockIn,
                    isLate: false,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                  _timeRow(
                    icon: Icons.login,
                    label: 'Jam Keluar',
                    time: item.clockIn,
                    isLate: false,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.textLight
                        : AppColors.textPrimary,
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    }

    final jamMasukLate = _isLate(item.shiftIn, item.clockIn);
    final jamKeluarEarly = _isEarly(item.shiftOut, item.clockOut);

    int minutesLate = 0;
    int minutesEarly = 0;
    DateTime shiftInTime = DateTime(2000, 1, 1, 8, 0, 0);
    DateTime shiftOutTime = DateTime(2000, 1, 1, 8, 0, 0);
    String badge = '';
    bool stsToday = false;

    if (item.clockIn != null && item.shiftIn != null) {
      final clockInTime = DateFormat("HH:mm:ss").parse(item.clockIn!);
      shiftInTime = DateFormat("HH:mm:ss").parse(item.shiftIn!);
      bool isLate = clockInTime.isAfter(shiftInTime);
      if (isLate) {
        minutesLate = clockInTime.difference(shiftInTime).inMinutes;
        stsToday = true;
      }

      badge = stsToday ? 'Terlambat ' : 'Normal';
    } else {
      badge = 'Shift Belum Diatur';
    }
    if (item.clockOut != null) {
      final clockOutTime = DateFormat("HH:mm:ss").parse(item.clockOut!);
      shiftOutTime = DateFormat("HH:mm:ss").parse(item.shiftOut!);
      bool isEarly = clockOutTime.isBefore(shiftOutTime);

      if (isEarly) {
        minutesEarly = (clockOutTime.difference(shiftOutTime).inMinutes) - 1;
        stsToday = true;
      }
    }
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        RoutesNames.attendanceDetail,
        arguments: {
          'item': item,
          'minutesLate': minutesLate,
          'minutesEarly': minutesEarly,
        },
      ),
      child: Container(
        margin: EdgeInsets.only(bottom: 16.r),
        padding: EdgeInsets.all(16.r),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textSecondary.withOpacity(0.10)
              : AppColors.surface,
          borderRadius: BorderRadius.circular(14.r),
        ),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    formattedDate,
                    style: GoogleFonts.poppins(
                        fontWeight: FontWeight.w900,
                        fontSize: AppDimens.fontBody),
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.symmetric(horizontal: 10.w, vertical: 2.h),
                  decoration: BoxDecoration(
                    color: badge != 'Normal'
                        ? AppColors.myLightYellow
                        : AppColors.myLightGreen,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Text(
                    badge,
                    style: TextStyle(
                      color: badge != 'Normal'
                          ? const Color.fromARGB(255, 131, 100, 8)
                          : const Color.fromARGB(255, 3, 82, 9),
                      fontWeight: FontWeight.w700,
                      fontSize: AppDimens.fontCaption,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10.h),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _timeRow(
                    icon: Icons.login,
                    label: 'Jam Masuk',
                    time: item.clockIn,
                    isLate: jamMasukLate,
                    color: jamMasukLate
                        ? Theme.of(context).brightness == Brightness.dark
                            ? AppColors.myLightRed
                            : AppColors.error
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textLight
                            : AppColors.textPrimary),
                _timeRow(
                    icon: Icons.logout,
                    label: 'Jam Pulang',
                    time: item.clockOut,
                    isLate: jamKeluarEarly,
                    color: jamKeluarEarly
                        ? Theme.of(context).brightness == Brightness.dark
                            ? AppColors.myLightRed
                            : AppColors.error
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textLight
                            : AppColors.textPrimary),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
