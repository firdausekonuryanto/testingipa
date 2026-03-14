import 'package:flutter/material.dart';
import '../models/dynamic_form_model.dart';
import '../services/dynamic_form_service.dart';

class DynamicFormProvider extends ChangeNotifier {
  final DynamicFormService _service;

  DynamicFormProvider({DynamicFormService? service})
      : _service = service ?? DynamicFormService();

  List<DynamicForm> _forms = [];
  List<DynamicForm> _allForms = [];
  List<DynamicFormResponse> _responses = [];

  bool _isLoading = false;
  String? _errorMessage;

  Map<String, List<Map<String, dynamic>>> _fetchedOptions = {};

  List<DynamicForm> get forms => _forms;
  List<DynamicForm> get allForms => _allForms;
  List<DynamicFormResponse> get responses => _responses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, List<Map<String, dynamic>>> get fetchedOptions => _fetchedOptions;

  Future<List<Map<String, dynamic>>> fetchOptionsByUrl(
      String url, String fieldName) async {
    if (_fetchedOptions.containsKey(fieldName)) {
      return _fetchedOptions[fieldName]!;
    }

    try {
      final options = await _service.fetchOptionsByUrl(url);

      _fetchedOptions[fieldName] = options;
      return options;
    } catch (e) {
      const errorOptions = [
        {
          "label": "Gagal memuat data",
          "name": "Gagal memuat data",
          "modem": 0,
        }
      ];

      _fetchedOptions[fieldName] = errorOptions;
      return errorOptions;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    if (value) {
      _errorMessage = null;
    }
    notifyListeners();
  }

  Future<void> loadAllForms() async {
    _setLoading(true);
    try {
      _allForms = await _service.fetchAllDynamicForms();
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadFormById(int id) async {
    _setLoading(true);
    try {
      _forms = await _service.fetchDynamicFormById(id);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> editLoadFormById(int id) async {
    _setLoading(true);
    try {
      _forms = await _service.fetchDynamicEditFormById(id);
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> submitForm(int formId, Map<String, dynamic> fields) async {
    _setLoading(true);
    try {
      await _service.submitDynamicForm(formId, fields);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> submitFormEdit(int formId, Map<String, dynamic> fields) async {
    _setLoading(true);
    try {
      await _service.submitDynamicFormEdit(formId, fields);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<void> loadFormResponses() async {
    _setLoading(true);
    try {
      _responses = await _service.fetchFormResponses();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }
    _setLoading(false);
  }

  Future<bool> deleteResponse(int responseId) async {
    _setLoading(true);
    try {
      await _service.deleteFormResponse(responseId);

      _responses.removeWhere((res) => res.id == responseId);

      _errorMessage = null;
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      return false;
    }
  }
}
