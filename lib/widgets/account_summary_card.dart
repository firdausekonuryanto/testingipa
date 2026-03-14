import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/utils/theme.dart';

class AccountSummaryCard extends StatelessWidget {
  final String name;
  final String company;
  final String profileImageUrl;
  final double currentBalance;
  final double allowance;
  final double deduction;

  const AccountSummaryCard({
    super.key,
    required this.name,
    required this.company,
    required this.profileImageUrl,
    required this.currentBalance,
    required this.allowance,
    required this.deduction,
  });

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Color>>(
      valueListenable: AppColors.gradientNotifier,
      builder: (context, colors, _) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: Theme.of(context).brightness == Brightness.dark
                ? LinearGradient(
                    colors: [
                      AppColors.textSecondary.withOpacity(0.1),
                      AppColors.textPrimary
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 30.h),
              Text(
                "Account Summary",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimens.fontBody,
                ),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundImage: NetworkImage(profileImageUrl),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Icon(Icons.person,
                                color: Colors.white, size: AppDimens.fontBody),
                            const SizedBox(width: 4),
                            Text(
                              name,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: AppDimens.fontBody,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(Icons.business,
                                color: Colors.white70,
                                size: AppDimens.fontBody),
                            const SizedBox(width: 4),
                            Text(
                              company,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: AppDimens.fontCaption,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Center(
                child: Text(
                  "TOTAL AKUMULASI PENDAPATAN",
                  style: TextStyle(
                      color: AppColors.myLightYellow,
                      fontSize: AppDimens.fontCaption),
                ),
              ),
              Center(
                child: Text(
                  "\ ${formatToRupiah(currentBalance)}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: AppDimens.fontXL,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Column(
                    children: [
                      Text(
                        "TUNJANGAN",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppDimens.fontCaption),
                      ),
                      Text(
                        "\ ${formatToRupiah(allowance)}",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightGreen
                              : AppColors.attendanceInArea,
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimens.fontTitle,
                        ),
                      )
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "POTONGAN",
                        style: TextStyle(
                            color: Colors.white70,
                            fontSize: AppDimens.fontCaption),
                      ),
                      Text(
                        "\ ${formatToRupiah(deduction)}",
                        style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightRed
                              : AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: AppDimens.fontTitle,
                        ),
                      )
                    ],
                  ),
                ],
              )
            ],
          ),
        );
      },
    );
  }
}
