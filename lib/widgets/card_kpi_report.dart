import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/models/kpi.dart';
import 'package:internusa_group/screens/kpi/detail_kpi_screen.dart';
import 'package:internusa_group/utils/theme.dart';

class CardKpiReport extends StatelessWidget {
  const CardKpiReport({
    super.key,
    required this.listKpis,
    required this.index,
  });

  final listKpi listKpis;
  final int index;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Container(
      child: Card(
        elevation: 0,
        margin: EdgeInsets.symmetric(horizontal: 6.w, vertical: 16.h),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.r),
        ),
        child: ListTile(
          leading: Container(
            width: 40.w,
            height: 40.h,
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.2),
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Icon(
              Icons.check_circle,
              color: colorScheme.primary,
              size: AppDimens.fontTitle,
            ),
          ),
          title: Text(
            listKpis.employeeName,
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: AppDimens.fontBody),
          ),
          subtitle: Text(
              formatDate(
                listKpis.period,
                "MMMM yyyy",
              ),
              style: TextStyle(fontSize: AppDimens.fontCaption)),
          trailing: IconButton(
            icon: Icon(Icons.remove_red_eye, color: colorScheme.primary),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => DetailKpiScreen(
                    id: listKpis.id,
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
