import 'package:dio/dio.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/work_schedule.dart';

class WorkScheduleService {
  final Dio _dio = Dio();

  WorkScheduleService() {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await Tokenmanager.getToken();
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        return handler.next(options);
      },
    ));
  }

  Future<List<WorkSchedule>> getTodaySchedules() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.workSchedule));

      if (response.data['success'] == true) {
        final schedules = (response.data['data'] as List)
            .map((schedule) => WorkSchedule.fromJson(schedule))
            .toList();
        return schedules;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get schedules');
      }
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getTodayShift(int employeeId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.shiftTemplateMine(employeeId)),
      );

      if (response.data['success'] == true) {
        final schedules = response.data['data'];

        if (schedules is List) {
          return schedules
              .map((e) => Map<String, dynamic>.from(e as Map))
              .toList();
        } else {
          throw Exception(
              "Invalid data format: expected List, got ${schedules.runtimeType}");
        }
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get schedules');
      }
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  Future<WorkSchedule?> getScheduleByEmployeeId(int employeeId,
      {String? date}) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.workScheduleEmployeeById(employeeId)),
        queryParameters: date != null ? {'date': date} : null,
      );

      if (response.data['success'] == true) {
        final scheduleData = response.data['data'];
        return scheduleData != null
            ? WorkSchedule.fromJson(scheduleData)
            : null;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get schedule');
      }
    } catch (e) {
      throw Exception('Failed to fetch schedule: $e');
    }
  }

  Future<List<WorkSchedule>> getEmployeeSchedules(
      {String? startDate, String? endDate}) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.workScheduleEmployee),
        queryParameters: {
          if (startDate != null) 'start_date': startDate,
          if (endDate != null) 'end_date': endDate,
        },
      );

      if (response.data['success'] == true) {
        final schedules = (response.data['data']['schedules'] as List)
            .map((schedule) => WorkSchedule.fromJson(schedule))
            .toList();
        return schedules;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to get schedules');
      }
    } catch (e) {
      throw Exception('Failed to fetch schedules: $e');
    }
  }

  Future<bool> createOrUpdateWorkSchedule({
    required int employeeId,
    required dynamic shiftId,
    required int shiftTemplateId,
    required String scheduleDate,
    required String status,
  }) async {
    try {
      final response = await _dio.post(
        Api.url(ApiRoutes.workScheduleInsert),
        data: {
          'employee_id': employeeId,
          'shift_id': shiftId,
          'modal_shift_template': shiftTemplateId,
          'start_date': scheduleDate,
          'end_date': scheduleDate,
          'status': status,
        },
      );

      if (response.data['success'] == true) {
        return true;
      } else {
        throw Exception(response.data['message'] ?? 'Failed to create/update');
      }
    } catch (e) {
      throw Exception('Failed to create/update work schedule: $e');
    }
  }
}
