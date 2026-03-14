import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:internusa_group/providers/workproduct_provider.dart';

import 'package:internusa_group/models/work_product.dart';

import 'package:internusa_group/widgets/dashboard_header.dart';
import 'package:internusa_group/widgets/date_range_button.dart';
import 'package:internusa_group/widgets/reset_button.dart';
import 'package:internusa_group/widgets/loading/loading_state_widget.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/widgets/input/search_input.dart';
import 'package:internusa_group/widgets/card_report.dart';

import 'package:internusa_group/utils/theme.dart';

class LaporanOdpScreen extends StatefulWidget {
  const LaporanOdpScreen({super.key});

  @override
  State<LaporanOdpScreen> createState() => _LaporanOdpScreenState();
}

class _LaporanOdpScreenState extends State<LaporanOdpScreen> {
  List<WorkProducts> _allWorkProducts = [];
  List<WorkProducts> _filteredWorkProducts = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _keyword = "";
  bool _hasShownNoDataMessage = false;
  int? userID = 0;
  bool isLoading = true;

  final Map<String, String> purposes = {
    "psb": "Pasang Baru",
    "repair": "Perbaikan",
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;
      if (user != null) {
        await context.read<WorkproductProvider>().fetchWorkproducts(user.id);
        final provider = context.read<WorkproductProvider>();
        setState(() {
          _allWorkProducts = provider.workproducts;
          _filteredWorkProducts = provider.workproducts;
          userID = user.id;
          isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      final workproducts = _allWorkProducts;
      _filteredWorkProducts = workproducts.where((w) {
        final name = w.name.toLowerCase();
        final branch = w.transaction?.branch?.name.toLowerCase() ?? "";

        final search = _keyword.toLowerCase();

        final matchKeyword = _keyword.isEmpty ||
            name.contains(search) ||
            branch.contains(search);

        final created = DateTime.tryParse(w.createdAt ?? '');
        bool matchDate = true;

        if (created != null) {
          final createdDate =
              DateTime(created.year, created.month, created.day);

          DateTime? startDate = _startDate != null
              ? DateTime(_startDate!.year, _startDate!.month, _startDate!.day)
              : null;
          DateTime? endDate = _endDate != null
              ? DateTime(_endDate!.year, _endDate!.month, _endDate!.day)
              : null;

          if (startDate != null) {
            matchDate = createdDate.isAfter(startDate) ||
                createdDate.isAtSameMomentAs(startDate);
          }
          if (endDate != null) {
            matchDate = matchDate &&
                (createdDate.isBefore(endDate) ||
                    createdDate.isAtSameMomentAs(endDate));
          }
        }

        return matchKeyword && matchDate;
      }).toList();

      if (_filteredWorkProducts.isEmpty && !_hasShownNoDataMessage) {
        _hasShownNoDataMessage = true;
        WidgetsBinding.instance.addPostFrameCallback((_) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Data tidak ada"),
              duration: Duration(seconds: 2),
            ),
          );
        });
      }

      if (_filteredWorkProducts.isNotEmpty) {
        _hasShownNoDataMessage = false;
      }
    });
  }

  void _updateKeyword(String keyword) {
    _keyword = keyword;
    _applyFilters();
  }

  void _updateDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
  }

  void _resetFilters() {
    setState(() {
      _keyword = "";
      _startDate = null;
      _endDate = null;
      _filteredWorkProducts = _allWorkProducts;
    });
  }

  @override
  Widget build(BuildContext context) {
    final uniqueBranches = _filteredWorkProducts
        .map((w) => w.transaction?.branch?.name)
        .where((name) => name != null)
        .toSet()
        .length;

    final now = DateTime.now();

    final thisMonthTrans = _filteredWorkProducts
        .where((data) {
          final createdDate = DateTime.tryParse(data.createdAt!);
          if (createdDate == null) return false;
          return createdDate.month == now.month && createdDate.year == now.year;
        })
        .toList()
        .length;
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
                title: const Text("Laporan ODP"),
                actions: [
                  IconButton(
                    icon: const Icon(Icons.add),
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        RoutesNames.createLaporanOdp,
                      );

                      if (result == true) {
                        await context
                            .read<WorkproductProvider>()
                            .fetchWorkproducts(userID);
                        final provider = context.read<WorkproductProvider>();
                        setState(() {
                          _allWorkProducts = provider.workproducts;
                          _filteredWorkProducts = provider.workproducts;
                        });
                      }
                    },
                    tooltip: "Tambah Data",
                  ),
                ],
              ),
              body: RefreshIndicator(
                  onRefresh: () async {
                    final auth = context.read<AuthProvider>();
                    final user = auth.currentUser;

                    if (user != null) {
                      await context
                          .read<WorkproductProvider>()
                          .fetchWorkproducts(user.id);
                      final provider = context.read<WorkproductProvider>();
                      setState(() {
                        _allWorkProducts = provider.workproducts;
                        _filteredWorkProducts = provider.workproducts;
                      });
                    }
                  },
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    decoration: BoxDecoration(
                      image: Theme.of(context).brightness == Brightness.dark
                          ? null
                          : const DecorationImage(
                              image: AssetImage("assets/images/bg.png"),
                              fit: BoxFit.cover,
                            ),
                    ),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              DashboardHeader(
                                totalData: _filteredWorkProducts.length,
                                leftData: thisMonthTrans,
                                rightData: uniqueBranches,
                                leftLabel: "Bulan Ini",
                                rightLabel: "Cabang",
                                iconTotalData: Icons.data_usage,
                                iconLeftData: Icons.calendar_month,
                                iconRightData: Icons.production_quantity_limits,
                              ),
                              Card(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 12.w, vertical: 6.h),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10.r),
                                ),
                                child: Column(
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.textPrimary
                                            : AppColors.textLight,
                                        borderRadius:
                                            BorderRadius.circular(10.r),
                                        border: Border.all(
                                          color: AppColors.primary
                                              .withValues(alpha: 0.5),
                                          width: 1.5.w,
                                        ),
                                      ),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: 16.w, vertical: 8.h),
                                      child: Row(
                                        children: [
                                          Icon(Icons.search,
                                              color: AppColors.textSecondary,
                                              size: 24.sp),
                                          SizedBox(width: 8.w),
                                          Expanded(
                                            child: SearchInput(
                                              onChanged: _updateKeyword,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 16.w),
                                child: Row(
                                  children: [
                                    DateRangeButton(
                                      startDate: _startDate,
                                      endDate: _endDate,
                                      onDateRangePicked: _updateDateRange,
                                    ),
                                    SizedBox(width: 10.w),
                                    ResetButton(
                                      onPressed: _resetFilters,
                                    ),
                                  ],
                                ),
                              ),
                              if (_startDate != null && _endDate != null) ...[
                                Container(
                                  margin: EdgeInsets.only(top: 16.h),
                                  padding:
                                      EdgeInsets.symmetric(horizontal: 16.w),
                                  child: Row(
                                    children: [
                                      Text(
                                        "Filter By Date : ${_startDate!.day}-${_startDate!.month}-${_startDate!.year} "
                                        "s/d ${_endDate!.day}-${_endDate!.month}-${_endDate!.year}",
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                              if (isLoading) ...[
                                SizedBox(height: 100.h),
                                const LoadingStateWidget(),
                              ],
                              if (_filteredWorkProducts.isEmpty &&
                                  isLoading == false) ...[
                                Padding(
                                  padding: EdgeInsets.all(10.w),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Lottie.asset('assets/NoDataFound.json'),
                                      Text(
                                        "Tidak ada data ditemukan",
                                        style: TextStyle(
                                          fontSize: 18.sp,
                                          fontWeight: FontWeight.bold,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.surface
                                              : AppColors.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                      Text(
                                        "Silakan coba dengan kata kunci lain.",
                                        style: TextStyle(
                                          fontSize: 14.sp,
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.surface
                                              : AppColors.textPrimary,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ],
                                  ),
                                )
                              ] else ...[
                                SizedBox(height: 10.h),
                                ListView.builder(
                                  itemCount: _filteredWorkProducts.length,
                                  shrinkWrap: true,
                                  physics: const NeverScrollableScrollPhysics(),
                                  itemBuilder: (context, index) {
                                    final workproduct =
                                        _filteredWorkProducts[index];
                                    return CardReport(
                                      title: workproduct.name,
                                      purpose: "psb",
                                      branchName: workproduct
                                              .transaction?.branch?.name ??
                                          "-",
                                      createdAt: workproduct.createdAt,
                                      routeVoidCallback: () async {
                                        await Navigator.pushNamed(
                                          context,
                                          RoutesNames.viewLaporanOdp,
                                          arguments: workproduct,
                                        );
                                      },
                                    );
                                  },
                                ),
                              ]
                            ],
                          ),
                        ),
                      ],
                    ),
                  )));
        });
  }
}
