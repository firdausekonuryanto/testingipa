import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class AttendanceCard extends StatelessWidget {
  final Widget? titleWidget;
  final Widget titleMyPosition;
  final String buttonLabel;
  final Color buttonColor;
  final VoidCallback? onTap;
  final Animation<double>? animation;
  final Map<String, dynamic>? data;
  final String inOut;
  final String stsLocationIn;
  final String stsLocationOut;
  final bool isProcessing;

  const AttendanceCard({
    super.key,
    this.titleWidget,
    required this.titleMyPosition,
    required this.buttonLabel,
    required this.buttonColor,
    required this.onTap,
    required this.animation,
    required this.data,
    required this.inOut,
    required this.stsLocationIn,
    required this.stsLocationOut,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    final timeText =
        data != null ? DateFormat('HH:mm:ss').format(data!["time"]) : null;

    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    final Color locationColor =
        (inOut == 'in' ? stsLocationIn : stsLocationOut) == 'didalam'
            ? AppColors.attendanceInArea
            : AppColors.checkOut;

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          children: [
            if (titleWidget != null)
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    color:
                        isDark ? AppColors.textLight : AppColors.textSecondary,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  Expanded(child: titleWidget!),
                ],
              ),
            SizedBox(height: 5.h),

            // Lokasi
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: locationColor,
                  size: 20.sp,
                ),
                SizedBox(width: 8.w),
                Expanded(child: titleMyPosition),
              ],
            ),

            SizedBox(height: 10.h),

            // Tombol + animasi
            Center(
              child: Material(
                color: Colors.transparent,
                child: InkResponse(
                  onTap: onTap,
                  containedInkWell: true,
                  customBorder: const CircleBorder(),
                  splashColor: Colors.white.withOpacity(0.2),
                  highlightColor: Colors.white.withOpacity(0.1),
                  child: animation != null
                      ? ScaleTransition(
                          scale: animation!,
                          child: AttendanceButton(
                            label: buttonLabel,
                            color: buttonColor,
                            time: timeText,
                            isProcessing: isProcessing,
                          ),
                        )
                      : AttendanceButton(
                          label: buttonLabel,
                          color: buttonColor,
                          time: timeText,
                          isProcessing: isProcessing,
                        ),
                ),
              ),
            ),

            if (data != null && data!["status"] != null) ...[
              SizedBox(height: 5.h),
              Text(
                "Status: ${data!["status"]}",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: data!["status"] == "Terlambat"
                      ? AppColors.checkOut
                      : AppColors.checkIn,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class AttendanceButton extends StatelessWidget {
  final String label;
  final Color color;
  final String? time;
  final bool isProcessing;

  const AttendanceButton({
    super.key,
    required this.label,
    required this.color,
    this.time,
    this.isProcessing = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 170.w,
      height: 170.h,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: AppColors.background.withValues(alpha: 0.5),
          width: 10.w,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.textPrimary.withValues(alpha: 0.1),
            blurRadius: 6,
            spreadRadius: 2,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: isProcessing
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.textLight),
            )
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt,
                  color: AppColors.background.withValues(alpha: 0.7),
                  size: 24.sp,
                ),
                SizedBox(height: 6.sp),
                Text(
                  label,
                  style: TextStyle(
                    color: AppColors.textLight,
                    fontSize: AppDimens.fontHeading,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 6.sp),
                StreamBuilder<String>(
                  stream: Stream.periodic(const Duration(seconds: 1), (_) {
                    final now = DateTime.now();
                    return "${now.hour.toString().padLeft(2, '0')}:"
                        "${now.minute.toString().padLeft(2, '0')}:"
                        "${now.second.toString().padLeft(2, '0')}";
                  }),
                  builder: (context, snapshot) {
                    return Text(
                      snapshot.data ?? "",
                      style: TextStyle(
                        color: AppColors.background,
                        fontSize: AppDimens.fontTitle,
                      ),
                    );
                  },
                ),
                if (time != null) ...[
                  SizedBox(height: 2.h),
                  Text(
                    time!,
                    style: TextStyle(
                      color: AppColors.textLight,
                      fontSize: 14.sp,
                    ),
                  ),
                ],
              ],
            ),
    );
  }
}
