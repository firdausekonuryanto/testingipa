import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/theme.dart';

class DashboardHeaderLeave extends StatelessWidget {
  final int totalData;
  final int sick;
  final int annual;
  final int maternity;
  final int marriage;
  final int other;

  const DashboardHeaderLeave({
    super.key,
    required this.totalData,
    required this.sick,
    required this.annual,
    required this.maternity,
    required this.marriage,
    required this.other,
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
              // Grid Cards
              Container(
                padding: EdgeInsets.all(8.r),
                child: GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 2.w,
                  mainAxisSpacing: 2.h,
                  childAspectRatio: 3.5,
                  children: [
                    _buildInfoCard(
                      context: context,
                      icon: Icons.bar_chart,
                      label: "Total Data",
                      value: totalData,
                    ),
                    _buildInfoCard(
                      context: context,
                      icon: Icons.sick,
                      label: "Sick",
                      value: sick,
                    ),
                    _buildInfoCard(
                      context: context,
                      icon: Icons.calendar_month,
                      label: "Annual",
                      value: annual,
                    ),
                    _buildInfoCard(
                      context: context,
                      icon: Icons.child_friendly,
                      label: "Maternity",
                      value: maternity,
                    ),
                    _buildInfoCard(
                      context: context,
                      icon: Icons.favorite,
                      label: "Marriage",
                      value: marriage,
                    ),
                    _buildInfoCard(
                      context: context,
                      icon: Icons.more_horiz,
                      label: "Other",
                      value: other,
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
    required BuildContext context,
    required IconData icon,
    required String label,
    required int value,
  }) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      color: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4.r),
      ),
      elevation: 0,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.15),
          borderRadius: BorderRadius.circular(8.r),
        ),
        padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Icon(icon, size: 22.sp, color: colorScheme.primary),
                SizedBox(width: 8.w),
                Text(
                  label,
                  style: TextStyle(
                    fontSize: AppDimens.fontBody,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            Text(
              value.toString(),
              style: TextStyle(
                fontSize: AppDimens.fontTitle,
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
