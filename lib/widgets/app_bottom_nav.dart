import 'package:flutter/material.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AppBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemTapped;

  const AppBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemTapped,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: isDark ? AppColors.textPrimary : AppColors.background,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 6.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _navItem(
              index: 0,
              isSelected: currentIndex == 0,
              icon: Icons.remove_red_eye,
              label: "View",
              isDark: isDark,
            ),
            _navItem(
              index: 1,
              isSelected: currentIndex == 1,
              icon: Icons.edit_note,
              label: "Write",
              isDark: isDark,
            ),
          ],
        ),
      ),
    );
  }

  Widget _navItem({
    required int index,
    required bool isSelected,
    required IconData icon,
    required String label,
    required bool isDark,
  }) {
    return InkResponse(
      onTap: () => onItemTapped(index),
      radius: 34.r,
      containedInkWell: true,
      splashColor: AppColors.textSecondary.withOpacity(0.5),
      highlightColor: AppColors.textSecondary.withOpacity(0.3),
      child: Padding(
        padding: EdgeInsets.symmetric(vertical: 4.h, horizontal: 16.h),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(isSelected ? 6.r : 0.r),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.textSecondary.withOpacity(0.3),
              ),
              child: Icon(
                icon,
                size: isSelected ? 27.sp : 25.sp,
                color: isSelected
                    ? (isDark ? AppColors.background : AppColors.textPrimary)
                    : AppColors.textSecondary,
              ),
            ),
            SizedBox(height: 3.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 12.sp,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                color: isSelected
                    ? (isDark ? AppColors.background : AppColors.textPrimary)
                    : AppColors.textSecondary,
              ),
            )
          ],
        ),
      ),
    );
  }
}
