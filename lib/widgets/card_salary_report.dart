import 'package:flutter/material.dart';
import 'package:internusa_group/models/salary.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';

class CardSalaryReport extends StatelessWidget {
  const CardSalaryReport({
    super.key,
    required this.salary,
    required this.index,
    required this.onTapDetail,
  });

  final Salary salary;
  final int index;
  final void Function(Salary) onTapDetail;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final formattedDate = DateFormat("MMMM yyyy", "id_ID")
        .format(DateTime.parse(salary.salaryMonth));

    final formattedTotal = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    ).format(double.parse(salary.totalSalary));

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.textLight.withOpacity(0.1)
            : AppColors.textLight,
        borderRadius: BorderRadius.circular(16.r),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 10,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Card(
        color: Colors.transparent,
        elevation: 0,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        child: Padding(
          padding: EdgeInsets.all(16.r),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => onTapDetail(salary),
                child: Container(
                  height: 40.r,
                  width: 40.r,
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? colorScheme.primary
                        : AppColors.textPrimary.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.payments_rounded,
                    color: AppColors.textPrimary,
                    size: AppDimens.fontXL,
                  ),
                ),
              ),
              SizedBox(width: 16.w),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      formattedDate,
                      style: GoogleFonts.poppins(
                        fontSize: AppDimens.fontBody,
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                      ),
                    ),
                    SizedBox(height: 6.h),
                    RichText(
                      text: TextSpan(
                        style: TextStyle(
                          fontSize: AppDimens.fontBody,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightGreen
                              : AppColors.textPrimary,
                        ),
                        children: [
                          const TextSpan(text: 'Total Gaji: '),
                          TextSpan(
                            text: formattedTotal,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? AppColors.myLightGreen
                                  : AppColors.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                '#${index + 1}',
                style: TextStyle(
                  fontSize: 18.sp,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.myLightYellow
                      : AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
