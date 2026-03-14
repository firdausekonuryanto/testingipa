import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:internusa_group/providers/app_notification_provider.dart';
import 'package:internusa_group/models/app_notification.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/utils/theme.dart';

enum NotificationFilter { unread, read }

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  NotificationFilter _filter = NotificationFilter.unread;

  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      context.read<AppNotificationProvider>().getNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppNotificationProvider>();

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        centerTitle: true,
        title: const Text("Notifications"),
      ),
      body: provider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                SizedBox(height: 12.h),
                _SegmentedControl(
                  selected: _filter,
                  onChanged: (value) {
                    setState(() => _filter = value);
                  },
                ),
                SizedBox(height: 16.h),
                Expanded(
                  child: _NotificationList(
                    filter: _filter,
                  ),
                ),
              ],
            ),
    );
  }
}

class _SegmentedControl extends StatelessWidget {
  final NotificationFilter selected;
  final ValueChanged<NotificationFilter> onChanged;

  const _SegmentedControl({
    required this.selected,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textPrimary
              : const Color.fromARGB(255, 222, 223, 228),
          borderRadius: BorderRadius.circular(30.r),
        ),
        child: Row(
          children: [
            _item("Unread", NotificationFilter.unread, context),
            _item("Read", NotificationFilter.read, context),
          ],
        ),
      ),
    );
  }

  Widget _item(String title, NotificationFilter value, BuildContext context) {
    final isSelected = selected == value;
    final colorScheme = Theme.of(context).colorScheme;

    IconData icon;

    if (value == NotificationFilter.unread) {
      icon = Icons.mark_email_unread;
    } else {
      icon = Icons.mark_email_read;
    }

    return Expanded(
      child: GestureDetector(
        onTap: () => onChanged(value),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          padding: EdgeInsets.symmetric(vertical: 10.h),
          decoration: BoxDecoration(
            color: isSelected
                ? colorScheme.primary
                : Theme.of(context).brightness == Brightness.dark
                    ? AppColors.textPrimary
                    : const Color.fromARGB(255, 222, 223, 228),
            borderRadius: BorderRadius.circular(30.r),
          ),
          child: Center(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  size: 18.sp,
                  color: isSelected
                      ? Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textPrimary
                          : AppColors.textLight
                      : Theme.of(context).brightness == Brightness.dark
                          ? AppColors.textLight
                          : AppColors.textPrimary,
                ),
                SizedBox(width: 6.w),
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: isSelected
                        ? Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textPrimary
                            : AppColors.textLight
                        : Theme.of(context).brightness == Brightness.dark
                            ? AppColors.textLight
                            : AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationList extends StatelessWidget {
  final NotificationFilter filter;

  const _NotificationList({required this.filter});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<AppNotificationProvider>();

    final notifications = provider.notifications
        .where(
            (e) => filter == NotificationFilter.unread ? !e.isRead : e.isRead)
        .toList();
    // print("check notifications : ");
    // print(notifications);
    if (notifications.isEmpty) {
      return const _EmptyState();
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => SizedBox(height: 14.h),
      itemBuilder: (_, index) {
        return _NotificationCard(item: notifications[index]);
      },
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_none,
            size: 60.sp,
            color: Theme.of(context).brightness == Brightness.dark
                ? Colors.white38
                : AppColors.textPrimary,
          ),
          SizedBox(height: 12.h),
          Text(
            "No notifications",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white38
                  : AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: 6.h),
          Text(
            "You're all caught up 🎉",
            style: TextStyle(
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white38
                  : AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<AppNotificationProvider>();
    final isRead = item.isRead;

    return InkWell(
      borderRadius: BorderRadius.circular(18.r),
      onTap: () async {
        if (!isRead) {
          await provider.markAsRead(item.id);
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textPrimary
              : AppColors.textLight,
          borderRadius: BorderRadius.circular(18.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildAvatar(context),
                SizedBox(width: 12.w),
                Expanded(
                  child: Text(
                    item.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  item.createdAt != null
                      ? DateFormat('HH:mm').format(item.createdAt!)
                      : '',
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            const Divider(),
            Text(
              item.message,
              style: const TextStyle(
                fontSize: 13,
              ),
            ),
            SizedBox(height: 4.h),
            if (item.createdAt != null)
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.schedule,
                    size: 14,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    DateFormat('dd MMM yyyy • HH:mm', 'id')
                        .format(item.createdAt!),
                    style: const TextStyle(
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildAvatar(BuildContext context) {
    String label = '';

    if (item.type == 'leave') {
      label = 'CTI';
    } else {
      label = capitalizeFirst(item.type);
    }

    return CircleAvatar(
      radius: 18.r,
      backgroundColor: Colors.blueAccent.withOpacity(0.2),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
      ),
    );
  }
}
