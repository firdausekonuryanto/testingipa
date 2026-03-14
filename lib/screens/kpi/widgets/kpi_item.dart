import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/models/kpi.dart';
import 'package:internusa_group/utils/theme.dart';

class KpiItem extends StatelessWidget {
  final String no, indikator, bobot, target, totalTask, aktualisasi, skor, task;
  final List<DetailTask> detailTask;

  const KpiItem({
    required this.no,
    required this.indikator,
    required this.bobot,
    required this.target,
    required this.totalTask,
    required this.aktualisasi,
    required this.skor,
    required this.task,
    required this.detailTask,
  });

  Widget infoRow(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 2.h),
      child: Row(
        children: [
          Expanded(
              flex: 2,
              child: Text(
                "$label:",
                style: TextStyle(fontSize: AppDimens.fontBody),
              )),
          Expanded(
              flex: 3,
              child:
                  Text(value, style: TextStyle(fontSize: AppDimens.fontBody))),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(vertical: 6.h, horizontal: 8.w),
      child: ExpansionTile(
        title: Text("$no. $indikator",
            style: TextStyle(
                fontWeight: FontWeight.bold, fontSize: AppDimens.fontBody)),
        subtitle:
            Text("Skor: $skor", style: TextStyle(fontSize: AppDimens.fontBody)),
        children: [
          infoRow("Bobot (%)", bobot),
          infoRow("Target", target),
          infoRow("Total Task", totalTask),
          infoRow("Aktualisasi", aktualisasi),
          infoRow("Task", task),
          const Divider(),
          Padding(
            padding: EdgeInsets.all(8.0.r),
            child: Text("Detail Task:",
                style: TextStyle(
                    fontWeight: FontWeight.bold, fontSize: AppDimens.fontBody)),
          ),
          ...detailTask.map((d) => ListTile(
                leading: const Icon(Icons.task),
                title: Text(d.taskDetailName,
                    style: TextStyle(fontSize: AppDimens.fontBody)),
                subtitle: Text("${d.assignDate} - ${d.place}"),
                trailing: Text(
                  d.status,
                  style: TextStyle(
                    fontSize: AppDimens.fontBody,
                    color: d.status.toLowerCase() == "completed" ||
                            d.status.toLowerCase() == "complated"
                        ? AppColors.attendanceInArea
                        : AppColors.myOrange,
                  ),
                ),
              )),
        ],
      ),
    );
  }
}
