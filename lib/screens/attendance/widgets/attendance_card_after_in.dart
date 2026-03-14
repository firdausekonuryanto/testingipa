import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/models/attendance.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/services/attendance_service.dart';

class AttendanceCardAfterIn extends StatelessWidget {
  final Widget titleWidget;
  final Widget? titleLocation;
  final String stsIn;
  final int noteId;
  final Map<String, dynamic> checkDataAttendance;

  const AttendanceCardAfterIn({
    super.key,
    required this.titleWidget,
    this.titleLocation,
    required this.stsIn,
    required this.noteId,
    required this.checkDataAttendance,
  });

  Color _getStatusColor() {
    return stsIn == 'Terlambat'
        ? AppColors.myOrange
        : AppColors.attendanceInArea;
  }

  Widget _buildStatusBadge() {
    final bgColor = _getStatusColor();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12.r),
        border: Border.all(color: bgColor),
      ),
      child: Text(
        stsIn,
        style: TextStyle(
          color: bgColor,
          fontWeight: FontWeight.bold,
          fontSize: 12.sp,
        ),
      ),
    );
  }

  void _showAttendanceNotesDialog(BuildContext context) {
    final attendanceId = noteId;

    showDialog(
      context: context,
      builder: (context) {
        return FutureBuilder<List<AttendanceNote>>(
          future: AttendanceService()
              .getAttendanceNotes(attendanceId, attendanceType: "in"),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return AlertDialog(
                title: const Text("Loading..."),
                content: SizedBox(
                  height: 60.h,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              );
            } else if (snapshot.hasError) {
              return AlertDialog(
                title: const Text("Error"),
                content: Text(snapshot.error.toString()),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup"),
                  ),
                ],
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return AlertDialog(
                title: const Text("Catatan Kehadiran"),
                content: const Text("Tidak ada catatan"),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup"),
                  ),
                ],
              );
            } else {
              final notes = snapshot.data!;
              return AlertDialog(
                title: const Text("Catatan Kehadiran"),
                content: SizedBox(
                  width: double.maxFinite,
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: notes.length,
                    itemBuilder: (context, index) {
                      final note = notes[index];
                      return ListTile(
                        leading:
                            const Icon(Icons.note, color: AppColors.primary),
                        title: Text(note.notes),
                      );
                    },
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text("Tutup"),
                  ),
                ],
              );
            }
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 16.w),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.r),
      ),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            titleWidget,
            if (titleLocation != null) ...[
              SizedBox(height: 10.h),
              Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: checkDataAttendance['locationStsIn'] == 'offsite'
                        ? AppColors.checkOut
                        : AppColors.attendanceInArea,
                    size: 20.sp,
                  ),
                  SizedBox(width: 8.w),
                  if (titleLocation != null) Expanded(child: titleLocation!),
                ],
              ),
              SizedBox(height: 8.h),
              Row(
                children: [
                  Icon(Icons.info, color: AppColors.textSecondary, size: 20.sp),
                  SizedBox(width: 8.w),
                  _buildStatusBadge(),
                  SizedBox(width: 8.w),
                  GestureDetector(
                    onTap: () => _showAttendanceNotesDialog(context),
                    child: Text(
                      "Lihat Catatan",
                      style: TextStyle(
                        color: colorScheme.primary,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }
}
