import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:internusa_group/routes/api_routes.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/models/dynamic_form_model.dart';

class DynamicFormService {
  final Dio _dio = Dio();

  DynamicFormService() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await Tokenmanager.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          options.headers['Accept'] = 'application/json';
          return handler.next(options);
        },
        onError: (DioException e, handler) {
          print("Dio Error: ${e.message}");
          return handler.next(e);
        },
      ),
    );
  }

  Future<List<Map<String, dynamic>>> fetchOptionsByUrl(String url) async {
    try {
      final response = await _dio.get(url);

      if (response.statusCode == 200) {
        final List<dynamic> items = response.data['data'] ?? [];

        final options = items.map<Map<String, dynamic>>((item) {
          return {
            "label":
                item['label']?.toString() ?? item['name']?.toString() ?? '',
            "name": item['name']?.toString() ?? '',
            "modem": item['is_modem'] ?? 0,
          };
        }).toList();

        return options;
      } else {
        throw Exception('Gagal memuat data dari API: ${response.statusCode}');
      }
    } catch (e) {
      print("Error fetch: $e");
      rethrow;
    }
  }

  Future<List<DynamicForm>> fetchAllDynamicForms() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.dynamicForms));

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => DynamicForm.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data semua form dinamis');
      }
    } on DioException catch (e) {
      throw Exception('Error koneksi: ${e.message}');
    }
  }

  Future<List<DynamicForm>> fetchDynamicFormById(int id) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.dynamicFormsById(id)),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];
        return data.map((e) => DynamicForm.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data form dinamis');
      }
    } on DioException catch (e) {
      throw Exception('Error koneksi: ${e.message}');
    }
  }

  Future<List<DynamicForm>> fetchDynamicEditFormById(int id) async {
    try {
      final response = await _dio.get(
        Api.url(ApiRoutes.dynamicFormsEditById(id)),
      );

      if (response.statusCode == 200 && response.data['success'] == true) {
        final List<dynamic> data = response.data['data'];

        return data.map((e) => DynamicForm.fromJson(e)).toList();
      } else {
        throw Exception('Gagal mengambil data form dinamis');
      }
    } on DioException catch (e) {
      throw Exception('Error koneksi: ${e.message}');
    } catch (e) {
      debugPrint('UNEXPECTED ERROR : $e');
      rethrow;
    }
  }

  Future<void> submitDynamicForm(
      int formId, Map<String, dynamic> fields) async {
    try {
      final formData = FormData();

      fields.forEach((key, value) {
        if (value is File) {
          formData.files.add(
            MapEntry(
              key,
              MultipartFile.fromFileSync(
                value.path,
                filename: value.path.split('/').last,
              ),
            ),
          );
        } else if (value is List<File>) {
          for (var i = 0; i < value.length; i++) {
            final file = value[i];
            formData.files.add(
              MapEntry(
                "${key}[]",
                MultipartFile.fromFileSync(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
          }
        } else {
          formData.fields.add(MapEntry(key, value.toString()));
        }
      });

      final response = await _dio.post(
        Api.url(ApiRoutes.dynamicFormsCreate(formId)),
        data: formData,
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        final errorMsg =
            response.data?['message'] ?? 'Gagal menyimpan data form dinamis';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      print('Submit Error: ${e.response?.data ?? e.message}');
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Error submit form: $errorMsg');
    }
  }

  Future<void> submitDynamicFormEdit(
    int formId,
    Map<String, dynamic> fields,
  ) async {
    final formData = FormData();

    for (final entry in fields.entries) {
      final fieldName = entry.key;
      final fieldValue = entry.value;

      /// ================= SINGLE =================
      if (fieldValue is Map<String, dynamic>) {
        final id = fieldValue['id'];
        final value = fieldValue['value'];
        final file = fieldValue['file'];

        if (id != null) {
          formData.fields.add(
            MapEntry('$fieldName[id]', id.toString()),
          );
        }

        // kirim value HANYA jika tidak ada file
        if (file == null && value != null) {
          formData.fields.add(
            MapEntry('$fieldName[value]', value.toString()),
          );
        }

        if (file != null && file is File) {
          formData.files.add(
            MapEntry(
              '$fieldName[file]',
              await MultipartFile.fromFile(
                file.path,
                filename: file.path.split('/').last,
              ),
            ),
          );
        }
      }

      /// ================= MULTIPLE =================
      if (fieldValue is List) {
        for (int i = 0; i < fieldValue.length; i++) {
          final item = fieldValue[i];

          if (item is! Map<String, dynamic>) continue;

          final id = item['id'];
          final value = item['value'];
          final file = item['file'];

          if (id != null) {
            formData.fields.add(
              MapEntry('$fieldName[$i][id]', id.toString()),
            );
          }

          // kirim value HANYA jika tidak ada file
          if (file == null && value != null) {
            formData.fields.add(
              MapEntry('$fieldName[$i][value]', value.toString()),
            );
          }

          if (file != null && file is File) {
            formData.files.add(
              MapEntry(
                '$fieldName[$i][file]',
                await MultipartFile.fromFile(
                  file.path,
                  filename: file.path.split('/').last,
                ),
              ),
            );
          }
        }
      }
    }

    final response = await _dio.post(
      Api.url(ApiRoutes.dynamicFormsEdit),
      data: formData,
      options: Options(contentType: 'multipart/form-data'),
    );

    if (response.statusCode != 200 || response.data?['success'] != true) {
      throw Exception(
        response.data?['message'] ?? 'Gagal submit dynamic form',
      );
    }
  }

  Future<List<DynamicFormResponse>> fetchFormResponses() async {
    try {
      final response = await _dio.get(Api.url(ApiRoutes.dynamicFormsResponses));

      if (response.statusCode == 200 && response.data['success'] == true) {
        final data = response.data['data'] as List;

        return data.map((e) => DynamicFormResponse.fromJson(e)).toList();
      } else {
        throw Exception('Gagal memuat responses');
      }
    } on DioException catch (e) {
      throw Exception('Error koneksi: ${e.message}');
    }
  }

  Future<void> deleteFormResponse(int responseId) async {
    try {
      final response = await _dio.delete(
        Api.url(ApiRoutes.dynamicFormsDelete(responseId)),
      );

      if (response.statusCode != 200 || response.data['success'] != true) {
        final errorMsg = response.data?['message'] ?? 'Gagal menghapus data';
        throw Exception(errorMsg);
      }
    } on DioException catch (e) {
      final errorMsg = e.response?.data?['message'] ?? e.message;
      throw Exception('Error delete data: $errorMsg');
    }
  }
}
