import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class DashboardHeader extends StatelessWidget {
  final int totalData;
  final int? leftData;
  final int? rightData;
  final String leftLabel;
  final String rightLabel;
  final IconData iconTotalData;
  final IconData iconLeftData;
  final IconData iconRightData;

  const DashboardHeader({
    super.key,
    required this.totalData,
    required this.leftData,
    required this.rightData,
    required this.leftLabel,
    required this.rightLabel,
    required this.iconTotalData,
    required this.iconLeftData,
    required this.iconRightData,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: Theme.of(context).brightness == Brightness.dark
                          ? [AppColors.textPrimary, AppColors.textPrimary]
                          : colors,
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned(top: -50, left: -50, child: _buildCircle(200)),
                      Positioned(top: 20, right: -20, child: _buildCircle(150)),
                      Positioned(
                          bottom: 50, left: 50, child: _buildCircle(250)),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(5.r),
                child: Row(
                  children: [
                    if (leftData != null)
                      Expanded(
                        child: _buildInfoCard(
                          icon: iconLeftData,
                          label: leftLabel,
                          value: leftData!,
                        ),
                      ),
                    Expanded(
                      child: _buildInfoCard(
                        icon: iconTotalData,
                        label: "Total",
                        value: totalData,
                        isHighlight: true,
                      ),
                    ),
                    if (rightData != null)
                      Expanded(
                        child: _buildInfoCard(
                          icon: iconRightData,
                          label: rightLabel,
                          value: rightData!,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        });
  }

  static Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.white.withOpacity(0.1),
      ),
    );
  }

  Widget _buildInfoCard({
    required IconData icon,
    required String label,
    required int value,
    bool isHighlight = false,
  }) {
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.r),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: isHighlight
              ? Colors.white.withOpacity(0.25)
              : Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(16.r),
        ),
        padding: EdgeInsets.all(8.r),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(icon, size: 28.sp, color: Colors.white),
            SizedBox(height: 8.h),
            Text(
              label,
              style: TextStyle(
                fontSize: 13.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            SizedBox(height: 4.h),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: 18.sp,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
