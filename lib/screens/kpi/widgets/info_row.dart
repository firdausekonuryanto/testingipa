import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const InfoRow({required this.label, required this.value, required this.icon});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 2.0.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: Icon(icon,
                size: AppDimens.fontTitle,
                color: Theme.of(context).brightness == Brightness.dark
                    ? colorScheme.secondary
                    : Colors.black),
          ),
          SizedBox(
            width: 80.w,
            child: Text(
              label,
              style: TextStyle(fontSize: AppDimens.fontBody),
            ),
          ),
          Expanded(
              child: Text(value,
                  style: TextStyle(
                      fontSize: AppDimens.fontBody,
                      fontWeight: FontWeight.bold))),
        ],
      ),
    );
  }
}
