import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';

class BtnGlobal extends StatefulWidget {
  final VoidCallback? onClick;
  final String title;
  final Icon? icon;
  const BtnGlobal({
    super.key,
    required this.onClick,
    required this.title,
    this.icon,
  });

  @override
  State<BtnGlobal> createState() => _BtnGlobalState();
}

class _BtnGlobalState extends State<BtnGlobal> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 35.h,
      child: TextButton(
        onPressed: widget.onClick,
        style: TextButton.styleFrom(
          backgroundColor: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textPrimary
              : AppColors.textSecondary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.borderRadius),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.icon != null) ...[
              widget.icon!,
              SizedBox(width: 8.w),
            ],
            // const Icon(
            //   Icons.login,
            //   color: Colors.white,
            //   size: 20,
            // ),
            const SizedBox(width: 8),
            Text(
              widget.title,
              style: Theme.of(context)
                  .textTheme
                  .titleMedium
                  ?.copyWith(color: AppColors.textLight),
            ),
          ],
        ),
      ),
    );
  }
}
