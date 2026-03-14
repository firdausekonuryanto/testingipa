import 'package:flutter/material.dart';
import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class AttendanceDetailScreen extends StatelessWidget {
  final dynamic item;
  final int minutesLate;
  final int minutesEarly;

  const AttendanceDetailScreen({
    super.key,
    required this.item,
    required this.minutesLate,
    required this.minutesEarly,
  });

  Widget _buildCircle(double size) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.textLight.withOpacity(0.1),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, Widget value,
      {Color iconColor = AppColors.textLight}) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 4.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20.sp, color: iconColor),
          SizedBox(width: 8.w),
          SizedBox(
            width: 90.w,
            child: Text(
              "$label ",
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textLight,
              ),
            ),
          ),
          if (value is Text) Expanded(child: value) else value,
        ],
      ),
    );
  }

  Widget _buildCard({
    required BuildContext context,
    required String title,
    required String jam,
    required String catatan,
    required String lokasi,
    required Widget status,
    required String lokasiStatus,
    required String? imageUrl,
  }) {
    return Card(
      color: AppColors.background.withValues(alpha: 0.15),
      elevation: 6,
      margin: EdgeInsets.only(bottom: 20.r),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textLight,
                )),
            Divider(color: AppColors.textLight.withValues(alpha: 0.5)),
            _buildInfoRow(
                Icons.access_time,
                "Jam",
                Text(jam.isNotEmpty ? jam : "-",
                    style: const TextStyle(color: AppColors.textLight))),
            _buildInfoRow(Icons.verified, "Status", status),
            _buildInfoRow(Icons.location_on, "Lokasi Sts",
                _buildLokasiStatus(lokasiStatus),
                iconColor: Colors.redAccent),
            _buildInfoRow(
                Icons.note_alt,
                "Catatan",
                Text(catatan.isNotEmpty ? catatan : "-",
                    style: const TextStyle(color: AppColors.textLight)),
                iconColor: Colors.orange),
            _buildInfoRow(
                Icons.map,
                "Lokasi",
                Text(lokasi.isNotEmpty ? lokasi : "-",
                    style: const TextStyle(color: AppColors.textLight)),
                iconColor: Colors.green),
            SizedBox(height: 10.h),
            if (imageUrl != null)
              GestureDetector(
                onTap: () {
                  showDialog(
                    context: context,
                    builder: (_) => Dialog(
                      backgroundColor: AppColors.textPrimary,
                      insetPadding: EdgeInsets.all(10.r),
                      child: InteractiveViewer(
                        panEnabled: true,
                        minScale: 0.5,
                        maxScale: 4,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12.r),
                          child: Image.network(
                            imageUrl,
                            fit: BoxFit.contain,
                            errorBuilder: (context, error, stackTrace) =>
                                const Center(
                                    child: Text("No Image",
                                        style: TextStyle(
                                            color: AppColors.textLight))),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.r),
                  child: Image.network(
                    imageUrl,
                    height: 160.h,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Text("No Image"),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String status) {
    final normalized = status.toLowerCase();
    Color bgColor =
        (normalized != "normal") ? AppColors.myOrange : AppColors.checkIn;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 6.w, vertical: 2.h),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: Text(
        status.isNotEmpty ? status : "-",
        style: TextStyle(
          color: AppColors.textLight,
          fontSize: 12.sp,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildLokasiStatus(String status) {
    final isOffsite = status.toLowerCase() == "offsite";
    return Text(
      status.isNotEmpty ? status : "-",
      style: TextStyle(
        color: isOffsite ? AppColors.error : AppColors.textLight,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final noteIn = item.notes
        .where((n) => n.attendanceType == 'in')
        .map((n) => n.notes)
        .join(", ");
    final noteOut = item.notes
        .where((n) => n.attendanceType == 'out')
        .map((n) => n.notes)
        .join(", ");
    final locIn = item.locations
        .where((n) => n.attendanceType == 'in')
        .map((n) => n.place)
        .join(", ");
    final locOut = item.locations
        .where((n) => n.attendanceType == 'out')
        .map((n) => n.place)
        .join(", ");

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Detail Kehadiran",
          style: TextStyle(
            color: AppColors.textLight,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: AppColors.textPrimary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Color.fromARGB(255, 19, 29, 36),
                    Color.fromARGB(255, 2, 31, 61),
                  ],
                ),
              ),
              child: Stack(
                children: [
                  Positioned(top: -50, left: -50, child: _buildCircle(200)),
                  Positioned(top: 20, right: -20, child: _buildCircle(150)),
                  Positioned(bottom: 50, left: 50, child: _buildCircle(250)),
                ],
              ),
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight,
                  ),
                  child: IntrinsicHeight(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.clockIn != null) ...[
                          _buildCard(
                            context: context,
                            title: "Clock In ",
                            jam: item.clockIn ?? "-",
                            status: _buildStatusBadge(minutesLate > 0
                                ? "Telat : ${minutesLate.toString()} Menit"
                                : 'Normal'),
                            lokasiStatus: item.locations.isNotEmpty
                                ? item.locations[0].status
                                : "-",
                            catatan: noteIn,
                            lokasi: locIn,
                            imageUrl: item.clockInImage != null
                                ? "${item.clockInImage}"
                                : null,
                          ),
                        ],
                        if (item.clockOut != null) ...[
                          _buildCard(
                            context: context,
                            title: "Clock Out",
                            jam: item.clockOut ?? "-",
                            status: _buildStatusBadge(minutesEarly < 0
                                ? "Kurang : ${minutesEarly.abs().toString()} Menit"
                                : 'Normal'),
                            lokasiStatus: item.locations.length > 1
                                ? item.locations[1].status
                                : item.locations[0].status,
                            catatan: noteOut,
                            lokasi: locOut,
                            imageUrl: item.clockOutImage != null
                                ? "${item.clockOutImage}"
                                : null,
                          ),
                        ],
                        const Spacer(),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
