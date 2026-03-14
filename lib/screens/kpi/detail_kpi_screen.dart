import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';

import 'package:internusa_group/models/kpi.dart';

import 'package:internusa_group/services/kpi_service.dart';

import 'package:internusa_group/widgets/background_decoration.dart';

import 'package:internusa_group/screens/kpi/widgets/info_row.dart';
import 'package:internusa_group/screens/kpi/widgets/kpi_item.dart';

class DetailKpiScreen extends StatefulWidget {
  final int id;
  const DetailKpiScreen({super.key, required this.id});
  @override
  State<DetailKpiScreen> createState() => _DetailKpiScreenState();
}

class _DetailKpiScreenState extends State<DetailKpiScreen> {
  final KpiService _kpiService = KpiService();
  KpiResponse? _kpiResponse;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadKpi();
  }

  Future<void> _loadKpi() async {
    try {
      final result = await _kpiService.getKpi(widget.id);
      setState(() {
        _kpiResponse = result;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return Scaffold(
            appBar: AppBar(
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
              title: Text(
                "Detail Hasil KPI",
                style: TextStyle(
                    fontSize: AppDimens.fontTitle, fontWeight: FontWeight.bold),
              ),
            ),
            body: BackgroundDecoration(
                child: SingleChildScrollView(
              padding: EdgeInsets.all(16.r),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ================= Informasi Karyawan =================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: colorScheme.primary,
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              Icon(
                                Icons.badge,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.white,
                                size: AppDimens.fontTitle,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Informasi Karyawan",
                                style: TextStyle(
                                     color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppDimens.fontTitle),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _error != null
                                  ? Text("Error: $_error")
                                  : _kpiResponse == null
                                      ? const Text("Tidak ada data")
                                      : Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            InfoRow(
                                              icon: Icons.person,
                                              label: "Nama",
                                              value: _kpiResponse!
                                                  .informasiKaryawan
                                                  .employeeName,
                                            ),
                                            InfoRow(
                                              icon: Icons.badge,
                                              label: "ID",
                                              value: _kpiResponse!
                                                  .informasiKaryawan.employeeId
                                                  .toString(),
                                            ),
                                            InfoRow(
                                              icon: Icons.apartment,
                                              label: "Dept.",
                                              value: _kpiResponse!
                                                  .informasiKaryawan.department,
                                            ),
                                            InfoRow(
                                              icon: Icons.date_range,
                                              label: "Periode",
                                              value: _kpiResponse!
                                                  .informasiKaryawan.period,
                                            ),
                                            InfoRow(
                                              icon: Icons.assignment,
                                              label: "Template",
                                              value: _kpiResponse!
                                                  .informasiKaryawan.template,
                                            ),
                                          ],
                                        ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // ================= Ringkasan Kinerja =================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: colorScheme.primary,
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              Icon(
                                Icons.bar_chart,
                                color: Theme.of(context).brightness == Brightness.dark
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.white,
                                size: AppDimens.fontTitle,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Ringkasan Kinerja",
                                style: TextStyle(
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color.fromARGB(255, 0, 0, 0)
                                        : Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: AppDimens.fontTitle),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.all(16.r),
                          child: Column(
                            children: [
                              Text(
                                (_kpiResponse?.ringkasanKinerja
                                            .tugasBelumDikerjakan ??
                                        0)
                                    .toString(),
                                style: TextStyle(
                                  fontSize: AppDimens.fontXL,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Tugas Belum Dikerjakan",
                                  style: TextStyle(
                                      fontSize: AppDimens.fontCaption)),
                              const Divider(color: AppColors.textSecondary),
                              Text(
                                _kpiResponse?.ringkasanKinerja.level?.level ??
                                    "-",
                                style: TextStyle(
                                  color: getColorFromLevel(
                                      context,
                                      _kpiResponse
                                          ?.ringkasanKinerja.level?.color),
                                  fontSize: AppDimens.fontTitle,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _kpiResponse
                                        ?.ringkasanKinerja.level?.description ??
                                    "-",
                                style: TextStyle(
                                    color: getColorFromLevel(
                                        context,
                                        _kpiResponse
                                            ?.ringkasanKinerja.level?.color),
                                    fontSize: AppDimens.fontBody),
                                textAlign: TextAlign.center,
                              ),
                              SizedBox(height: 20.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  _buildSummaryItem(
                                      "Total Score KPI",
                                      ((_kpiResponse?.ringkasanKinerja
                                                  .totalSkorKpi ??
                                              0))
                                          .toStringAsFixed(2)),
                                  _buildSummaryItem("Total Weight", "100"),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16.h),
                  // ================= Ringkasan Hasil KPI =================
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          color: colorScheme.primary,
                          padding: EdgeInsets.all(12.r),
                          child: Row(
                            children: [
                              Icon(
                                Icons.assignment_turned_in,
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? const Color.fromARGB(255, 0, 0, 0)
                                    : Colors.white,
                                size: AppDimens.fontTitle,
                              ),
                              SizedBox(width: 8.w),
                              Text(
                                "Ringkasan Hasil KPI",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: AppDimens.fontTitle,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? const Color.fromARGB(255, 0, 0, 0)
                                      : Colors.white,
                                ),
                              ),
                            ],
                          ),
                        ),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount:
                              _kpiResponse?.hasilPerhitunganKpi.length ?? 0,
                          itemBuilder: (context, index) {
                            final item =
                                _kpiResponse!.hasilPerhitunganKpi[index];

                            return KpiItem(
                              no: item.no.toString(),
                              indikator: item.indicator,
                              bobot: item.bobot,
                              target: item.targetValue.toString(),
                              totalTask: item.totalTask.toString(),
                              aktualisasi: item.aktualisasi.toString(),
                              skor: "${item.skorKpi} %",
                              task: item.task ?? "-",
                              detailTask: item.detailTask,
                            );
                          },
                        ),
                      ],
                    ),
                  )
                ],
              ),
            )),
          );
        });
  }

  Widget _buildSummaryItem(String title, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: AppDimens.fontHeading,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).brightness == Brightness.dark
                ? AppColors.myLightGreen
                : Colors.black,
          ),
        ),
        SizedBox(height: 4.h),
        Text(title, style: TextStyle(fontSize: AppDimens.fontCaption)),
      ],
    );
  }
}
