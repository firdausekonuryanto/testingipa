import 'dart:io';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:internusa_group/utils/location_consent_helper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:location/location.dart';
import 'package:provider/provider.dart';
import 'package:geocoding/geocoding.dart' as geo;
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/screens/attendance/custom_camera_screen.dart';

import 'package:internusa_group/providers/attendance_provider.dart';
import 'package:internusa_group/providers/work_schedule_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/services/attendance_service.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/widgets/appbutton.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/screens/attendance/widgets/main_header.dart';
import 'package:internusa_group/screens/attendance/widgets/location_text.dart';
import 'package:internusa_group/screens/attendance/widgets/attendance_card.dart';
import 'package:internusa_group/screens/attendance/widgets/attendance_card_after_in.dart';
import 'package:internusa_group/screens/attendance/widgets/attendance_card_after_out.dart';

class AttendanceScreen extends StatefulWidget {
  const AttendanceScreen({super.key});

  @override
  State<AttendanceScreen> createState() => _AttendanceScreenState();
}

class _AttendanceScreenState extends State<AttendanceScreen>
    with TickerProviderStateMixin {
  final Location _location = Location();

  List<Map<String, String>> _workSchedule = [];
  List<Map<String, dynamic>> shift = [];

  bool _isProcessing = false;
  bool _isProcessingIn = false;
  bool _isProcessingOut = false;
  bool _isLoading = true;
  bool _isLoadingGps = true;
  bool _isCheckedIn = false;
  bool _isCheckedOut = false;
  bool _isWsEmpty = false;

  String? stsClockIn;
  String? stsClockOut;
  String infoMyLocationIn = '';
  String infoMyLocationOut = '';
  String stsLocationGlobal = '';
  String stsLocationIn = '';
  String stsLocationOut = '';
  String initialInfoIn = '';
  String initialInfoOut = '';
  String mockPlace = '';
  String selectedOffice = '';
  String selectedLat = '';
  String selectedLong = '';
  String selectedRadius = '';

  Map<String, dynamic>? _checkInData;
  Map<String, dynamic>? _checkOutData;
  Map<String, dynamic> checkDataAttendance = {};

  late AnimationController _inController;
  late AnimationController _outController;
  late Animation<double> _inAnimation;
  late Animation<double> _outAnimation;

  double mockLatitude = 0;
  double mockLongitude = 0;

  int? selectedIdOffice = null;
  int nowMinutes = 0;
  int maxCheckInMinutes = 0;
  dynamic clockInRaw;

  @override
  void initState() {
    super.initState();
    _initControllers();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeScreen();
    });
  }

  void _initControllers() {
    _inController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _outController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  Future<void> _initializeScreen() async {
    if (!mounted) return;

    // ================= AUTH =================
    final auth = context.read<AuthProvider>();
    await auth.getCurrentUser();
    if (!mounted) return;

    final user = auth.currentUser;
    if (user == null) return;

    // ================= SHIFT =================
    final ws = context.read<WorkScheduleProvider>();
    await ws.fetchTodayShift(user.id);
    if (!mounted) return;

    shift = ws.todayShift;

    // ================= VALIDATE OFFICE =================
    if (!_hasOffice()) {
      _showOfficeError();
      return;
    }

    // ================= LOCATION =================
    await _initOfficeLocation();
    if (!mounted) return;

    // ================= CONSENT =================
    final accepted = await _handleLocationConsent();
    if (!accepted || !mounted) return;

    // ================= LOAD DATA =================
    await _getMyLocationGps();
    if (!mounted) return;

    _initAnimations();
    _fetchInitialData();

    _stopLoadingDelayed();
  }

  Future<void> _initOfficeLocation() async {
    final location = await _getCurrentLocation();
    if (location == null) return;

    final offices = shift.isNotEmpty ? shift[0]['office'] : [];

    // double latx = -8.306584445113012; //for testing radius - pasar rogojampi
    // double longx = 114.29493173674066; //for testing radius - pasarrogojampi

    // double latx = -8.40191359937756; //for testing radius - pasar srono
    // double longx = 114.26409008248991; //for testing radius - pasar srono

    // double latx = -9.40191359937756; //for testing radius - diluar area
    // double longx = 115.26409008248991; //for testing radius - diluar area

    final latx = location.latitude ?? 0.0;
    final longx = location.longitude ?? 0.0;

    for (final office in offices) {
      final lat = double.tryParse('${office['lat']}') ?? 0.0;
      final lon = double.tryParse('${office['long']}') ?? 0.0;
      final radius = int.tryParse('${office['radius']}') ?? 0;

      final distance = calculateDistance(lat, lon, latx, longx);

      if (distance <= radius) {
        if (!mounted) return;

        setState(() {
          selectedOffice = office['name'];
          selectedIdOffice = office['id'];
          selectedLat = office['lat'].toString();
          selectedLong = office['long'].toString();
          selectedRadius = office['radius'].toString();
          stsLocationIn = 'inside';
          stsLocationOut = 'inside';
        });
        break;
      }
    }
  }

  bool _hasOffice() {
    return shift.isNotEmpty &&
        shift[0]['shifts'] != null &&
        shift[0]['office'] != null &&
        shift[0]['office'][0]['name'] != null;
  }

  void _showOfficeError() {
    if (!mounted) return;

    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          backgroundColor: AppColors.myLightRed,
          duration: const Duration(seconds: 10),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.textPrimary),
              SizedBox(width: 10.w),
              const Expanded(
                child: Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: 'Upps.. Error ',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      TextSpan(
                        text:
                            'Office / Jadwal belum diset, silakan hubungi admin',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      );
  }

  Future<bool> _handleLocationConsent() async {
    final accepted = await LocationConsentHelper.hasAccepted();
    if (!accepted) {
      final consent = await showLocationDisclosure(context);
      if (!consent) {
        if (mounted) {
          Navigator.pushReplacementNamed(context, RoutesNames.home);
        }
        return false;
      }
      await LocationConsentHelper.accept();
    }
    return true;
  }

  void _stopLoadingDelayed() {
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() => _isLoading = false);
    });
  }

  @override
  void dispose() {
    _inController.dispose();
    _outController.dispose();

    _isProcessing = false;
    _isProcessingIn = false;
    _isProcessingOut = false;

    _isLoading = true;
    _isLoadingGps = true;
    _isCheckedIn = false;
    _isCheckedOut = false;
    _isWsEmpty = false;

    stsClockIn = null;
    stsClockOut = null;

    infoMyLocationIn = '';
    infoMyLocationOut = '';

    stsLocationGlobal = '';
    stsLocationIn = '';
    stsLocationOut = '';

    initialInfoIn = '';
    initialInfoOut = '';

    _checkInData = null;
    _checkOutData = null;

    checkDataAttendance = {};

    shift = [];
    _workSchedule = [];

    mockLatitude = 0;
    mockLongitude = 0;

    mockPlace = '';

    super.dispose();
  }

  void _resetState() {
    setState(() {
      _workSchedule = [];
      _isProcessing = false;
      _isProcessingIn = false;
      _isProcessingOut = false;
      _isLoading = true;
      _isLoadingGps = true;
      _isCheckedIn = false;
      _isCheckedOut = false;
      _isWsEmpty = false;

      stsClockIn = null;
      stsClockOut = null;
      infoMyLocationIn = '';
      infoMyLocationOut = '';
      stsLocationGlobal = '';
      stsLocationIn = '';
      stsLocationOut = '';
      initialInfoIn = '';
      initialInfoOut = '';

      _checkInData = null;
      _checkOutData = null;
      checkDataAttendance = {};
      shift = [];

      mockLatitude = 0;
      mockLongitude = 0;
      mockPlace = '';
    });
  }

  Future<void> _getMyLocationGps() async {
    final attendanceProvider = context.read<AttendanceProvider>();
    await attendanceProvider.fetchWorkSchedules();

    final service = AttendanceService();
    checkDataAttendance = await service.getTodayAttendances();

    if (checkDataAttendance.isNotEmpty &&
            checkDataAttendance['clockIn'] == null ||
        checkDataAttendance['clockOut'] == null) {
      final location = await _getCurrentLocation();
      if (location == null) return;

      final addr = await getAddressFromLatLng(
        location.latitude!,
        location.longitude!,
        // mockLatitude!,
        // mockLongitude!,
      );

      String placeText = addr;
      final placemarks = await geo.placemarkFromCoordinates(
        location.latitude!,
        location.longitude!,
        // mockLatitude!,
        // mockLongitude!,
      );

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        placeText = "${place.street}, ${place.subLocality}, ${place.locality}, "
            "${place.administrativeArea}, ${place.country}";
      }

      setState(() {
        mockLatitude = location.latitude ?? 0.0;
        mockLongitude = location.longitude ?? 0.0;
        mockPlace = placeText;
        _isLoadingGps = false;
      });
    }

    final tempSchedule = attendanceProvider.workSchedule;

    setState(() {
      _workSchedule = tempSchedule;
    });

    if (tempSchedule.isEmpty ||
        (tempSchedule.isNotEmpty && tempSchedule[0]['status'] == 'offday')) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppColors.primary,
            duration: const Duration(seconds: 8),
            content: Row(
              children: [
                const Icon(
                  Icons.info_outline,
                  color: AppColors.background,
                ),
                SizedBox(width: 8.w),
                Expanded(
                  child: RichText(
                    text: const TextSpan(
                      style: TextStyle(color: AppColors.background),
                      children: [
                        TextSpan(
                          text: 'Info: ',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(
                          text: 'Jadwal tidak ditemukan untuk hari ini',
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      });

      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;
      if (user == null) return;

      final ws = context.read<WorkScheduleProvider>();
      await ws.fetchTodayShift(user.id);
      shift = ws.todayShift;

      if (shift.isNotEmpty && shift[0]['shifts'] != null) {
        setState(() {
          _workSchedule = [
            {
              'schedule_date': '2025-09-22',
              'employee_name': shift[0]['employees'][0]['name'],
              'shift_name': '?',
              'shift_start': '',
              'shift_end': '',
              'shift_template_id': shift[0]['template_id'].toString(),
              'shift_template_name': shift[0]['template_name'].toString(),
              'office_name': selectedOffice,
              'latitude': selectedLat,
              'longitude': selectedLong,
              'radius': selectedRadius,
            }
          ];
          _isWsEmpty = true;
        });
      }
    }
  }

  Future<bool> showLocationDisclosure(BuildContext context) async {
    return await showDialog<bool>(
          context: context,
          barrierDismissible: false,
          builder: (context) {
            return AlertDialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 24,
              ),
              title: const Text('Akses Lokasi untuk Absensi'),
              content: const SingleChildScrollView(
                child: Text(
                  'Aplikasi ini memerlukan akses lokasi (GPS) untuk:\n\n'
                  '• Menentukan posisi karyawan saat melakukan check-in dan check-out\n'
                  '• Menetapkan status absensi apakah berada di dalam atau di luar radius kantor\n\n'
                  'Absensi tetap dapat dilakukan meskipun berada di luar radius kantor.\n\n'
                  'Data lokasi hanya digunakan saat proses check-in dan check-out '
                  'dan tidak dilacak secara terus-menerus atau dibagikan ke pihak ketiga.',
                ),
              ),
              actions: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, false),
                      icon: const Icon(Icons.close),
                      label: const Text('Batal'),
                    ),
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () => Navigator.pop(context, true),
                      icon: const Icon(Icons.arrow_forward),
                      label: const Text('Lanjutkan'),
                    ),
                  ],
                )
              ],
            );
          },
        ) ??
        false;
  }

  int toMinutes(String time) {
    final parts = time.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return ValueListenableBuilder<List<Color>>(
          valueListenable: AppColors.gradientNotifier,
          builder: (context, colors, _) {
            return Scaffold(
              body: Container(
                width: double.infinity,
                height: double.infinity,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: Theme.of(context).brightness == Brightness.dark
                        ? [AppColors.textPrimary, AppColors.textPrimary]
                        : colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(
                        valueColor:
                            AlwaysStoppedAnimation<Color>(AppColors.background),
                      ),
                      SizedBox(height: 20.h),
                      Text(
                        _isLoadingGps == true
                            ? "Sedang memuat Data.."
                            : "Sedang memuat Data & Lokasi GPS...",
                        style: TextStyle(
                            color: AppColors.background,
                            fontSize: AppDimens.fontBody),
                      ),
                    ],
                  ),
                ),
              ),
            );
          });
    }
    if (_getScheduleValue('shift_template_name') == '-') {
      Future.delayed(Duration.zero, () {
        Navigator.pushNamedAndRemoveUntil(
          context,
          RoutesNames.home,
          (route) => false,
        );
      });
      return const SizedBox.shrink();
    }

    final shiftStartStr = formatTime2(_getScheduleValue('shift_start'));

    if (shiftStartStr == '-' || !shiftStartStr.contains(':')) {
      // return const Center(
      //   child: Text('Shift belum tersedia'),
      // );
      nowMinutes = 0;
      maxCheckInMinutes = 1;
      clockInRaw = checkDataAttendance['clockIn'] ?? null;
    } else {
      final parts = shiftStartStr.split(':');
      final hour = int.parse(parts[0]);
      final minute = int.parse(parts[1]);

      final shiftStart = DateTime(2000, 1, 1, hour, minute);
      final maxCheckIn = shiftStart.add(const Duration(hours: 4));

      final maxCheckInStr =
          '${maxCheckIn.hour.toString().padLeft(2, '0')}:${maxCheckIn.minute.toString().padLeft(2, '0')}';
      final now = DateTime.now();

      final nowStr =
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';

      nowMinutes = toMinutes(nowStr);
      maxCheckInMinutes = toMinutes(maxCheckInStr);

      clockInRaw = checkDataAttendance['clockIn'];
      if (nowMinutes > maxCheckInMinutes) {
        setState(() {
          _isCheckedIn = true;
          _inController.stop();
          _outController.repeat(reverse: true);
        });
      }
    }
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return WillPopScope(
              onWillPop: () async {
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   RoutesNames.home,
                //   (route) => false,
                // ); // back to home first
                SystemNavigator.pop();
                return false;
              },
              child: Scaffold(
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      // ---------------- CLOCK IN ----------------
                      // if (checkDataAttendance['clockIn'] == null &&
                      //     90 < maxCheckInMinutes) ...[
                      if (checkDataAttendance['clockIn'] == null &&
                          nowMinutes < maxCheckInMinutes) ...[
                        SizedBox(height: 20.h),
                        AttendanceCard(
                          titleWidget: (formatTime2(
                                          _getScheduleValue('shift_start')) !=
                                      '-' &&
                                  formatTime2(
                                          _getScheduleValue('shift_start')) !=
                                      'null')
                              ? RichText(
                                  text: TextSpan(
                                    style: TextStyle(
                                      fontSize: 16.sp,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textLight
                                          : AppColors.textPrimary,
                                    ),
                                    children: [
                                      const TextSpan(
                                        text: "Waktu Masuk : ",
                                        style: TextStyle(
                                            fontWeight: FontWeight.normal),
                                      ),
                                      TextSpan(
                                        text: formatTime2(
                                            _getScheduleValue('shift_start')),
                                        style: const TextStyle(
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  ),
                                )
                              : null,
                          titleMyPosition: LocationText(
                            param: 'in',
                            statusLocation: stsLocationIn,
                            infoLocation: infoMyLocationIn,
                            brightness: Theme.of(context).brightness,
                          ),
                          buttonLabel: stsClockIn ?? '-',
                          buttonColor: stsClockIn == 'Terlambat'
                              ? AppColors.myOrange
                              : AppColors.checkIn,
                          animation: _inAnimation,
                          data: _checkInData,
                          onTap: _isProcessingIn || _isCheckedIn
                              ? null
                              : () => _handleCheck(isCheckIn: true),
                          inOut: "in",
                          stsLocationIn: stsLocationIn,
                          stsLocationOut: stsLocationOut,
                          isProcessing: _isProcessing,
                        ),
                        SizedBox(height: 20.h),
                        if (formatTime2(_getScheduleValue('shift_end')) !=
                                '-' &&
                            formatTime2(_getScheduleValue('shift_end')) !=
                                'null') ...[
                          Card(
                            margin: EdgeInsets.symmetric(horizontal: 16.w),
                            elevation: 4,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10.r),
                            ),
                            child: Padding(
                              padding: EdgeInsets.all(16.r),
                              child: Row(
                                children: [
                                  Icon(Icons.access_time,
                                      color: Theme.of(context).brightness ==
                                              Brightness.dark
                                          ? AppColors.textLight
                                          : AppColors.textSecondary,
                                      size: 20.sp),
                                  SizedBox(width: 12.w),
                                  RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Waktu Pulang : ",
                                          style: TextStyle(
                                              fontSize: AppDimens.fontBody,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        TextSpan(
                                          text: formatTime2(
                                              _getScheduleValue('shift_end')),
                                          style: const TextStyle(
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        ]
                      ] else ...[
                        // SUDAH CHECK IN -> tampil Punch Time
                        SizedBox(height: 20.h),
                        AttendanceCardAfterIn(
                          titleWidget: RichText(
                            text: TextSpan(
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textLight
                                    : AppColors.textPrimary,
                              ),
                              children: [
                                TextSpan(
                                  text: clockInRaw == null
                                      ? "Absent / Clock In: ❌ Terlewat "
                                      : "Waktu Absen ${DateFormat.Hm().format(
                                          clockInRaw is DateTime
                                              ? clockInRaw
                                              : DateTime.parse(clockInRaw),
                                        )}",
                                  style: TextStyle(
                                    fontSize: AppDimens.fontTitle,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                if (formatTime2(
                                        _getScheduleValue('shift_start')) !=
                                    'null') ...[
                                  TextSpan(
                                    text:
                                        " (Waktu Masuk  ${formatTime2(_getScheduleValue('shift_start'))})",
                                    style: TextStyle(
                                      fontSize: AppDimens.fontBody,
                                    ),
                                  ),
                                ]
                              ],
                            ),
                          ),

                          titleLocation: clockInRaw != null
                              ? Text(
                                  infoMyLocationIn,
                                  style: TextStyle(
                                    color:
                                        checkDataAttendance['locationStsIn'] ==
                                                'offsite'
                                            ? Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? AppColors.myLightRed
                                                : AppColors.checkOut
                                            : Theme.of(context).brightness ==
                                                    Brightness.dark
                                                ? AppColors.textLight
                                                : AppColors.textPrimary,
                                  ),
                                )
                              : null,
                          stsIn: checkDataAttendance['clockInStatus'] == 'late'
                              ? 'Terlambat'
                              : 'Normal',
                          // noteId: checkDataAttendance['id'],
                          noteId: int.tryParse(
                                  checkDataAttendance['id']?.toString() ??
                                      '') ??
                              0,

                          checkDataAttendance: checkDataAttendance,
                        ),

                        // ---------------- CLOCK OUT ----------------
                        if (checkDataAttendance['clockOut'] == null) ...[
                          SizedBox(height: 20.h),
                          AttendanceCard(
                            titleWidget: formatTime2(
                                            _getScheduleValue('shift_end')) !=
                                        '-' &&
                                    formatTime2(
                                            _getScheduleValue('shift_end')) !=
                                        'null'
                                ? RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        fontSize: 16.sp,
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.textLight
                                            : AppColors.textPrimary,
                                      ),
                                      children: [
                                        TextSpan(
                                          text: "Waktu Pulang : ",
                                          style: TextStyle(
                                              fontSize: AppDimens.fontBody,
                                              fontWeight: FontWeight.normal),
                                        ),
                                        TextSpan(
                                          text: formatTime2(
                                              _getScheduleValue('shift_end')),
                                          style: TextStyle(
                                              fontSize: AppDimens.fontBody,
                                              fontWeight: FontWeight.bold),
                                        ),
                                      ],
                                    ),
                                  )
                                : null,
                            titleMyPosition: LocationText(
                              param: 'out',
                              statusLocation: stsLocationOut,
                              infoLocation: infoMyLocationOut,
                              brightness: Theme.of(context).brightness,
                            ),
                            buttonLabel: stsClockOut ?? '-',
                            buttonColor: stsClockOut == 'Lebih Awal'
                                ? AppColors.myOrange
                                : AppColors.checkOut,
                            animation: _outAnimation,
                            data: _checkOutData,
                            onTap: _isProcessingOut || !_isCheckedIn
                                ? () => _handleCheck(isCheckIn: false)
                                : () => _handleCheck(isCheckIn: false),
                            inOut: "out",
                            stsLocationIn: stsLocationIn,
                            stsLocationOut: stsLocationOut,
                            isProcessing: _isProcessing,
                          ),
                        ] else ...[
                          // SUDAH CHECK OUT -> tampil Punch Time
                          SizedBox(height: 20.h),
                          AttendanceCardAfterOut(
                            titleWidget: RichText(
                              text: TextSpan(
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textLight
                                      : AppColors.textPrimary,
                                ),
                                children: [
                                  TextSpan(
                                    text: "Waktu Absen ${DateFormat.Hm().format(
                                      DateTime.parse(
                                          checkDataAttendance['clockOut']
                                              .toString()),
                                    )}",
                                    style: TextStyle(
                                        fontSize: AppDimens.fontTitle,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text:
                                        " (Waktu Pulang ${formatTime2(_getScheduleValue('shift_end'))})",
                                    style:
                                        TextStyle(fontSize: AppDimens.fontBody),
                                  ),
                                ],
                              ),
                            ),
                            titleLocation: Text(
                              infoMyLocationOut,
                              style: TextStyle(
                                color: checkDataAttendance['locationStsOut'] ==
                                        'offsite'
                                    ? Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.myLightRed
                                        : AppColors.checkOut
                                    : Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.textLight
                                        : AppColors.textPrimary,
                              ),
                            ),
                            stsOut:
                                checkDataAttendance['clockOutStatus'] == 'early'
                                    ? 'Lebih Awal'
                                    : 'Normal',
                            noteId: checkDataAttendance['id'],
                            locationStatus:
                                checkDataAttendance['locationStsOut'] ?? '',
                          ),
                        ],
                      ],
                      SizedBox(height: 20.h),
                    ],
                  ),
                ),
              ));
        });
  }

  void _initAnimations() {
    _inController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _inAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _inController, curve: Curves.easeInOut),
    );

    _outController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _outAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _outController, curve: Curves.easeInOut),
    );
  }

  Future<void> _fetchInitialData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();

      await auth.getCurrentUser();

      final user = auth.currentUser;

      if (user == null) return;

      try {
        _handleClockInLogic();
        _handleClockOutLogic();

        await _handleClockInLocation();
        await _handleClockOutLocation();

        setState(() {});
      } catch (e) {
        debugPrint("Error fetching attendance data: $e");
      }
    });
  }

  double calculateDistance(lat1, lon1, lat2, lon2) {
    const earthRadius = 6371000;
    final dLat = _deg2rad(lat2 - lat1);
    final dLon = _deg2rad(lon2 - lon1);

    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_deg2rad(lat1)) *
            cos(_deg2rad(lat2)) *
            sin(dLon / 2) *
            sin(dLon / 2);

    final c = 2 * asin(sqrt(a));
    return earthRadius * c;
  }

  double _deg2rad(double deg) => deg * (pi / 180);

  Future<String> getAddressFromLatLng(double lat, double lon) async {
    try {
      List<geo.Placemark> placemarks =
          await geo.placemarkFromCoordinates(lat, lon);

      if (placemarks.isNotEmpty) {
        final place = placemarks.first;
        return "${place.street}, ${place.locality}";
      }
    } catch (e) {
      print(e);
    }
    return "Alamat tidak ditemukan";
  }

  void _handleClockInLogic() {
    if (checkDataAttendance.isNotEmpty &&
        checkDataAttendance['clockIn'] != null) {
      _checkInData = {
        "time": checkDataAttendance['clockIn'],
        "lat": checkDataAttendance['latitude'] ?? 0.0,
        "lon": checkDataAttendance['lon'] ?? 0.0,
        "status": checkDataAttendance['clockInStatus'],
      };
      _isCheckedIn = true;
      _inController.stop();
      _outController.repeat(reverse: true);
      stsClockIn = "Sudah Clock In";
      return;
    }

    final now = DateTime.now();
    final today = DateFormat("yyyy-MM-dd").format(now);

    final shiftStartStr =
        _workSchedule.isNotEmpty && _workSchedule[0]['shift_start'] != null
            ? "$today ${_workSchedule[0]['shift_start']}"
            : null;

    if (shiftStartStr == null) {
      _resetState();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.myLightRed,
          duration: const Duration(seconds: 7),
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.warning_amber_rounded,
                  color: AppColors.textPrimary),
              SizedBox(width: 10.w),
              Expanded(
                child: RichText(
                  text: const TextSpan(
                    style:
                        TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    children: [
                      TextSpan(text: "Mohon "),
                      TextSpan(
                        text: "hidupkan GPS",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                          text:
                              " anda / Shift Belum Di Konfigurasi Oleh Admin"),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      );

      Navigator.pushNamed(context, RoutesNames.home);
      return;
    }

    try {
      final shiftStart = DateTime.parse(shiftStartStr);
      stsClockIn = now.isAfter(shiftStart) ? "Terlambat" : "Normal";
    } catch (_) {
      stsClockIn = "Custom";
    }
  }

  void _handleClockOutLogic() {
    if (checkDataAttendance.isNotEmpty &&
        checkDataAttendance['clockOut'] != null) {
      _checkOutData = {
        "time": checkDataAttendance['clockOut'],
        "lat": checkDataAttendance['latitude'] ?? 0.0,
        "lon": checkDataAttendance['longitude'] ?? 0.0,
        "status": checkDataAttendance['clockOutStatus'],
      };
      _isCheckedOut = true;
      _outController.stop();
      stsClockOut = "Sudah Clock Out";
      return;
    }

    if (_workSchedule.isEmpty || _workSchedule[0]['shift_end'] == null) {
      stsClockOut = "Jadwal tidak ditemukan";
      return;
    }

    final now = DateTime.now();
    final today = DateFormat("yyyy-MM-dd").format(now);
    final shiftEndStr = "$today ${_workSchedule[0]['shift_end']}";

    try {
      final shiftEnd = DateTime.parse(shiftEndStr);
      stsClockOut = now.isBefore(shiftEnd) ? "Lebih Awal" : "Normal";
    } catch (_) {
      stsClockOut = "Custom";
    }
  }

  Future<void> _handleClockInLocation() async {
    if (checkDataAttendance.isNotEmpty &&
        checkDataAttendance['clockIn'] != null) {
      final status = checkDataAttendance['locationStsIn'];
      if (status == 'offsite') {
        final addr = await getAddressFromLatLng(
          checkDataAttendance['latitude'],
          checkDataAttendance['longitude'],
        );
        infoMyLocationIn =
            "Diluar radius ${checkDataAttendance['officeIn'] ?? ''} : $addr";
        initialInfoIn = "Diluar semua radius kantor";
        stsLocationIn = "Diluar";
      } else {
        infoMyLocationIn =
            "Didalam radius ${checkDataAttendance['officeIn'] ?? '-'}";
        initialInfoIn = "Didalam radius";
        stsLocationIn = "Didalam";
      }
      return;
    }

    await _checkRadiusLocation(isClockIn: true);
  }

  Future<void> _handleClockOutLocation() async {
    if (checkDataAttendance.isNotEmpty &&
        checkDataAttendance['clockOut'] != null) {
      final status = checkDataAttendance['locationStsOut'];
      if (status == 'offsite') {
        final addr = await getAddressFromLatLng(
          checkDataAttendance['latitudeOut'],
          checkDataAttendance['longitudeOut'],
        );
        infoMyLocationOut =
            "Diluar semua radius kantor${checkDataAttendance['officeOut'] ?? ''} : $addr";
        initialInfoOut = "Diluar semua radius kantor";
        stsLocationOut = "Diluar";
      } else {
        infoMyLocationOut =
            "Didalam radius ${checkDataAttendance['officeOut'] ?? '-'}";
        initialInfoOut = "Didalam radius";
        stsLocationOut = "Didalam";
      }
      return;
    }

    await _checkRadiusLocation(isClockIn: false);
  }

  Future<void> _checkRadiusLocation({required bool isClockIn}) async {
    final location = await _getCurrentLocation();
    if (location == null || _workSchedule.isEmpty) {
      if (isClockIn) {
        infoMyLocationIn = "Lokasi tidak ditemukan";
      } else {
        infoMyLocationOut = "Lokasi tidak ditemukan";
      }
      return;
    }

    final lat = double.tryParse(selectedLat ?? '0') ?? 0.0;
    final lon = double.tryParse(selectedLong ?? '0') ?? 0.0;
    final radius = int.tryParse(selectedRadius ?? '0') ?? 0;
    final distance = calculateDistance(lat, lon, mockLatitude, mockLongitude);
    final inside = distance <= radius;
    final officeName = selectedOffice ?? '-';
    final addr = await getAddressFromLatLng(mockLatitude, mockLongitude);

    if (isClockIn) {
      infoMyLocationIn = (stsLocationIn.isNotEmpty)
          ? "Didalam radius $officeName"
          : "Diluar semua radius kantor : $addr";

      stsLocationIn = (stsLocationIn.isNotEmpty) ? "didalam" : "diluar";
      stsLocationGlobal = stsLocationIn;
    } else {
      infoMyLocationOut = (stsLocationOut.isNotEmpty)
          ? "Didalam radius $officeName"
          : "Diluar semua radius kantor : $addr";
      stsLocationOut = (stsLocationOut.isNotEmpty) ? "didalam" : "diluar";
      stsLocationGlobal = stsLocationOut;
    }
  }

  String _getScheduleValue(String key) {
    if (_workSchedule.isNotEmpty) {
      return _workSchedule[0][key] ?? "-";
    }
    return "-";
  }

  Future<LocationData?> _getCurrentLocation() async {
    if (!await _location.serviceEnabled() &&
        !await _location.requestService()) {
      return null;
    }

    var permission = await _location.hasPermission();
    if (permission == PermissionStatus.denied &&
        await _location.requestPermission() != PermissionStatus.granted) {
      return null;
    }

    return await _location.getLocation();
  }

  Future<File?> _takePhoto(double lat, double lon, String pos) async {
    final file = await Navigator.push<File>(
      context,
      MaterialPageRoute(
        builder: (_) => CustomCameraScreen(
          latitude: lat,
          longitude: lon,
          position: pos,
        ),
      ),
    );

    if (file == null) {
      return null;
    }
    return file;
  }

  Future<String?> _showLateNoteDialog({
    required String punchTime,
    required String location,
    required File imageFile,
  }) {
    final noteController = TextEditingController();

    return showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.r),
          ),
          title: Row(
            children: [
              Container(
                padding: EdgeInsets.all(6.r),
                decoration: BoxDecoration(
                  color: colorScheme.primary.withOpacity(.12),
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Icon(
                  Icons.note_add_rounded,
                  size: 18.sp,
                  color: colorScheme.primary,
                ),
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: Text(
                  "Tambah Catatan",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: AppDimens.fontTitle,
                  ),
                ),
              ),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// INFO
                Text(
                  "Waktu Absen : $punchTime",
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                SizedBox(height: 4.h),
                Text("Lokasi : $location"),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    Icon(
                      Icons.edit_note_rounded,
                      size: 16.sp,
                      color: colorScheme.primary,
                    ),
                    SizedBox(width: 6.w),
                    Text(
                      "Catatan (optional)",
                      style: TextStyle(
                        fontSize: 12.sp,
                        fontWeight: FontWeight.w600,
                        color: colorScheme.primary,
                      ),
                    ),
                  ],
                ),

                SizedBox(height: 6.h),

                TextField(
                  controller: noteController,
                  maxLines: 2,
                  decoration: InputDecoration(
                    hintText: "Tulis catatan di sini...",
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                ),

                SizedBox(height: 16.h),

                Row(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => Dialog(
                            backgroundColor: Colors.black,
                            insetPadding: EdgeInsets.all(16.w),
                            child: GestureDetector(
                              onTap: () => Navigator.pop(context),
                              child: InteractiveViewer(
                                child: Image.file(
                                  imageFile,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          imageFile,
                          width: 60.w,
                          height: 60.h,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    InkWell(
                      onTap: () {},
                      borderRadius: BorderRadius.circular(8.r),
                      child: Container(
                        width: 60.w,
                        height: 60.h,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(8.r),
                          border: Border.all(
                            color: colorScheme.outlineVariant,
                          ),
                        ),
                        child: Icon(
                          Icons.camera_alt,
                          color: colorScheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            AppButton(
              label: "Simpan",
              icon: Icons.save_rounded,
              onPressed: () {
                Navigator.pop(context, noteController.text);
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleCheck({required bool isCheckIn}) async {
    if (isCheckIn && _isCheckedIn) {
      _showSnackBar("Anda sudah melakukan Check-in hari ini");
      // return;
    }

    if (!isCheckIn && !_isCheckedIn) {
      _showSnackBar("Anda belum melakukan Check-in");
      // return;
    }

    if (!isCheckIn && _isCheckedOut) {
      _showSnackBar("Anda sudah melakukan Check-out hari ini");
      return;
    }

    setState(() {
      isCheckIn ? _isProcessingIn = true : _isProcessingOut = true;
    });

    final now = DateTime.now();

    try {
      final myLocationOnCamera = stsLocationGlobal == 'diluar'
          ? 'Diluar semua Radius kantor Kantor'
          : selectedOffice ?? '-';

      // final location = await _getCurrentLocation();

      final image = await _takePhoto(
        mockLatitude,
        mockLongitude,
        myLocationOnCamera,
      );

      // if (location == null) {
      //   debugPrint('❌ Location NULL');
      //   _showSnackBar("Lokasi tidak ditemukan");
      //   return;
      // }

      if (image == null) {
        debugPrint('❌ Image NULL (user cancel / camera error)');
        _showSnackBar("Foto tidak ditemukan");
        return;
      }

      if (!image.existsSync()) {
        debugPrint('❌ File tidak ada di path');
        _showSnackBar("File foto tidak tersimpan");
        return;
      }

      final note = await _showLateNoteDialog(
        punchTime: DateFormat.Hm().format(now),
        location: myLocationOnCamera,
        imageFile: image,
      );

      final service = AttendanceService();
      final response = await service.submitAttendance(
        isCheckIn: isCheckIn,
        image: image,
        shiftInOut: _workSchedule.isEmpty
            ? null
            : (isCheckIn
                ? _workSchedule[0]['shift_start']
                : _workSchedule[0]['shift_end']),
        latitude: mockLatitude,
        longitude: mockLongitude,
        place: mockPlace,
        officeId: selectedIdOffice,
        workScheduleId:
            _workSchedule.isNotEmpty ? _workSchedule[0]['id'] : null,
      );

      if (note != null && note.trim().isNotEmpty) {
        await service.addAttendanceNote(
          attendanceId: response.data['data']['id'],
          notes: note,
          attendanceType: isCheckIn ? "in" : "out",
        );
      }

      // final data = {
      //   "time": now,
      //   "lat": location.latitude,
      //   "lon": location.longitude,
      //   "image": image,
      //   "status": "success",
      // };
      checkDataAttendance = await service.getTodayAttendances();

      setState(() {
        if (isCheckIn) {
          // _checkInData = data;
          _isCheckedIn = true;

          checkDataAttendance['clockIn'] = now.toIso8601String();

          _inController.stop();
          _outController.repeat(reverse: true);
        } else {
          // _checkOutData = data;
          _isCheckedOut = true;

          checkDataAttendance['clockOut'] = now.toIso8601String();

          _outController.stop();
        }
      });

      _showSnackBar(isCheckIn ? "Check-in Berhasil" : "Check-out Berhasil");
    } catch (e, s) {
      debugPrint('❌ HANDLE CHECK ERROR: $e');
      debugPrintStack(stackTrace: s);
      _showSnackBar("Error: $e");
    } finally {
      setState(() {
        isCheckIn ? _isProcessingIn = false : _isProcessingOut = false;
      });
    }
  }

  void _showSnackBar(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  AppBar _buildAppBar(colors) {
    return AppBar(
      flexibleSpace: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: Theme.of(context).brightness == Brightness.dark
                ? [AppColors.textPrimary, AppColors.textPrimary]
                : colors,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
      ),
      elevation: 0,
      title: Text(
        _getScheduleValue('office_name').toUpperCase(),
        style: const TextStyle(
          color: AppColors.textLight,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.help_outline, color: AppColors.textLight),
          onPressed: () {},
        ),
      ],
    );
  }
}
