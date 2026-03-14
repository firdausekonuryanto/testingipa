import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/leave.dart';
import 'package:internusa_group/screens/task/widgets/info_row.dart';

import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/utils/theme.dart';

class LeaveCard extends StatelessWidget {
  final Leave leave;

  const LeaveCard({super.key, required this.leave});

  IconData _getIcon(String type) {
    switch (type.toLowerCase()) {
      case "sick":
        return Icons.local_hospital;
      case "maternity":
        return Icons.child_friendly;
      case "annual":
        return Icons.flight_takeoff;
      default:
        return Icons.assignment;
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(vertical: 8.h),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
      ),
      elevation: 3,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: Padding(
          padding: EdgeInsets.all(12.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.w,
                    decoration: BoxDecoration(
                        shape: BoxShape.circle, color: colorScheme.primary),
                    child: Icon(_getIcon(leave.type),
                        size: 28.sp, color: colorScheme.onSecondary),
                  ),
                  SizedBox(width: 12.w),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              "Pengajuan Cuti - ${capitalizeFirst(leave.type)}",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimens.fontTitle,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.myLightYellow
                                    : AppColors.textPrimary,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: 2.h),
                        Row(children: [
                          Icon(
                            Icons.check_circle_outline,
                            size: AppDimens.fontBody,
                            color: AppColors.checkIn,
                          ),
                          SizedBox(width: 4.w),
                          Text(
                            "Sent : ${formatDateIndonesia(leave.dateSubmitted)}",
                            style: TextStyle(
                              fontSize: AppDimens.fontBody,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.myLightGreen
                                  : AppColors.textSecondary,
                            ),
                          ),
                          SizedBox(
                            width: 5.w,
                          ),
                        ]),
                      ],
                    ),
                  ),
                ],
              ),
              Divider(
                thickness: 1,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withValues(alpha: 0.12)
                    : Colors.grey.shade400.withValues(alpha: 0.7),
              ),
              InfoRow(
                  icon: Icons.date_range,
                  label: "Tanggal",
                  value: leave.dateRange),
              InfoRow(
                  icon: Icons.date_range, label: "Alasan", value: leave.reason),
              InfoRow(
                icon: Icons.date_range,
                label: "Status",
                value: leave.status,
              ),
              SizedBox(height: 4.h),
              if (leave.status == 'rejected') ...[
                InfoRow(
                  icon: Icons.date_range,
                  label: "Penolakan",
                  value: leave.rejectionReason,
                  iconColor: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.myLightRed
                      : AppColors.error,
                ),
              ],
              if (leave.medicalImage != '-') ...[
                SizedBox(height: 4.h),
                GestureDetector(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (_) => Dialog(
                        backgroundColor: Colors.transparent,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).pop(),
                          child: InteractiveViewer(
                            child: Image.network(
                              "${leave.medicalImage}",
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                  child: Text(
                    "Lihat Gambar",
                    style: TextStyle(
                      fontSize: 13.sp,
                      color: colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
