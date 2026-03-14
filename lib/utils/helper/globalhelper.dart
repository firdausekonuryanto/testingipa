import 'dart:io';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';

String formatDate(String date, String format) {
  try {
    final parsedDate = DateTime.parse(date);
    return DateFormat(format, "id_ID").format(parsedDate);
  } catch (e) {
    return date;
  }
}

String formatDateSlash(String dateString) {
  try {
    final date = DateTime.parse(dateString);
    return '${date.day}/${date.month}/${date.year} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  } catch (e) {
    return dateString;
  }
}

String formatDateIndonesia(String dateString) {
  try {
    final dateTime = DateTime.parse(dateString);
    final formatter = DateFormat('d MMMM yyyy', 'id');

    return formatter.format(dateTime);
  } catch (e) {
    return dateString;
  }
}

String formatTime(String? time) {
  if (time == null) return 'N/A';

  final parts = time.split(':');
  if (parts.length >= 2) {
    return '${parts[0]}:${parts[1]}';
  }
  return time;
}

String formatTime2(String? timeStr) {
  if (timeStr == null || timeStr.isEmpty) return "-";
  try {
    final parsed = DateFormat("HH:mm:ss").parse(timeStr);
    return DateFormat("HH:mm").format(parsed);
  } catch (e) {
    return timeStr;
  }
}

String getStatusName(String status) {
  switch (status.toLowerCase()) {
    case 'complated':
      return 'Completed';
    case 'in progress':
    case 'ongoing':
      return 'In Progress';
    case 'pending':
      return 'Pending';
    default:
      return 'Overdue';
  }
}

Color getStatusColor(String status) {
  switch (status.toLowerCase()) {
    case 'completed':
      return Colors.green;
    case 'in progress':
    case 'ongoing':
      return Colors.orange;
    case 'pending':
      return Colors.blue;
    default:
      return Colors.grey;
  }
}

Color getColorFromLevel(BuildContext context, String? color) {
  switch (color) {
    case "success":
      return AppColors.checkIn;
    case "primary":
      return AppColors.primary;
    case "info":
      return AppColors.myYellow;
    case "warning":
      return AppColors.myOrange;
    case "danger":
      return Theme.of(context).brightness == Brightness.dark
          ? AppColors.secondaryLight
          : AppColors.error;
    default:
      return AppColors.textSecondary;
  }
}

String formatToRupiah(num number) {
  final formatter = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );
  return formatter.format(number);
}

String capitalizeFirst(String s) {
  return s
      .split(' ')
      .map((word) =>
          word.isEmpty ? word : word[0].toUpperCase() + word.substring(1))
      .join(' ');
}

bool isImageFile(String path) {
  final ext = path.toLowerCase();
  return ext.endsWith('.jpg') ||
      ext.endsWith('.jpeg') ||
      ext.endsWith('.png') ||
      ext.endsWith('.webp');
}

void showImagePreview(BuildContext context, dynamic imageSource) {
  final theme = Theme.of(context);

  ImageProvider provider;

  if (imageSource is File) {
    provider = FileImage(imageSource);
  } else if (imageSource is String && imageSource.startsWith("/")) {
    provider = FileImage(File(imageSource));
  } else if (imageSource is String) {
    provider = NetworkImage(imageSource);
  } else {
    throw Exception("Unsupported image type");
  }

  showDialog(
    context: context,
    builder: (BuildContext dialogContext) {
      return Dialog(
        insetPadding: EdgeInsets.symmetric(horizontal: 40.w, vertical: 80.h),
        backgroundColor: theme.scaffoldBackgroundColor,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
        child: Stack(
          children: [
            Container(
              padding: EdgeInsets.all(16.r),
              child: InteractiveViewer(
                child: Image(
                  image: provider,
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) {
                    return Center(
                      child: Text(
                        'Gagal memuat gambar',
                        style: theme.textTheme.bodyMedium
                            ?.copyWith(color: AppColors.error),
                      ),
                    );
                  },
                ),
              ),
            ),
            Positioned(
              top: 0,
              right: 0,
              child: IconButton(
                icon: Icon(Icons.close, size: 24.sp),
                onPressed: () => Navigator.of(dialogContext).pop(),
              ),
            ),
          ],
        ),
      );
    },
  );
}
