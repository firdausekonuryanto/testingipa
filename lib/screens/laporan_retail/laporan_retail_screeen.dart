import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/models/customer.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/providers/customerservice_provider.dart';

import 'package:internusa_group/widgets/dashboard_header.dart';
import 'package:internusa_group/widgets/date_range_button.dart';
import 'package:internusa_group/widgets/reset_button.dart';
import 'package:internusa_group/widgets/card_report.dart';
import 'package:internusa_group/widgets/input/search_input.dart';
import 'package:internusa_group/widgets/loading/loading_state_widget.dart';

class LaporanRetailScreen extends StatefulWidget {
  const LaporanRetailScreen({super.key});

  @override
  State<LaporanRetailScreen> createState() => _LaporanRetailScreenState();
}

class _LaporanRetailScreenState extends State<LaporanRetailScreen> {
  List<Customer> _allCustomers = [];
  List<Customer> _filteredCustomers = [];
  DateTime? _startDate;
  DateTime? _endDate;
  String _keyword = "";
  bool _hasShownNoDataMessage = false;
  int? userID = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;
      if (user != null) {
        await context.read<CustomerServiceProvider>().fetchCustomers(user.id);
        final provider = context.read<CustomerServiceProvider>();
        setState(() {
          _allCustomers = provider.customers;
          _filteredCustomers = provider.customers;
          userID = user.id;
          isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      final customers = _allCustomers;
      _filteredCustomers = customers.where((w) {
        final name = w.name.toLowerCase();
        final branch = w.branch?.name.toLowerCase() ?? '';
        final search = _keyword.toLowerCase();

        final matchKeyword = _keyword.isEmpty ||
            name.contains(search) ||
            branch.contains(search);

        final created = DateTime.tryParse(w.createdAt);
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

      if (_filteredCustomers.isEmpty && !_hasShownNoDataMessage) {
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

      if (_filteredCustomers.isNotEmpty) {
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
      _filteredCustomers = _allCustomers;
    });
  }

  @override
  Widget build(BuildContext context) {
    ;
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
                "Laporan Retail",
                style: TextStyle(fontSize: 18.sp),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add, size: 22.sp),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      RoutesNames.createLaporanRetail,
                    );

                    if (result == true) {
                      await context
                          .read<CustomerServiceProvider>()
                          .fetchCustomers(userID);
                      final provider = context.read<CustomerServiceProvider>();
                      setState(() {
                        _allCustomers = provider.customers;
                        _filteredCustomers = provider.customers;
                      });
                    }
                  },
                  tooltip: "Tambah Data",
                ),
              ],
            ),
            body: Container(
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
              child: RefreshIndicator(
                onRefresh: () async {
                  final auth = context.read<AuthProvider>();
                  await auth.getCurrentUser();
                  final user = auth.currentUser;
                  if (user != null) {
                    await context
                        .read<CustomerServiceProvider>()
                        .fetchCustomers(user.id);
                    final provider = context.read<CustomerServiceProvider>();
                    setState(() {
                      _allCustomers = provider.customers;
                      _filteredCustomers = provider.customers;
                      userID = user.id;
                    });
                  }
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DashboardHeader(
                      totalData: _filteredCustomers.length,
                      leftData: _filteredCustomers
                          .where((c) => c.purpose == "psb")
                          .length,
                      rightData: _filteredCustomers
                          .where((c) => c.purpose == "repair")
                          .length,
                      leftLabel: "PSB",
                      rightLabel: "Perbaikan",
                      iconTotalData: Icons.people,
                      iconLeftData: Icons.add,
                      iconRightData: Icons.car_repair_sharp,
                    ),
                    Card(
                      margin:
                          EdgeInsets.symmetric(horizontal: 12.w, vertical: 6.h),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.r),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimary
                              : AppColors.textLight,
                          borderRadius: BorderRadius.circular(10.r),
                          border: Border.all(
                            color: AppColors.primary.withValues(alpha: 0.5),
                            width: 1.5.w,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Icon(
                              Icons.search,
                              color: AppColors.textSecondary,
                              size: 24.sp,
                            ),
                            SizedBox(width: 8.w),
                            Expanded(
                              child: SearchInput(
                                onChanged: _updateKeyword,
                              ),
                            ),
                          ],
                        ),
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
                          ResetButton(onPressed: _resetFilters),
                        ],
                      ),
                    ),
                    if (isLoading) ...[
                      SizedBox(height: 100.h),
                      const LoadingStateWidget(),
                    ],
                    if (_startDate != null && _endDate != null)
                      Container(
                        margin: EdgeInsets.only(top: 16.h),
                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                        child: Row(
                          children: [
                            Text(
                              "Filter By Date : "
                              "${_startDate!.day}-${_startDate!.month}-${_startDate!.year} "
                              "s/d ${_endDate!.day}-${_endDate!.month}-${_endDate!.year}",
                            ),
                          ],
                        ),
                      ),
                    if (isLoading == false && _filteredCustomers.isEmpty) ...[
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
                        itemCount: _filteredCustomers.length,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final customer = _filteredCustomers[index];
                          return CardReport(
                            title: customer.name,
                            purpose: customer.purpose,
                            branchName: customer.branch?.name ?? "-",
                            createdAt: customer.createdAt,
                            routeVoidCallback: () async {
                              await Navigator.pushNamed(
                                context,
                                RoutesNames.viewLaporanRetail,
                                arguments: customer,
                              );
                            },
                          );
                        },
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        });
  }
}
