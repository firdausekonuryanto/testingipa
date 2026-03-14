import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? iconColor;
  final Color? badgeColor;

  const InfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
    this.badgeColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final resolvedIconColor = iconColor ?? colorScheme.secondary;
    final isBadge = value == 'Completed';
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Container(
            padding: EdgeInsets.all(6.r),
            decoration: BoxDecoration(
              color: resolvedIconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6.r),
            ),
            child: Icon(
              icon,
              color: resolvedIconColor,
              size: AppDimens.fontBody,
            ),
          ),

          SizedBox(width: 10.w),

          // 👉 LABEL (FIXED WIDTH)
          SizedBox(
            width: 90.w, // 🔥 adjust this
            child: Text(
              label,
              style: TextStyle(
                fontSize: AppDimens.fontBody,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.grey[300]
                    : Colors.grey[700],
              ),
            ),
          ),

          // colon
          Text(
            ":",
            style: TextStyle(
              fontSize: AppDimens.fontBody,
              fontWeight: FontWeight.w500,
            ),
          ),

          SizedBox(width: 6.w),

          // 👉 VALUE (FLEXIBLE)
          Expanded(
            child: isBadge
                ? Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: 8.w,
                      vertical: 4.h,
                    ),
                    decoration: BoxDecoration(
                      color:
                          (badgeColor ?? colorScheme.primary).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Text(
                      value,
                      style: TextStyle(
                        fontSize: 13.sp,
                        fontWeight: FontWeight.w600,
                        color: badgeColor ?? colorScheme.primary,
                      ),
                    ),
                  )
                : Text(
                    value,
                    style: TextStyle(
                      fontSize: AppDimens.fontBody,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? Colors.white
                          : Colors.black87,
                    ),
                  ),
          ),
        ],
      ),
    );
  }
}
