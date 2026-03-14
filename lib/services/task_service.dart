import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import '../models/task.dart';
import '../models/task_report.dart';

class TaskService {
  final Dio _dio = Dio();

  TaskService() {
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

  Future<List<Task>> getAllTasks({
    String? status,
    bool? today,
    String? assignDate,
  }) async {
    try {
      final queryParams = {
        if (status != null) 'status': status,
        if (today == true) 'today': 'true',
        if (assignDate != null) 'assign_date': assignDate,
      };

      final response = await _dio.get(
        Api.url(ApiRoutes.task),
        queryParameters: queryParams.isNotEmpty ? queryParams : null,
      );

      if (response.data['success'] == true) {
        return (response.data['data'] as List)
            .map((task) => Task.fromJson(task))
            .toList();
      } else {
        throw Exception(response.data['message'] ?? 'Failed to load tasks');
      }
    } catch (e) {
      throw Exception('Failed to load tasks: $e');
    }
  }

  Future<Task> getTaskDetail(int taskId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.taskById(taskId)),
      );

      if (response.data['success'] == true) {
        return Task.fromJson(response.data['data']);
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load task detail');
      }
    } catch (e) {
      throw Exception('Failed to load task detail: $e');
    }
  }

  Future<List<TaskReport>> getTaskReports(int taskId) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.taskReports(taskId)),
      );

      if (response.data['success'] == true) {
        final reports = (response.data['data'] as List)
            .map((report) => TaskReport.fromJson(report))
            .toList();
        return reports;
      } else {
        throw Exception(
            response.data['message'] ?? 'Failed to load task reports');
      }
    } catch (e) {
      throw Exception('Failed to load task reports: $e');
    }
  }

  Future<TaskReport> createTaskReport({
    required int taskId,
    required String content,
    String? reasonNotCompleted,
    XFile? imageBefore,
    XFile? imageAfter,
  }) async {
    try {
      final formData = FormData.fromMap({
        'report_content': content,
        'reason_not_completed': reasonNotCompleted,
        if (imageBefore != null)
          'before_image': await MultipartFile.fromFile(
            imageBefore.path,
            filename: imageBefore.name,
          ),
        if (imageAfter != null)
          'after_image': await MultipartFile.fromFile(
            imageAfter.path,
            filename: imageAfter.name,
          ),
      });

      final response = await _dio.post(
        Api.url(ApiRoutes.taskReport(taskId)),
        data: formData,
      );

      if (response.data['success'] == true) {
        return TaskReport.fromJson(response.data['data']);
      } else {
        throw Exception(
          response.data['message'] ?? 'Failed to create task report',
        );
      }
    } catch (e) {
      throw Exception('Failed to create task report: $e');
    }
  }

  Future<bool> updateReason(List<int> taskIds, String reason) async {
    try {
      final response = await _dio.put(
        Api.url(ApiRoutes.taskOverdueReason()),
        data: {
          "employee_task_ids": taskIds,
          "reason_not_complated": reason,
        },
      );

      return response.data != null &&
          response.data is Map &&
          response.data['success'] == true;
    } catch (e) {
      print("Error update alasan: $e");
      return false;
    }
  }
}
