import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/product_subscription.dart';

import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/providers/product_subscription_provider.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/widgets/card_subscription.dart';
import 'package:internusa_group/widgets/dashboard_header.dart';
import 'package:internusa_group/widgets/date_range_button.dart';
import 'package:internusa_group/widgets/reset_button.dart';
import 'package:internusa_group/widgets/loading/loading_state_widget.dart';
import 'package:internusa_group/widgets/input/search_input.dart';

class ProductSubscriptionScreen extends StatefulWidget {
  const ProductSubscriptionScreen({super.key});

  @override
  State<ProductSubscriptionScreen> createState() =>
      _ProductSubscriptionScreenState();
}

class _ProductSubscriptionScreenState extends State<ProductSubscriptionScreen> {
  List<ProductSubscription> _allData = [];
  List<ProductSubscription> _filteredData = [];
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
        await context.read<ProductSubscriptionProvider>().fetchSubscriptions();
        final provider = context.read<ProductSubscriptionProvider>();
        setState(() {
          _allData = provider.subscriptions;
          _filteredData = provider.subscriptions;
          userID = user.id;
          isLoading = false;
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      final data = _allData;
      _filteredData = data.where((item) {
        final name = item.name.toLowerCase();
        final productName = item.productName?.toLowerCase() ?? '';
        final search = _keyword.toLowerCase();

        final matchKeyword = _keyword.isEmpty ||
            name.contains(search) ||
            productName.contains(search);

        final created = item.createdAt;
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

      if (_filteredData.isEmpty && !_hasShownNoDataMessage) {
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

      if (_filteredData.isNotEmpty) {
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
      _filteredData = _allData;
    });
  }

  @override
  Widget build(BuildContext context) {
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
                "Putus Langganan",
                style: TextStyle(fontSize: 18.sp),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.add, size: 22.sp),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      RoutesNames.createProductSubscription,
                    );

                    if (result != true) return;

                    final provider =
                        context.read<ProductSubscriptionProvider>();

                    try {
                      await provider.fetchSubscriptions();

                      if (!mounted) return;

                      setState(() {
                        _allData = provider.subscriptions;
                        _filteredData = provider.subscriptions;
                      });
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Gagal memuat data terbaru: $e')),
                      );
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
                        .read<ProductSubscriptionProvider>()
                        .fetchSubscriptions();
                    final provider =
                        context.read<ProductSubscriptionProvider>();
                    setState(() {
                      _allData = provider.subscriptions;
                      _filteredData = provider.subscriptions;
                      userID = user.id;
                    });
                  }
                },
                child: ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    DashboardHeader(
                      totalData: _filteredData.length,
                      leftData: _filteredData
                          .where((c) => (c.terminationReason).isEmpty)
                          .length,
                      rightData: _filteredData
                          .where((c) => (c.terminationReason).isNotEmpty)
                          .length,
                      leftLabel: "Aktif",
                      rightLabel: "Berhenti",
                      iconTotalData: Icons.people,
                      iconLeftData: Icons.check_circle,
                      iconRightData: Icons.cancel,
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
                            color: colors.first.withValues(alpha: 0.5),
                            width: 1.5.w,
                          ),
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: 16.w, vertical: 8.h),
                        child: Row(
                          children: [
                            Icon(Icons.search,
                                color: AppColors.textSecondary, size: 24.sp),
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
                    if (isLoading == false && _filteredData.isEmpty) ...[
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
                                    ? AppColors.background
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
                                    ? AppColors.background
                                    : AppColors.textPrimary,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      )
                    ] else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: _filteredData.length,
                        itemBuilder: (context, index) {
                          final item = _filteredData[index];
                          return CardSubscription(
                            name: item.name,
                            phone: item.phone,
                            address: item.address,
                            productSN:
                                "${item.productName} - ${item.serialNumber}",
                            subscriptionPackage: item.subscriptionPackage,
                            terminationReason: item.terminationReason,
                            createdAt: item.createdAt.toString(),
                            colors: colors.last,
                          );
                        },
                      ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
