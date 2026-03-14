import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class CustomNavItem extends StatelessWidget {
  final bool isActive;
  final IconData activeIcon;
  final IconData inactiveIcon;
  final String label;
  final VoidCallback onTap;

  const CustomNavItem({
    super.key,
    required this.isActive,
    required this.activeIcon,
    required this.inactiveIcon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive
                  ? (isDark
                      ? AppColors.textSecondary.withOpacity(0.1)
                      : AppColors.primary.withOpacity(0.15))
                  : Colors.transparent,
            ),
            child: Icon(
              isActive ? activeIcon : inactiveIcon,
              size: 24.sp,
              color: isActive
                  ? (isDark ? AppColors.textLight : AppColors.primary)
                  : (isDark ? AppColors.textSecondary : Colors.grey),
            ),
          ),
          SizedBox(height: 3.h),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.sp,
              fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              color: isActive
                  ? (isDark ? AppColors.textLight : AppColors.primary)
                  : (isDark ? AppColors.textSecondary : Colors.grey),
            ),
          ),
        ],
      ),
    );
  }
}
