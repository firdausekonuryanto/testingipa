import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/theme.dart';

class DateRangeButton extends StatelessWidget {
  final DateTime? startDate;
  final DateTime? endDate;
  final Function(DateTime, DateTime) onDateRangePicked;

  const DateRangeButton({
    Key? key,
    required this.startDate,
    required this.endDate,
    required this.onDateRangePicked,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return ValueListenableBuilder<List<Color>>(
      valueListenable: AppColors.gradientNotifier,
      builder: (context, colors, _) {
        return ElevatedButton(
          onPressed: () async {
            final picked = await showDateRangePicker(
              context: context,
              firstDate: DateTime(2020),
              lastDate: DateTime(2100),
              initialDateRange: (startDate != null && endDate != null)
                  ? DateTimeRange(start: startDate!, end: endDate!)
                  : null,
            );

            if (picked != null) {
              onDateRangePicked(picked.start, picked.end);
            }
          },
          style: ElevatedButton.styleFrom(
            side: BorderSide(
              color: AppColors.textSecondary,
              width: 1,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            padding: EdgeInsets.symmetric(
              vertical: 8.h,
              horizontal: 16.w,
            ),
            elevation: 0,
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.date_range,
                size: AppDimens.fontBody,
                color: colorScheme.primary,
              ),
              SizedBox(width: 6.w),
              Text(
                "Pilih Rentang Tanggal",
                style: TextStyle(
                  fontSize: AppDimens.fontBody,
                  color: colorScheme.onSurface,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
