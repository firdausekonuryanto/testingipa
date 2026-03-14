import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:http_parser/http_parser.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/attendance.dart';

class AttendanceService {
  final Dio _dio = Dio();

  AttendanceService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await Tokenmanager.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        options.headers['Accept'] = 'application/json';
        return handler.next(options);
      },
    ));
  }

  Future<List<Attendance>> getAllAttendances() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.attendance));

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((item) => Attendance.fromJson(item))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load attendances: $e');
    }
  }

  Future<AttendanceMontly> getMontlyAttendances() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.attendanceMontly));

      if (response.data['success'] == true) {
        return AttendanceMontly.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load attendances: $e');
    }
  }

  Future<AttendanceMontly> getMontlyAttendancesByDate(DateTime date) async {
    try {
      final dateStr = "${date.year.toString().padLeft(4, '0')}-"
          "${date.month.toString().padLeft(2, '0')}-"
          "${date.day.toString().padLeft(2, '0')}";

      final response = await _dio.get(
        Api.url(ApiRoutes.attendanceByDate(dateStr)),
      );

      if (response.data['success'] == true) {
        return AttendanceMontly.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load attendances: $e');
    }
  }

  Future<List<Map<String, String>>> getWorkSchedules() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.workSchedule));

      if (response.data['success'] == true) {
        return (response.data['data'] as List).map((item) {
          return {
            'schedule_date': item['schedule_date'].toString(),
            'employee_name': item['employee_name'].toString(),
            'shift_name': item['shift_name'].toString(),
            'shift_start': item['shift_start'].toString(),
            'shift_end': item['shift_end'].toString(),
            'status': item['status'].toString(),
            'shift_template_name': item['shift_template_name'].toString(),
            'office_name': item['office_name'].toString(),
            'latitude': item['latitude'].toString(),
            'longitude': item['longitude'].toString(),
            'radius': item['radius'].toString(),
          };
        }).toList();
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load work schedules: $e');
    }
  }

  Future<Response> submitAttendance({
    required bool isCheckIn,
    required File image,
    required dynamic shiftInOut,
    required double latitude,
    required double longitude,
    required String place,
    required int? officeId,
    String? workScheduleId,
  }) async {
    try {
      // ================= VALIDASI DASAR =================
      if (!image.existsSync()) {
        throw Exception('Image file not found');
      }

      // ================= BUILD FORM DATA =================
      final formData = FormData.fromMap({
        if (workScheduleId != null) 'work_schedule_id': workScheduleId,
        if (shiftInOut != null) 'shift_in_out': shiftInOut,
        'latitude': latitude,
        'longitude': longitude,
        'place': place,
        'office_id': officeId,
        'clock_image': await MultipartFile.fromFile(
          image.path,
          filename: image.path.split('/').last,
        ),
      });

      // ================= ENDPOINT =================
      final endpoint =
          isCheckIn ? Api.url(ApiRoutes.clockin) : Api.url(ApiRoutes.clockout);

      // ================= REQUEST =================
      final response = await _dio.post(
        endpoint,
        data: formData,
        options: Options(
          validateStatus: (status) => status != null && status < 500,
        ),
      );

      if (response.statusCode != 200 && response.statusCode != 201) {
        throw DioException(
          requestOptions: response.requestOptions,
          response: response,
          type: DioExceptionType.badResponse,
        );
      }

      return response;
    } catch (e, s) {
      debugPrint('❌ SUBMIT ATTENDANCE ERROR');
      debugPrint('ERROR: $e');
      debugPrintStack(stackTrace: s);
      rethrow;
    }
  }

  String? _safeOffice(dynamic office) {
    if (office == null) return null;
    if (office is String) return office;
    if (office is Map && office['name'] != null) {
      return office['name'].toString();
    }
    return null;
  }

  Map<String, dynamic>? _locationByType(List? locations, String type) {
    if (locations == null) return null;

    return locations.cast<Map<String, dynamic>>().firstWhere(
          (e) => e['attendance_type'] == type,
          orElse: () => {},
        );
  }

  Future<Map<String, dynamic>> getTodayAttendances({
    bool? hasClockIn,
    bool? hasClockOut,
  }) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.attendanceToday),
        queryParameters: {
          if (hasClockIn != null) 'has_clock_in': hasClockIn,
          if (hasClockOut != null) 'has_clock_out': hasClockOut,
        },
      );

      if (response.data['success'] == true) {
        final attendanceDataList = response.data['data'];

        if (attendanceDataList != null && attendanceDataList.isNotEmpty) {
          final attendanceData = attendanceDataList[0];
          final locations = attendanceData['locations'];
          final office = attendanceData['office'];
          final workSchedule = attendanceData['work_schedule']?['shift'];
          final locationIn = _locationByType(locations, 'in');
          final locationOut = _locationByType(locations, 'out');
          return {
            'date': response.data['date'],
            'count': response.data['count'],
            'id': attendanceData['id'],
            'clockInShift': (workSchedule != null &&
                    workSchedule['shift_start'] != null &&
                    workSchedule['shift_start'].toString().isNotEmpty)
                ? _parseClockTime(workSchedule['shift_start'])
                : null,
            'clockOutShift': (workSchedule != null &&
                    workSchedule['shift_end'] != null &&
                    workSchedule['shift_end'].toString().isNotEmpty)
                ? _parseClockTime(workSchedule['shift_end'])
                : null,
            'clockIn': _parseClockTime(attendanceData['clock_in']),
            'clockOut': _parseClockTime(attendanceData['clock_out']),
            'clockInStatus': attendanceData['clock_in_status'],
            'clockOutStatus': attendanceData['clock_out_status'],

            // LOCATION IN
            'latitude': locationIn != null
                ? double.tryParse(locationIn['lat']?.toString() ?? '')
                : null,
            'longitude': locationIn != null
                ? double.tryParse(locationIn['long']?.toString() ?? '')
                : null,
            'officeIn':
                locationIn != null ? _safeOffice(locationIn['office']) : null,
            'locationStsIn': locationIn?['status'] as String?,

            // LOCATION OUT
            'latitudeOut': locationOut != null
                ? double.tryParse(locationOut['lat']?.toString() ?? '')
                : null,
            'longitudeOut': locationOut != null
                ? double.tryParse(locationOut['long']?.toString() ?? '')
                : null,
            'officeOut':
                locationOut != null ? _safeOffice(locationOut['office']) : null,
            'locationStsOut': locationOut?['status'] as String?,
            'officeName': office != null ? office['name'] : null,
          };
        } else {
          return {};
        }
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load today\'s attendances: $e');
    }
  }

  DateTime? _parseClockTime(String? timeStr) {
    if (timeStr == null) return null;

    final parts = timeStr.split(':');
    if (parts.length < 2) return null;

    final now = DateTime.now();
    return DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
      parts.length > 2 ? int.parse(parts[2]) : 0,
    );
  }

  Future<Attendance> clockIn({
    int? workScheduleId,
    required File clockInImage,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String fileName = clockInImage.path.split('/').last;
      FormData formData = FormData.fromMap({
        if (workScheduleId != null) 'work_schedule_id': workScheduleId,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'clock_image': await MultipartFile.fromFile(
          clockInImage.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        Api.url(ApiRoutes.clockin),
        data: formData,
      );

      if (response.data['success'] == true) {
        final attendanceData = response.data['data'];
        return Attendance.fromJson(attendanceData);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to clock in: $e');
    }
  }

  Future<Attendance> clockOut({
    required File clockOutImage,
    double? latitude,
    double? longitude,
  }) async {
    try {
      String fileName = clockOutImage.path.split('/').last;
      FormData formData = FormData.fromMap({
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        'clock_image': await MultipartFile.fromFile(
          clockOutImage.path,
          filename: fileName,
          contentType: MediaType('image', 'jpeg'),
        ),
      });

      final response = await _dio.post(
        Api.url(ApiRoutes.clockout),
        data: formData,
      );

      if (response.data['success'] == true) {
        return Attendance.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to clock out: $e');
    }
  }

  Future<AttendanceNote> addAttendanceNote({
    required int attendanceId,
    required String notes,
    required String attendanceType,
  }) async {
    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.attendanceNotes(attendanceId)),
        data: {
          'notes': notes,
          'attendance_type': attendanceType,
        },
      );

      if (response.data['success'] == true) {
        return AttendanceNote.fromJson(response.data['data']);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to add attendance note: $e');
    }
  }

  Future<List<AttendanceNote>> getAttendanceNotes(
    int attendanceId, {
    String? attendanceType,
  }) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.attendanceNotes(attendanceId)),
      );

      if (response.data['success'] == true) {
        final notes = (response.data['data'] as List)
            .map((item) => AttendanceNote.fromJson(item))
            .toList();

        if (attendanceType != null) {
          return notes
              .where((n) => n.attendanceType == attendanceType)
              .toList();
        }

        return notes;
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load attendance notes: $e');
    }
  }
}
