import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:intl/intl.dart';
import '../../utils/theme.dart';

class CardReport extends StatelessWidget {
  final String title;
  final String purpose;
  final String branchName;
  final String? createdAt;
  final VoidCallback routeVoidCallback;

  const CardReport({
    super.key,
    required this.title,
    required this.purpose,
    required this.branchName,
    required this.createdAt,
    required this.routeVoidCallback,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textSecondary.withOpacity(0.3)
            : Colors.white,
        borderRadius: BorderRadius.circular(14.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black12.withOpacity(0.06),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 12.h),
        child: Row(
          children: [
            Container(
              height: 38,
              width: 38,
              decoration: BoxDecoration(
                color: _getIconBgColor(purpose),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                _getIcon(purpose),
                color: _getIconColor(purpose),
                size: 20,
              ),
            ),
            SizedBox(width: 12.w),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 13.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textLight
                          : Colors.black87,
                    ),
                    softWrap: true,
                  ),
                  SizedBox(height: 4.h),
                  Text(
                    "Cabang : ${branchName}",
                    style: TextStyle(
                      fontSize: 12.sp,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                    ),
                    softWrap: true,
                  ),
                  SizedBox(height: 4.h),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 12,
                        color: Colors.grey,
                      ),
                      SizedBox(width: 4.w),
                      Text(
                        createdAt != null
                            ? DateFormat("dd MMM yyyy • HH:mm", "id_ID")
                                .format(DateTime.parse(createdAt!))
                            : "-",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightGreen
                              : Colors.grey[600],
                          fontSize: 11.sp,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            InkWell(
              borderRadius: BorderRadius.circular(50),
              onTap: routeVoidCallback,
              child: Container(
                padding: EdgeInsets.all(8.r),
                decoration: BoxDecoration(
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.myLightYellow
                      : Colors.grey.shade100,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.remove_red_eye_outlined,
                  color: Colors.black54,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // === Helper methods ===
  IconData _getIcon(String purpose) {
    if (purpose.toLowerCase().contains("psb")) {
      return Icons.cable; // ikon kabel
    } else if (purpose.toLowerCase().contains("repair")) {
      return Icons.build; // ikon repair
    }
    return Icons.description_outlined; // default
  }

  Color _getIconBgColor(String purpose) {
    if (purpose.toLowerCase().contains("psb")) {
      return const Color.fromARGB(255, 166, 217, 253);
    } else if (purpose.toLowerCase().contains("repair")) {
      return const Color.fromARGB(255, 247, 224, 183);
    }
    return Colors.grey.shade200;
  }

  Color _getIconColor(String purpose) {
    if (purpose.toLowerCase().contains("psb")) {
      return Colors.blue;
    } else if (title.toLowerCase().contains("repair")) {
      return Colors.red;
    }
    return Colors.grey;
  }
}
