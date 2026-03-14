import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../../utils/theme.dart';

class SearchInput extends StatelessWidget {
  final Function(String)? onChanged;
  final String hintText;

  const SearchInput({
    super.key,
    required this.onChanged,
    this.hintText = "Ketik Kriteria Pencarian...",
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: TextStyle(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textLight
              : AppColors.textSecondary,
          fontSize: AppDimens.fontBody,
        ),
        border: InputBorder.none,
        enabledBorder: InputBorder.none,
        focusedBorder: InputBorder.none,
        disabledBorder: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      style: TextStyle(fontSize: AppDimens.fontBody),
      onChanged: onChanged,
    );
  }
}
