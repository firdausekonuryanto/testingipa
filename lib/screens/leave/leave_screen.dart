import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/leave.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/providers/leave_provider.dart';

import 'package:internusa_group/widgets/dashboard_header_leave.dart';
import 'package:internusa_group/widgets/date_range_button.dart';
import 'package:internusa_group/widgets/reset_button.dart';
import 'package:internusa_group/screens/leave/widgets/leave_card.dart';
import 'package:internusa_group/widgets/input/search_input.dart';

class LeaveScreen extends StatefulWidget {
  const LeaveScreen({super.key});

  @override
  State<LeaveScreen> createState() => _LeaveScreenState();
}

class _LeaveScreenState extends State<LeaveScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  String _keyword = "";

  List<Leave> _allLeaves = [];
  List<Leave> _filteredLeaves = [];

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final prov = Provider.of<LeaveProvider>(context, listen: false);
      await prov.getLeaves();

      setState(() {
        _allLeaves = prov.leaves;
        _filteredLeaves = prov.leaves;
      });
    });
  }

  void _applyFilters() {
    setState(() {
      _filteredLeaves = _allLeaves.where((leave) {
        final search = _keyword.toLowerCase();

        final matchKeyword = search.isEmpty ||
            leave.type.toLowerCase().contains(search) ||
            leave.reason.toLowerCase().contains(search);

        bool matchDate = true;
        if (_startDate != null &&
            _endDate != null &&
            leave.dateSubmitted.isNotEmpty) {
          final submitted = DateTime.tryParse(leave.dateSubmitted);

          if (submitted != null) {
            final createdDate =
                DateTime(submitted.year, submitted.month, submitted.day);
            final start =
                DateTime(_startDate!.year, _startDate!.month, _startDate!.day);
            final end =
                DateTime(_endDate!.year, _endDate!.month, _endDate!.day);

            matchDate =
                !(createdDate.isBefore(start) || createdDate.isAfter(end));
          }
        }

        return matchKeyword && matchDate;
      }).toList();
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
      _filteredLeaves = _allLeaves;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          final leaveProv = Provider.of<LeaveProvider>(context);

          if (leaveProv.error != null) {
            return Center(child: Text("Error: ${leaveProv.error}"));
          }

          final resume = leaveProv.resume;

          int sick = 0;
          int annual = 0;
          int marriage = 0;
          int maternity = 0;
          int other = 0;

          for (var att in resume) {
            switch (att.type) {
              case 'sick':
                sick = att.total;
                break;
              case 'annual':
                annual = att.total;
                break;
              case 'marriage':
                marriage = att.total;
                break;
              case 'maternity':
                maternity = att.total;
                break;
              case 'other':
                other = att.total;
                break;
            }
          }

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
                "Daftar Pengajuan Cuti",
                style: TextStyle(
                    fontSize: AppDimens.fontTitle, fontWeight: FontWeight.bold),
              ),
              actions: [
                IconButton(
                  icon: const Icon(Icons.add),
                  onPressed: () async {
                    final result = await Navigator.pushNamed(
                      context,
                      RoutesNames.createLeave,
                    );

                    if (result == true) {
                      await leaveProv.getLeaves();
                      setState(() {
                        _allLeaves = leaveProv.leaves;
                        _filteredLeaves = leaveProv.leaves;
                      });
                    }
                  },
                  tooltip: "Tambah Data",
                ),
              ],
            ),
            body: RefreshIndicator(
                onRefresh: () async {
                  await leaveProv.getLeaves();
                  setState(() {
                    _allLeaves = leaveProv.leaves;
                    _filteredLeaves = leaveProv.leaves;
                  });
                },
                child: Container(
                  decoration: BoxDecoration(
                    image: Theme.of(context).brightness == Brightness.dark
                        ? null
                        : const DecorationImage(
                            image: AssetImage("assets/images/bg.png"),
                            fit: BoxFit.cover,
                          ),
                  ),
                  child: ListView(
                    children: [
                      DashboardHeaderLeave(
                        totalData: resume.fold<int>(
                            0, (sum, item) => sum + item.total),
                        sick: sick,
                        annual: annual,
                        maternity: maternity,
                        marriage: marriage,
                        other: other,
                      ),
                      Card(
                        margin: EdgeInsets.symmetric(
                            horizontal: 12.w, vertical: 6.h),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.r),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.textPrimary
                                    : AppColors.textLight,
                            borderRadius: BorderRadius.circular(10.r),
                            border: Border.all(
                              color: AppColors.textSecondary,
                              width: 1.5.w,
                            ),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 16.w, vertical: 8.h),
                          child: Row(
                            children: [
                              Icon(Icons.search,
                                  color: colorScheme.primary,
                                  size: AppDimens.fontTitle),
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
                      if (_filteredLeaves.length < 1) ...[
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
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: EdgeInsets.all(12.w),
                          itemCount: _filteredLeaves.length,
                          itemBuilder: (context, index) {
                            final leave = _filteredLeaves[index];
                            return LeaveCard(leave: leave);
                          },
                        ),
                      ]
                    ],
                  ),
                )),
          );
        });
  }
}
