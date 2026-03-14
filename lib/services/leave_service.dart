import 'dart:io';

import 'package:dio/dio.dart';
import 'package:internusa_group/models/leave.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import 'package:intl/intl.dart';

class LeaveService {
  final Dio _dio = Dio();

  LeaveService() {
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

  Future<LeaveResponse> fetchLeaves() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.leave));

      if (response.data['status'] == 'success') {
        return LeaveResponse.fromJson(response.data);
      } else {
        throw Exception(response.data['message'] ?? 'Unknown error');
      }
    } catch (e) {
      throw Exception('Failed to load leaves: $e');
    }
  }

  Future<void> createLeave({
    required String leaveType,
    required String reason,
    required DateTime startDate,
    required DateTime endDate,
    File? imageFile,
  }) async {
    final dateFormat = DateFormat('yyyy-MM-dd');
    final String formattedStartDate = dateFormat.format(startDate);
    final String formattedEndDate = dateFormat.format(endDate);

    try {
      FormData formData = FormData.fromMap({
        'leave_type': leaveType,
        'reason': reason,
        'start_date': formattedStartDate,
        'end_date': formattedEndDate,
        if (imageFile != null)
          'attachment': await MultipartFile.fromFile(
            imageFile.path,
            filename: imageFile.path.split('/').last,
          ),
      });

      final response = await _dio.post(
        Api.url(ApiRoutes.leaveCreate),
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
        ),
      );

      if (response.statusCode == 422) {
        final errors = response.data['errors'];
        throw Exception('Validation failed: ${errors.toString()}');
      }

      if (response.data['status'] != 'success') {
        throw Exception(response.data['message'] ?? 'Failed to create leave');
      }
    } catch (e) {
      throw Exception('Error creating leave: $e');
    }
  }
}
