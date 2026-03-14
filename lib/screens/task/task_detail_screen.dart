import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/providers/task_provider.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/widgets/info_row.dart';
import 'package:internusa_group/widgets/image_gallery.dart';
import 'package:internusa_group/widgets/loading/loading_state_widget.dart';
import 'package:internusa_group/widgets/empty_state_widget.dart';

class TaskDetailScreen extends StatefulWidget {
  const TaskDetailScreen({super.key});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _loadTaskReports();
      }
    });
  }

  Future<void> _loadTaskReports() async {
    final task = context.read<TaskProvider>().currentTask;
    if (task != null) {
      try {
        final provider = context.read<TaskProvider>();
        await provider.fetchTaskReports(task.id);
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load reports: ${e.toString()}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  Future<void> _onRefresh() async {
    await _loadTaskReports();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorSchemePrimary = colorScheme.primary;

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
                'Task Detail',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimens.fontTitle,
                ),
              ),
              elevation: 0,
              centerTitle: true,
            ),
            body: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final task = provider.currentTask;

                if (task == null) {
                  return const EmptyStateWidget(
                    icon: Icons.task_outlined,
                    title: 'No Task Selected',
                    subtitle: 'Please select a task to view details',
                  );
                }

                return RefreshIndicator(
                  key: _refreshIndicatorKey,
                  onRefresh: _onRefresh,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      _buildTaskInfoCard(task),
                      const SizedBox(height: 24),
                      _buildReportsSection(provider, context),
                    ],
                  ),
                );
              },
            ),
            floatingActionButton: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                final task = provider.currentTask;

                if (provider.isLoading) return const SizedBox.shrink();

                if (task == null || provider.taskReports.isNotEmpty) {
                  return const SizedBox.shrink();
                }

                return FloatingActionButton.extended(
                  onPressed: () async {
                    await Navigator.pushNamed(
                      context,
                      RoutesNames.createTask,
                    ).then((result) {
                      if (result == true) {
                        context.read<TaskProvider>().fetchAllTasks();
                      }
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Tambah Laporan'),
                );
              },
            ),
          );
        });
  }

  Widget _buildTaskInfoCard(dynamic task) {
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          width: 0.5,
          color: Colors.grey.withValues(alpha: 0.5),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: colorScheme.primary,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.task_alt,
                    color: colorScheme.onSecondary,
                    size: AppDimens.fontTitle,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.taskName,
                    style: TextStyle(
                      fontSize: AppDimens.fontTitle,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textLight
                          : Colors.black87,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16.h),
            InfoRow(
              icon: Icons.location_on_outlined,
              label: 'Lokasi',
              value: task.location,
              iconColor: Colors.blue,
            ),
            SizedBox(height: 8.h),
            InfoRow(
              icon: Icons.calendar_today_outlined,
              label: 'Tanggal',
              value: formatDateIndonesia(task.assignDate),
              iconColor: Colors.green,
            ),
            SizedBox(height: 8.h),
            InfoRow(
              icon: Icons.info_outline,
              label: 'Status',
              value: getStatusName(task.status),
              iconColor: getStatusColor(task.status),
            ),
            Card(
                child: Padding(
              padding: EdgeInsets.all(8),
              child: Html(
                data: task.taskDesc,
                style: {
                  "ul": Style(
                    fontSize: FontSize(AppDimens.fontBody),
                    lineHeight: LineHeight(1.5),
                    margin: Margins.zero,
                    padding: HtmlPaddings.zero,
                  ),
                  "li": Style(padding: HtmlPaddings.only(bottom: 6)),
                },
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _buildReportsSection(TaskProvider provider, BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Hasil Laporan',
              style: TextStyle(
                fontSize: AppDimens.fontTitle,
                fontWeight: FontWeight.bold,
              ),
            ),
            const Spacer(),
            if (provider.taskReports.isNotEmpty)
              Text(
                '${provider.taskReports.length} Laporan',
                style: TextStyle(
                  fontSize: AppDimens.fontCaption,
                  color: Theme.of(context).brightness == Brightness.dark
                      ? AppColors.myLightYellow
                      : Colors.grey[600],
                ),
              ),
          ],
        ),
        SizedBox(height: 16.h),
        if (provider.isLoading)
          const LoadingStateWidget()
        else if (provider.taskReports.isEmpty)
          _buildEmptyReportsState()
        else
          _buildReportsList(provider.taskReports, context),
      ],
    );
  }

  Widget _buildEmptyReportsState() {
    return const EmptyStateWidget(
      icon: Icons.report_outlined,
      title: 'Tidak Ada Laporan',
      subtitle: 'Tambahkan laporan dengan menekan tombol dibawah ini.',
    );
  }

  Widget _buildReportsList(List<dynamic> reports, BuildContext context) {
    return Column(
      children: reports.asMap().entries.map((entry) {
        final index = entry.key;
        final report = entry.value;
        return _buildReportCard(report, index, context);
      }).toList(),
    );
  }

  Widget _buildReportCard(dynamic report, int index, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final hasImages =
        report.images.before.isNotEmpty || report.images.after.isNotEmpty;
    final totalImages =
        report.images.before.length + report.images.after.length;
    return Card(
      elevation: 1,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
              color: Theme.of(context).brightness == Brightness.dark
                  ? AppColors.textSecondary
                  : Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: colorScheme.primary,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(8.r),
                        topRight: Radius.circular(8.r),
                      ),
                    ),
                    padding: EdgeInsets.all(12.r),
                    child: Row(
                      children: [
                        Icon(
                          Icons.description,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? colorScheme.onSecondary
                              : Colors.white,
                        ),
                        SizedBox(width: 8.w),
                        Text(
                          "Keterangan Laporan",
                          style: TextStyle(
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? colorScheme.onSecondary
                                    : Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: AppDimens.fontTitle,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(16.r),
                    child: Text(
                      report.content ?? '-',
                      style: TextStyle(fontSize: AppDimens.fontBody),
                    ),
                  ),
                ],
              ),
            ),
            if (report.reasonNotCompleted != null) ...[
              SizedBox(height: 8.h),
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
                color: Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textSecondary
                    : Colors.white,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            Color.fromARGB(255, 47, 127, 184),
                            Color.fromARGB(255, 2, 50, 99),
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(8.r),
                          topRight: Radius.circular(8.r),
                        ),
                      ),
                      padding: EdgeInsets.all(12.r),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.lightbulb,
                            color: Colors.white,
                          ),
                          SizedBox(width: 8.w),
                          const Text(
                            "Alasan",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.all(16.r),
                      child: Text(report.reasonNotCompleted ?? '-'),
                    ),
                  ],
                ),
              ),
            ],
            if (hasImages) ...[
              const SizedBox(height: 16),
              ImageGallery(
                  images: [...report.images.before, ...report.images.after]),
            ],
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 14,
                  color: Colors.grey[500],
                ),
                const SizedBox(width: 4),
                Text(
                  'dibuat: ${formatDateSlash(report.createdAt)}',
                  style: TextStyle(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.myLightYellow
                        : Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
                if (totalImages > 0) ...[
                  const Spacer(),
                  Icon(
                    Icons.image,
                    size: 14,
                    color: Colors.grey[500],
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$totalImages image${totalImages > 1 ? 's' : ''}',
                    style: TextStyle(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.myLightGreen
                          : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }
}
