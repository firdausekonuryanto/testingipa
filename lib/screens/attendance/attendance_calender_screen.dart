import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/providers/attendance_provider.dart';
import 'package:internusa_group/widgets/appbutton.dart';

class AttendanceCalenderScreen extends StatefulWidget {
  const AttendanceCalenderScreen({super.key});

  @override
  State<AttendanceCalenderScreen> createState() =>
      _AttendanceCalenderScreenState();
}

class _AttendanceCalenderScreenState extends State<AttendanceCalenderScreen> {
  late int daysInMonth;
  late int startingDayOfWeek;
  late int selectedDay;
  bool _isLocalLoading = false;
  DateTime _currentDate = DateTime.now();
  String stsLocOut = '';

  @override
  void initState() {
    super.initState();
    selectedDay = _currentDate.day;
    _generateCalendarData();

    Future.microtask(() {
      context.read<AttendanceProvider>().fetchMontlyAttendances();
    });
  }

  void _generateCalendarData() {
    daysInMonth = DateTime(_currentDate.year, _currentDate.month + 1, 0).day;
    startingDayOfWeek =
        DateTime(_currentDate.year, _currentDate.month, 1).weekday - 1;
  }

  void _showMonthYearPicker(BuildContext context) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        int tempMonth = _currentDate.month;
        int tempYear = _currentDate.year;

        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.all(16.r),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Pilih Bulan & Tahun",
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  DropdownButton<int>(
                    value: tempMonth,
                    isExpanded: true,
                    items: List.generate(12, (i) {
                      return DropdownMenuItem(
                        value: i + 1,
                        child: Text(
                          DateFormat.MMMM('id_ID').format(DateTime(0, i + 1)),
                        ),
                      );
                    }),
                    onChanged: (v) {
                      setModalState(() => tempMonth = v!);
                    },
                  ),
                  SizedBox(height: 12.h),
                  DropdownButton<int>(
                    value: tempYear,
                    isExpanded: true,
                    items: List.generate(10, (i) {
                      int year = DateTime.now().year - 5 + i;
                      return DropdownMenuItem(
                        value: year,
                        child: Text(year.toString()),
                      );
                    }),
                    onChanged: (v) {
                      setModalState(() => tempYear = v!);
                    },
                  ),
                  SizedBox(height: 20),
                  AppButton(
                    label: "Terapkan",
                    icon: Icons.save_rounded,
                    onPressed: () {
                      setState(() {
                        _currentDate = DateTime(tempYear, tempMonth, 1);
                        _generateCalendarData();
                        selectedDay = 1;
                      });
                      context
                          .read<AttendanceProvider>()
                          .fetchMontlyAttendancesByDate(_currentDate);
                      Navigator.pop(context);
                    },
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleDateSelection(int dayNum) async {
    if (selectedDay == dayNum) return;

    setState(() {
      selectedDay = dayNum;
      _isLocalLoading = true;
    });

    final targetDate = DateTime(_currentDate.year, _currentDate.month, dayNum);

    await context
        .read<AttendanceProvider>()
        .fetchMontlyAttendancesByDate(targetDate);

    if (!mounted) return;

    setState(() => _isLocalLoading = false);
  }

  void _showImagePreview(BuildContext context, String imageUrl) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.9),
      builder: (_) => GestureDetector(
        onTap: () => Navigator.pop(context),
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: InteractiveViewer(
              child: Image.network(imageUrl),
            ),
          ),
        ),
      ),
    );
  }

  void _changeMonth(int offset) {
    setState(() {
      _currentDate =
          DateTime(_currentDate.year, _currentDate.month + offset, 1);

      _generateCalendarData();

      selectedDay = 1;
    });

    context
        .read<AttendanceProvider>()
        .fetchMontlyAttendancesByDate(_currentDate);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final bool isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        title: Text(
          "Jadwal Kerja & Libur",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            size: 20.sp,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        backgroundColor: isDark ? Colors.transparent : Colors.white,
        elevation: 0.5,
        surfaceTintColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 12.h),
            _buildSelectedDateHeader(context),
            Center(
              child: GestureDetector(
                onHorizontalDragEnd: (details) {
                  if (details.primaryVelocity! > 0) {
                    _changeMonth(-1);
                  } else if (details.primaryVelocity! < 0) {
                    _changeMonth(1);
                  }
                },
                child: _buildCalendarGrid(colorScheme, isDark),
              ),
            ),
            Divider(
                height: 1.h,
                color: colorScheme.outlineVariant.withOpacity(0.5)),
            Consumer<AttendanceProvider>(
              builder: (context, provider, _) {
                if (_isLocalLoading) {
                  return SizedBox(
                    height: 250.h,
                    child: const Center(child: CircularProgressIndicator()),
                  );
                }
                final List<dynamic> shiftList =
                    provider.attendanceMontly?.shift ?? [];
                return Column(
                  children: [
                    if (shiftList.isNotEmpty) ...[
                      _buildShiftInfo(colorScheme, provider),
                      Divider(
                          height: 1.h,
                          color: colorScheme.outlineVariant.withOpacity(0.5)),
                      _buildAttendanceCount(provider, colorScheme),
                      Divider(
                          height: 1.h,
                          color: colorScheme.outlineVariant.withOpacity(0.5)),
                      _buildPunchDetail(provider, colorScheme),
                    ] else ...[
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 40.h),
                        child:
                            const Center(child: Text("Tidak ada data absensi")),
                      ),
                    ],
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSelectedDateHeader(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(right: 20.w, bottom: 8.h, left: 20.w, top: 7.h),
      child: Row(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(20),
            onTap: () => _showMonthYearPicker(context),
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                children: [
                  const Icon(Icons.calendar_month, size: 18),
                  SizedBox(width: 6.w),
                  Text(
                    "Pilih Bulan",
                    style: TextStyle(fontSize: AppDimens.fontBody),
                  ),
                ],
              ),
            ),
          ),
          const Spacer(),
          Text(
            "$selectedDay ${DateFormat('MMMM yyyy', 'id_ID').format(_currentDate).toUpperCase()}",
            style: TextStyle(
              fontSize: 14.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarGrid(ColorScheme colorScheme, bool isDark) {
    final daysLabels = ["Sen", "Sel", "Rab", "Kam", "Jum", "Sab", "Min"];

    return Consumer<AttendanceProvider>(
      builder: (context, provider, _) {
        final List<dynamic> allSchedule =
            provider.attendanceMontly?.allSchedule ?? [];
        final List<dynamic> presentDates =
            provider.attendanceMontly?.present ?? [];

        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: daysLabels
                    .map((label) => Expanded(
                          child: Center(
                            child: Text(label,
                                style: TextStyle(
                                    color: colorScheme.onSurfaceVariant,
                                    fontSize: AppDimens.fontBody,
                                    fontWeight: FontWeight.bold)),
                          ),
                        ))
                    .toList(),
              ),
              SizedBox(height: 12.h),
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  childAspectRatio: 0.8,
                  mainAxisSpacing: 8.h,
                ),
                itemCount: daysInMonth + startingDayOfWeek,
                itemBuilder: (context, index) {
                  if (index < startingDayOfWeek) return const SizedBox.shrink();
                  int dayNum = index - startingDayOfWeek + 1;
                  bool isSelected = dayNum == selectedDay;

                  String formattedDate = "${_currentDate.year}-"
                      "${_currentDate.month.toString().padLeft(2, '0')}-"
                      "${dayNum.toString().padLeft(2, '0')}";

                  bool hasSchedule = allSchedule.any(
                    (e) => e.date == formattedDate,
                  );

                  bool isPresent = presentDates.contains(formattedDate);

                  return GestureDetector(
                    onTap: () => _handleDateSelection(dayNum),
                    child: Column(
                      children: [
                        Container(
                          width: 32.w,
                          height: 32.w,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: isSelected
                                ? colorScheme.primary
                                : Colors.transparent,
                            shape: BoxShape.circle,
                            border: isSelected
                                ? null
                                : Border.all(
                                    color: isPresent
                                        ? Colors.orange.withOpacity(0.5)
                                        : Colors.transparent),
                          ),
                          child: Text(
                            "$dayNum",
                            style: TextStyle(
                              color: isSelected
                                  ? Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Colors.black
                                      : Colors.white
                                  : (hasSchedule
                                      ? (isDark ? Colors.white : Colors.black)
                                      : Colors.grey),
                              fontSize: 13.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        // SizedBox(height: 4.h),
                        Text(
                          hasSchedule
                              ? allSchedule
                                  .firstWhere((e) => e.date == formattedDate)
                                  .shiftName
                                  .substring(0, 1)
                              : '',
                          style: TextStyle(
                            fontSize: 10.sp,
                            color: hasSchedule
                                ? (Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Colors.white
                                    : Colors.black)
                                : Colors.grey,
                          ),
                        ),
                        Icon(Icons.circle,
                            size: 8.r,
                            color: hasSchedule
                                ? (isPresent ? Colors.orange : Colors.grey[300])
                                : Colors.transparent),
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShiftInfo(ColorScheme colorScheme, AttendanceProvider provider) {
    final List<dynamic> shiftList = provider.attendanceMontly?.shift ?? [];
    return Container(
      padding: EdgeInsets.all(16.r),
      width: double.infinity,
      color: colorScheme.surfaceContainerHighest.withOpacity(0.2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Group Kehadiran : ${provider.attendanceMontly?.group ?? '-'}",
              style: TextStyle(
                  fontWeight: FontWeight.bold, fontSize: AppDimens.fontBody)),
          SizedBox(height: 8.h),
          ...shiftList.map((s) => Padding(
                padding: EdgeInsets.only(bottom: 4.h),
                child: Row(
                  children: [
                    Icon(Icons.access_time_filled,
                        size: 14.sp, color: colorScheme.primary),
                    SizedBox(width: 8.w),
                    Text(s.toString(),
                        style: TextStyle(fontSize: AppDimens.fontBody)),
                  ],
                ),
              )),
        ],
      ),
    );
  }

  Widget _buildAttendanceCount(
      AttendanceProvider provider, ColorScheme colorScheme) {
    final data = provider.attendanceMontly;
    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Row(
        children: [
          Icon(Icons.history_toggle_off, color: colorScheme.primary),
          SizedBox(width: 12.w),
          Expanded(
            child: Text.rich(TextSpan(
              children: [
                const TextSpan(text: "Jumlah Kehadiran : "),
                TextSpan(
                    text: "${data?.countLog ?? 0}",
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: AppDimens.fontBody)),
                TextSpan(text: " (${data?.resultHours ?? '0h'})"),
              ],
            )),
          ),
        ],
      ),
    );
  }

  Widget _buildPunchDetail(
      AttendanceProvider provider, ColorScheme colorScheme) {
    final data = provider.attendanceMontly;

    if (data == null ||
        ((data.clockIn == null || data.clockIn!.isEmpty) &&
            (data.clockOut == null || data.clockOut!.isEmpty))) {
      return Padding(
        padding: EdgeInsets.symmetric(vertical: 20.h),
        child: const Center(child: Text("Tidak ada data absensi")),
      );
    }

    if (data.clockOut != null && data.clockOut!.isNotEmpty) {
      if (data.stsLocation.length > 1) {
        stsLocOut = data.stsLocation[1];
      } else {
        stsLocOut = data.stsLocation[0];
      }
    }

    return Padding(
      padding: EdgeInsets.all(16.r),
      child: Column(
        children: [
          if (data.clockIn != null && data.clockIn!.isNotEmpty)
            _buildPunchItem(
                "In",
                data.clockIn!,
                data.inTime ?? '08:00',
                data.stsLocation[0] ?? '-',
                data.lateInTime,
                data.inImage,
                colorScheme),
          if (data.clockOut != null && data.clockOut!.isNotEmpty) ...[
            SizedBox(height: 20.h),
            _buildPunchItem("Out", data.clockOut!, data.outTime ?? '17:00',
                stsLocOut ?? '-', data.lateOutTime, data.outImage, colorScheme),
          ]
        ],
      ),
    );
  }

  Widget _buildPunchItem(String label, String time, String schedule, String loc,
      String status, String? img, ColorScheme colorScheme) {
    bool isLate = status.toLowerCase().contains('kurang');

    final bool isDark = colorScheme.brightness == Brightness.dark;
    final Color primaryTextColor = isDark ? Colors.white : Colors.black;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 18.r,
          backgroundColor: colorScheme.surfaceContainerHighest,
          child: Text(label,
              style: TextStyle(
                fontSize: 10.sp,
                fontWeight: FontWeight.bold,
                color: primaryTextColor,
              )),
        ),
        SizedBox(width: 12.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    "Waktu Check ${label} ${time}",
                    style: TextStyle(
                      fontSize: AppDimens.fontBody,
                      fontWeight: FontWeight.bold,
                      color: primaryTextColor,
                    ),
                  ),
                  Text(
                    " Jadwal: $schedule",
                    style: TextStyle(
                        fontSize: AppDimens.fontCaption, color: Colors.grey),
                  ),
                ],
              ),
              SizedBox(height: 4.h),
              Row(
                children: [
                  Icon(Icons.location_on,
                      size: AppDimens.fontBody, color: Colors.grey),
                  SizedBox(width: 4.w),
                  Expanded(
                    child: Text(
                      loc,
                      style: TextStyle(
                          fontSize: AppDimens.fontBody, color: Colors.grey),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: isLate
                      ? AppColors.myLightRed.withOpacity(isDark ? 0.8 : 1.0)
                      : AppColors.myLightGreen.withOpacity(isDark ? 0.8 : 1.0),
                  borderRadius: BorderRadius.circular(12.r),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      isLate ? Icons.cancel : Icons.check_circle,
                      size: AppDimens.fontBody,
                      color: isLate ? Colors.red[900] : Colors.green[900],
                    ),
                    SizedBox(width: 4.w),
                    Text(
                      status,
                      style: TextStyle(
                        fontSize: AppDimens.fontCaption,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ],
                ),
              ),
              if (img != null && img.isNotEmpty) ...[
                SizedBox(height: 8.h),
                GestureDetector(
                  onTap: () => _showImagePreview(context, img),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8.r),
                    child: Image.network(
                      img,
                      width: 80.w,
                      height: 80.w,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                          Icons.broken_image,
                          size: 40.sp,
                          color: Colors.grey),
                    ),
                  ),
                ),
              ]
            ],
          ),
        ),
      ],
    );
  }
}
