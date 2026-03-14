import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/screens/home/widgets/wave_background_painter.dart';
import 'package:internusa_group/screens/home/widgets/check_box.dart';

import 'package:internusa_group/utils/theme.dart';

class AttendanceCard extends StatefulWidget {
  final String dateText;
  final String workHourText;
  final String checkIn;
  final String checkOut;

  const AttendanceCard({
    required this.dateText,
    required this.workHourText,
    required this.checkIn,
    required this.checkOut,
  });

  @override
  State<AttendanceCard> createState() => _AttendanceCardState();
}

class _AttendanceCardState extends State<AttendanceCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 8),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: BorderRadius.circular(16.r),
      child: ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          final waveColor = colorScheme.primary;

          return AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              return CustomPaint(
                painter: WaveBackgroundPainter(_controller.value, waveColor),
                child: Container(
                  padding: EdgeInsets.all(14.r),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(16.r),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textLight.withOpacity(0.10),
                        blurRadius: AppDimens.fontBody,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.dateText.replaceAll('·', ':'),
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            widget.workHourText,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12.h),
                      Row(
                        children: [
                          Expanded(
                            child: CheckBox(
                              icon: Icons.login,
                              iconBg: const Color(0xFFE9F7EE),
                              iconColor: const Color.fromARGB(255, 17, 128, 55),
                              label: 'CHECK IN',
                              time: widget.checkIn,
                            ),
                          ),
                          SizedBox(width: 12.h),
                          Expanded(
                            child: CheckBox(
                              icon: Icons.logout,
                              iconBg: const Color(0xFFFCEAEA),
                              iconColor: const Color.fromARGB(255, 190, 39, 39),
                              label: 'CHECK OUT',
                              time: widget.checkOut,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
