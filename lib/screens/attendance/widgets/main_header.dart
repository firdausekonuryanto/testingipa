import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class MainHeader extends StatelessWidget {
  final List<Color> colors;
  final String employeeName;
  final String employeeOffice;
  final String shiftTemplateName;
  final Brightness brightness;

  const MainHeader({
    super.key,
    required this.colors,
    required this.employeeName,
    required this.employeeOffice,
    required this.shiftTemplateName,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 6.h, horizontal: 16.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(height: 10.h),
          Container(
            padding: EdgeInsets.all(14.w),
            decoration: BoxDecoration(
              color: brightness == Brightness.dark
                  ? Colors.white.withOpacity(0.08)
                  : AppColors.background,
              borderRadius: BorderRadius.circular(16.r),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.12),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.person,
                            size: 16,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              employeeName.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.apartment,
                            size: 14,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              employeeOffice,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 6.h),
                      Row(
                        children: [
                          const Icon(
                            Icons.groups,
                            size: 14,
                          ),
                          SizedBox(width: 6.w),
                          Expanded(
                            child: Text(
                              'Grup : $shiftTemplateName',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                color: brightness == Brightness.dark
                                    ? AppColors.myLightYellow
                                    : AppColors.textPrimary,
                                fontSize: 12.sp,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: 10.w,
                    vertical: 8.h,
                  ),
                  decoration: BoxDecoration(
                    color: brightness == Brightness.dark
                        ? AppColors.secondaryLight
                        : AppColors.secondaryLight,
                    borderRadius: BorderRadius.circular(20.r),
                  ),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.calendar_today,
                        size: 14,
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        DateFormat('dd MMM yy').format(DateTime.now()),
                        style: TextStyle(
                          fontSize: 11.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
