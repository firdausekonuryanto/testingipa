import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TableRowLabel {
  static TableRow build(String label, String? value) {
    return TableRow(
      children: [
        Padding(
          padding: EdgeInsets.all(8.r),
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Padding(
          padding: EdgeInsets.all(8.r),
          child: Text(value ?? "-"),
        ),
      ],
    );
  }
}
