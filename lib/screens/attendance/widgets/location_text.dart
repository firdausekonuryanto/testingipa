import 'package:flutter/material.dart';
import 'package:internusa_group/utils/theme.dart';

class LocationText extends StatelessWidget {
  final String param; // 'in' atau 'out'
  final String statusLocation; // misal 'diluar' atau 'didalam'
  final String infoLocation;
  final Brightness brightness;

  const LocationText({
    super.key,
    required this.param,
    required this.statusLocation,
    required this.infoLocation,
    required this.brightness,
  });

  @override
  Widget build(BuildContext context) {
    Color textColor;

    final bool isOutside = statusLocation == 'diluar';

    if (param == 'in') {
      textColor = isOutside
          ? (brightness == Brightness.dark
              ? AppColors.myLightRed
              : AppColors.checkOut)
          : (brightness == Brightness.dark
              ? AppColors.textLight
              : AppColors.textPrimary);
    } else {
      textColor = isOutside
          ? (brightness == Brightness.dark
              ? AppColors.myLightRed
              : AppColors.checkOut)
          : (brightness == Brightness.dark
              ? AppColors.textLight
              : AppColors.textPrimary);
    }

    return Text(
      infoLocation,
      style: TextStyle(fontSize: AppDimens.fontBody, color: textColor),
    );
  }
}
