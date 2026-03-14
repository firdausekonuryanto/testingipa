import 'package:flutter/foundation.dart';
import '../models/kpi.dart';
import '../services/kpi_service.dart';

class KpiProvider extends ChangeNotifier {
  final KpiService _kpiService = KpiService();

  // State
  List<listKpi> _listKpi = [];

  bool _isLoading = false;
  String? _error;

  // Getters
  List<listKpi> get listKpis => _listKpi;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchKpiList(int userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      _listKpi = await _kpiService.getListKpi(userId);
      // print(_listKpi);
    } catch (e) {
      _error = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }
}
