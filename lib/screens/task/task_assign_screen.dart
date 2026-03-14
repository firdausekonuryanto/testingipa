import 'package:internusa_group/providers/task_provider.dart';
import 'package:internusa_group/screens/task/widgets/info_row.dart';
import 'package:internusa_group/screens/task/widgets/outline_dropdown.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:percent_indicator/percent_indicator.dart';

import 'package:internusa_group/providers/assignment_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/widgets/dashboard_header.dart';
import 'package:internusa_group/widgets/date_range_button.dart';
import 'package:internusa_group/widgets/reset_button.dart';

class TaskAssignScreen extends StatefulWidget {
  const TaskAssignScreen({super.key});

  @override
  State<TaskAssignScreen> createState() => _TaskAssignScreenState();
}

class _TaskAssignScreenState extends State<TaskAssignScreen> {
  List<Map<String, dynamic>> _allTaskAssignment = [];
  List<Map<String, dynamic>> _filteredTaskAssignment = [];
  int selectedMonth = DateTime.now().month;
  int selectedYear = DateTime.now().year;
  DateTime? _startDate;
  DateTime? _endDate;

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  void fetchData() async {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;
      if (user != null) {
        await context.read<AssignmentProvider>().fetchAssignment(user.id);
        final provider = context.read<AssignmentProvider>();

        setState(() {
          _allTaskAssignment = provider.assignment;
          _filteredTaskAssignment = provider.assignment;
        });
      }
    });
  }

  void _applyFilters() {
    setState(() {
      final taskAssignment = _allTaskAssignment;
      _filteredTaskAssignment = taskAssignment.where((w) {
        final created = DateTime.tryParse(w['assign_date']);
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

        return matchDate;
      }).toList();
    });
  }

  void _updateDateRange(DateTime? start, DateTime? end) {
    _startDate = start;
    _endDate = end;
    _applyFilters();
    setState(() {
      _startDate = start;
      _endDate = end;
    });
  }

  void _resetFilters() {
    setState(() {
      _startDate = null;
      _endDate = null;
    });
  }

  void _showReasonDialog(
    BuildContext context,
    List<int> taskIds,
    dynamic existingReason,
  ) {
    final alasanController = TextEditingController(
      text: existingReason?.toString() ?? "",
    );

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text(
            "Alasan tugas tidak dikerjakan?",
            style: TextStyle(fontSize: 20.sp),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TextField(
                controller: alasanController,
                enabled: existingReason ==
                    null, // <--- DISABLE jika sudah ada alasan
                decoration: InputDecoration(
                  hintText: "Masukkan alasan...",
                ),
                maxLines: 2,
              ),
            ],
          ),
          actions: [
            if (existingReason == null) ...[
              ElevatedButton(
                onPressed: () async {
                  final provider = Provider.of<TaskProvider>(
                    context,
                    listen: false,
                  );

                  bool success = await provider.updateReason(
                    taskIds,
                    alasanController.text,
                  );

                  Navigator.pop(context);
                },
                child: Text("Kirim"),
              ),
            ],
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return WillPopScope(
              onWillPop: () async {
                // Navigator.pushNamedAndRemoveUntil(
                //   context,
                //   RoutesNames.home,
                //   (route) => false,
                // ); // back to home first
                SystemNavigator.pop(); // auto close app
                return false;
              },
              child: Scaffold(
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
                    "Task Assignments",
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: AppDimens.fontTitle,
                    ),
                  ),
                  backgroundColor: AppColors.primary,
                  foregroundColor: AppColors.textLight,
                  elevation: 0,
                  centerTitle: true,
                ),
                body: Consumer<AssignmentProvider>(
                  builder: (context, provider, child) {
                    final assignments = provider.assignment;

                    final filteredTasks = assignments.where((att) {
                      final rawDate = att['assign_date'];
                      String? dateStr =
                          rawDate is Map ? rawDate['date'] : rawDate;

                      if (dateStr == null) return false;

                      DateTime? assignDate;
                      try {
                        assignDate = DateTime.parse(dateStr);
                      } catch (_) {
                        return false;
                      }

                      if (_startDate != null) {
                        final start = DateTime(_startDate!.year,
                            _startDate!.month, _startDate!.day);
                        if (assignDate.isBefore(start)) return false;
                      }

                      if (_endDate != null) {
                        final end = DateTime(
                            _endDate!.year, _endDate!.month, _endDate!.day);
                        if (assignDate.isAfter(end)) return false;
                      }

                      if (assignDate.month != selectedMonth) return false;
                      if (assignDate.year != selectedYear) return false;

                      return true;
                    }).toList();

                    final totalData = filteredTasks.length;
                    final totalPending = filteredTasks.where((att) {
                      final progress = att['progress'] ?? {};
                      return (progress['completed'] ?? 0) <
                          (progress['total'] ?? 0);
                    }).length;
                    final totalCompleted = filteredTasks.where((att) {
                      final progress = att['progress'] ?? {};
                      return (progress['completed'] ?? 0) ==
                          (progress['total'] ?? 0);
                    }).length;

                    return RefreshIndicator(
                        onRefresh: () async {
                          fetchData();
                        },
                        child: ListView(
                          children: [
                            DashboardHeader(
                              totalData: totalData,
                              leftData: totalPending,
                              rightData: totalCompleted,
                              leftLabel: "Progress",
                              rightLabel: "Complete",
                              iconTotalData: Icons.data_usage,
                              iconLeftData: Icons.pending_actions,
                              iconRightData: Icons.check_circle,
                            ),
                            SizedBox(height: 5.h),
                            Padding(
                              padding: EdgeInsets.symmetric(horizontal: 10.w),
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
                            Padding(
                              padding: EdgeInsets.only(
                                left: 10.w,
                                right: 10.w,
                                top: 10.h,
                                bottom: 10.h,
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: OutlineDropdown<int>(
                                      context: context,
                                      icon: Icons.calendar_month,
                                      value: selectedMonth,
                                      items: List.generate(12, (i) {
                                        final month = i + 1;
                                        return DropdownMenuItem(
                                          value: month,
                                          child: Text(
                                            DateFormat.MMMM()
                                                .format(DateTime(0, month)),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: AppDimens.fontBody),
                                          ),
                                        );
                                      }),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => selectedMonth = val);
                                        }
                                      },
                                    ),
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: OutlineDropdown<int>(
                                      context: context,
                                      icon: Icons.event,
                                      value: selectedYear,
                                      items: List.generate(5, (i) {
                                        final year =
                                            DateTime.now().year - 2 + i;
                                        return DropdownMenuItem(
                                          value: year,
                                          child: Text(
                                            year.toString(),
                                            overflow: TextOverflow.ellipsis,
                                            style: TextStyle(
                                                fontSize: AppDimens.fontBody),
                                          ),
                                        );
                                      }),
                                      onChanged: (val) {
                                        if (val != null) {
                                          setState(() => selectedYear = val);
                                        }
                                      },
                                    ),
                                  ),
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
                            filteredTasks.isEmpty
                                ? Padding(
                                    padding:
                                        EdgeInsets.symmetric(vertical: 40.h),
                                    child: Center(
                                      child: Text(
                                        "Tidak ada penugasan untuk periode ini",
                                        style: TextStyle(
                                          fontSize: 16.sp,
                                          color: AppColors.textSecondary,
                                        ),
                                      ),
                                    ),
                                  )
                                : ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    padding: EdgeInsets.all(16.w),
                                    itemCount: filteredTasks.length,
                                    itemBuilder: (context, index) {
                                      final att = filteredTasks[index];
                                      final progress = att['progress'] ?? {};
                                      final total = progress['total'] ?? 0;
                                      final completed =
                                          progress['completed'] ?? 0;
                                      final percent =
                                          total > 0 ? completed / total : 0.0;

                                      return InkWell(
                                        borderRadius:
                                            BorderRadius.circular(20.r),
                                        onTap: () {
                                          Navigator.pushNamed(
                                            context,
                                            RoutesNames.task,
                                            arguments: att['id'],
                                          );
                                        },
                                        child: Card(
                                          margin: EdgeInsets.only(bottom: 16.h),
                                          child: Padding(
                                            padding: EdgeInsets.all(16.w),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Row(
                                                      children: [
                                                        CircleAvatar(
                                                          radius: 20.r,
                                                          backgroundColor:
                                                              colorScheme
                                                                  .primary,
                                                          child: Icon(
                                                            Icons.person,
                                                            color: colorScheme
                                                                .onSecondary,
                                                            size: 20.sp,
                                                          ),
                                                        ),
                                                        SizedBox(width: 10.w),
                                                        Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              att['assignee'] ??
                                                                  '-',
                                                              style: TextStyle(
                                                                fontSize: AppDimens
                                                                    .fontHeading,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w700,
                                                              ),
                                                            ),
                                                            Text(
                                                              att['role'] ??
                                                                  'Manager Role',
                                                              style: TextStyle(
                                                                fontSize:
                                                                    AppDimens
                                                                        .fontBody,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                    CircularPercentIndicator(
                                                      radius: 26.r,
                                                      lineWidth: 4.w,
                                                      percent:
                                                          percent.clamp(0, 1),
                                                      backgroundColor:
                                                          Colors.grey.shade800,
                                                      progressColor:
                                                          colorScheme.secondary,
                                                      center: Text(
                                                        "${(percent * 100).toStringAsFixed(0)}%",
                                                        style: TextStyle(
                                                          fontSize: AppDimens
                                                              .fontBody,
                                                          fontWeight:
                                                              FontWeight.bold,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                SizedBox(height: 12.h),
                                                Divider(
                                                    color:
                                                        Colors.grey.shade800),
                                                InfoRow(
                                                    icon: Icons.location_on,
                                                    label: "Lokasi",
                                                    value: att['place'] ?? '-'),
                                                InfoRow(
                                                    icon: Icons.date_range,
                                                    label: "Tanggal",
                                                    value: att['assign_date']
                                                            is Map
                                                        ? (formatDateIndonesia(
                                                                att['assign_date']
                                                                    ['date']) ??
                                                            '-')
                                                        : (formatDateIndonesia(att[
                                                                'assign_date']) ??
                                                            '-')),
                                                InfoRow(
                                                    icon: Icons.assignment,
                                                    label: "Template",
                                                    value:
                                                        att['tasktemplate'] ??
                                                            '-'),
                                                SizedBox(height: 14.h),
                                                Text(
                                                  "Progress",
                                                  style: TextStyle(
                                                    fontSize: 14.sp,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                                ),
                                                SizedBox(height: 6.h),
                                                ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          8.r),
                                                  child:
                                                      LinearProgressIndicator(
                                                    value: percent,
                                                    minHeight: 8.h,
                                                    backgroundColor:
                                                        Colors.grey.shade800,
                                                    valueColor:
                                                        AlwaysStoppedAnimation<
                                                                Color>(
                                                            colorScheme
                                                                .primary),
                                                  ),
                                                ),
                                                SizedBox(height: 4.h),
                                                Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .spaceBetween,
                                                    children: [
                                                      if (att['sts'] != null &&
                                                          att['sts'] ==
                                                              "overdue") ...[
                                                        SizedBox(
                                                          height: 26.h,
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              _showReasonDialog(
                                                                context,
                                                                List<int>.from(att[
                                                                    'id_employee_task']),
                                                                att['sts_reason'],
                                                              );
                                                            },
                                                            style:
                                                                ElevatedButton
                                                                    .styleFrom(
                                                              backgroundColor:
                                                                  AppColors
                                                                      .myLightGreen,
                                                              foregroundColor:
                                                                  AppColors
                                                                      .textPrimary,
                                                              padding: EdgeInsets
                                                                  .symmetric(
                                                                      horizontal:
                                                                          8.w),
                                                              textStyle:
                                                                  TextStyle(
                                                                fontSize:
                                                                    AppDimens
                                                                        .fontBody,
                                                              ),
                                                              minimumSize:
                                                                  Size(0, 26.h),
                                                            ),
                                                            child: Row(
                                                              mainAxisSize:
                                                                  MainAxisSize
                                                                      .min,
                                                              children: [
                                                                Icon(
                                                                  Icons.info,
                                                                  size: 14.sp,
                                                                ),
                                                                SizedBox(
                                                                    width: 4.w),
                                                                Text(att['sts_reason'] !=
                                                                        null
                                                                    ? "Lihat Alasan"
                                                                    : "Input Alasan ${att['sts'] ?? '-'}"),
                                                              ],
                                                            ),
                                                          ),
                                                        )
                                                      ] else
                                                        SizedBox.shrink(),
                                                      Text(
                                                        "$completed / $total complete",
                                                        style: TextStyle(
                                                          fontSize: AppDimens
                                                              .fontBody,
                                                        ),
                                                      ),
                                                    ]),
                                              ],
                                            ),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ],
                        ));
                  },
                ),
              ));
        });
  }
}
