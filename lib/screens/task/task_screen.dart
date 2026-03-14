import 'package:internusa_group/screens/task/widgets/info_row.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/providers/task_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/models/task.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/widgets/dashboard_header.dart';

import 'task_detail_screen.dart';

class TaskScreen extends StatefulWidget {
  final dynamic item;
  const TaskScreen({super.key, required this.item});

  @override
  State<TaskScreen> createState() => _TaskScreenState();
}

class _TaskScreenState extends State<TaskScreen> {
  String _keyword = "";
  int totalData = 0;
  int totalPending = 0;
  int totalComplated = 0;

  int _selectedMonth = DateTime.now().month;
  int _selectedYear = DateTime.now().year;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;
      if (user != null) {
        await context.read<TaskProvider>().fetchAllTasks();
        _applyFilters();
      }
    });
  }

  void _applyFilters() {
    final provider = context.read<TaskProvider>();
    final filteredTasks = provider.tasks.where((task) {
      if (task.assignDate == null) return false;
      final date = DateTime.tryParse(task.assignDate);
      if (date == null) return false;
      return date.month == _selectedMonth &&
          date.year == _selectedYear &&
          task.taskId == widget.item;
    }).toList();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        totalData = filteredTasks.length;
        totalPending =
            filteredTasks.where((task) => task.status == "pending").length;
        totalComplated =
            filteredTasks.where((task) => task.status == "complated").length;
      });
    });
  }

  void _updateKeyword(String value) {
    setState(() {
      _keyword = value;
    });
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'complated':
        return const Color(0xFF4CAF50);
      case 'pending':
        return const Color(0xFFFF9800);
      case 'overdue':
        return const Color(0xFFF44336);
      case 'in_review':
        return const Color(0xFF2196F3);
      default:
        return const Color(0xFF9E9E9E);
    }
  }

  String _formatStatusText(String status) {
    String correctedStatus =
        status.toLowerCase() == 'complated' ? 'completed' : status;
    return correctedStatus
        .split('_')
        .map((word) => word[0].toUpperCase() + word.substring(1).toLowerCase())
        .join(' ');
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
                'Tasks',
                style: TextStyle(
                    fontWeight: FontWeight.w600, fontSize: AppDimens.fontTitle),
              ),
              centerTitle: true,
              backgroundColor: colorScheme.primary,
              foregroundColor: Colors.white,
              elevation: 0,
            ),
            body: Consumer<TaskProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (provider.error != null) {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    provider.fetchAllTasks();
                  });
                  return Center(
                    child: Text(
                      "Terjadi error: ${provider.error}",
                      style: const TextStyle(color: Colors.red),
                    ),
                  );
                }

                final filteredTasks = provider.tasks.where((task) {
                  if (task.assignDate == null) return false;
                  final date = DateTime.tryParse(task.assignDate);
                  if (date == null) return false;

                  final matchMonth = date.month == _selectedMonth &&
                      date.year == _selectedYear &&
                      task.taskId == widget.item;

                  final matchKeyword = _keyword.isEmpty ||
                      task.taskName
                          .toLowerCase()
                          .contains(_keyword.toLowerCase()) ||
                      task.location
                          .toLowerCase()
                          .contains(_keyword.toLowerCase());

                  return matchMonth && matchKeyword;
                }).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    await provider.fetchAllTasks();
                    _applyFilters();
                  },
                  color: colorScheme.primary,
                  child: ListView(
                    padding: EdgeInsets.zero,
                    children: [
                      DashboardHeader(
                        totalData: filteredTasks.length,
                        leftData: totalPending,
                        rightData: totalComplated,
                        leftLabel: "Pending",
                        rightLabel: "Complate",
                        iconTotalData: Icons.data_usage,
                        iconLeftData: Icons.pending_actions,
                        iconRightData: Icons.check_circle,
                      ),
                      _buildFilterSection(provider),
                      _buildTaskList(filteredTasks, colorSchemePrimary),
                    ],
                  ),
                );
              },
            ),
          );
        });
  }

  Widget _buildFilterSection(TaskProvider provider) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          width: 0.5,
          color: Colors.grey.withValues(alpha: 0.5),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildFilterButton(
            icon: Icons.today,
            label: 'Today',
            isActive: provider.showTodayOnly,
            onPressed: () => provider.toggleTodayFilter(),
          ),
          _buildFilterButton(
            icon: Icons.filter_list,
            label: 'Status',
            isActive: provider.currentStatus != null,
            onPressed: () => _showStatusFilterDialog(context),
          ),
          _buildFilterButton(
            icon: Icons.clear,
            label: 'Clear',
            isActive: false,
            onPressed: () => provider.clearFilters(),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterButton({
    required IconData icon,
    required String label,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return InkWell(
      onTap: onPressed,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primary.withValues(alpha: 0.1) : null,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon,
                color: isActive ? AppColors.primary : Colors.grey[600],
                size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? AppColors.primary : Colors.grey[600],
                fontSize: 12,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaskList(List<Task> filteredTasks, Color colorSchemePrimary) {
    if (filteredTasks.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            children: [
              Icon(Icons.assignment_outlined,
                  size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No tasks found',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                      fontSize: AppDimens.fontBody,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                'Pull down to refresh or adjust your filters',
                style: TextStyle(
                    color: Colors.grey[500], fontSize: AppDimens.fontCaption),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: filteredTasks.length,
      itemBuilder: (context, index) {
        final task = filteredTasks[index];
        return _buildTaskCard(task, index, colorSchemePrimary);
      },
    );
  }

  Widget _buildTaskCard(Task task, int index, Color colorSchemePrimary) {
    final statusColor = _getStatusColor(task.status);
    return Card(
      margin: EdgeInsets.only(bottom: 12.h),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side:
            BorderSide(width: 0.5.w, color: Colors.grey.withValues(alpha: 0.5)),
      ),
      child: InkWell(
        onTap: () => _showTaskDetail(task),
        borderRadius: BorderRadius.circular(12.r),
        child: Padding(
          padding: EdgeInsets.all(16.w),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.taskName,
                          style: TextStyle(
                            fontSize: AppDimens.fontBody,
                            fontWeight: FontWeight.w600,
                            height: 1.3,
                          ),
                        ),
                      ),
                      SizedBox(width: 12.w),
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: 10.w,
                          vertical: 6.h,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20.r),
                          border: Border.all(
                            color: statusColor.withValues(alpha: 0.3),
                            width: 1.w,
                          ),
                        ),
                        child: Text(
                          _formatStatusText(task.status),
                          style: TextStyle(
                            color: statusColor,
                            fontSize: AppDimens.fontCaption,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  InfoRow(
                      icon: Icons.location_on,
                      label: "Lokasi",
                      value: task.location),
                  SizedBox(height: 4.h),
                  InfoRow(
                      icon: Icons.date_range,
                      label: "Tanggal",
                      value: formatDateIndonesia(task.assignDate)),
                ],
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Text(
                  '#${index + 1}',
                  style: TextStyle(
                    fontSize: AppDimens.fontHeading,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).brightness == Brightness.dark
                        ? AppColors.myLightYellow
                        : AppColors.textPrimary.withValues(alpha: 0.50),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showTaskDetail(Task task) async {
    try {
      final provider = context.read<TaskProvider>();
      provider.setCurrentTask(task);

      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const TaskDetailScreen(),
        ),
      );

      if (mounted) {
        provider.clearCurrentTask();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error opening task detail: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showStatusFilterDialog(BuildContext context) {
    final provider = context.read<TaskProvider>();
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Filter by Status',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildStatusTile('All', null, provider.currentStatus == null),
            _buildStatusTile(
                'Pending', 'pending', provider.currentStatus == 'pending'),
            _buildStatusTile('In Review', 'in_review',
                provider.currentStatus == 'in_review'),
            _buildStatusTile('Completed', 'complated',
                provider.currentStatus == 'complated'),
            _buildStatusTile(
                'Overdue', 'overdue', provider.currentStatus == 'overdue'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusTile(String title, String? value, bool isSelected) {
    return ListTile(
      title: Text(title),
      trailing:
          isSelected ? const Icon(Icons.check, color: AppColors.primary) : null,
      onTap: () {
        context.read<TaskProvider>().setStatusFilter(value);
        Navigator.pop(context);
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}
