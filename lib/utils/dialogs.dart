import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/providers/update_provider.dart';

class AppDialogs {
  static void showUpdateDialog({
    required BuildContext context,
    required String version,
    required String notes,
    required bool isMandatory,
    required VoidCallback onDownload,
  }) {
    showDialog(
      context: context,
      barrierDismissible: !isMandatory,
      builder: (_) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16.r)),
        titlePadding: EdgeInsets.fromLTRB(24.w, 20.h, 24.w, 8.h),
        contentPadding: EdgeInsets.fromLTRB(24.w, 0, 24.w, 20.h),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Update Tersedia ($version)',
              style: TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 6.h),
            const Divider(thickness: 0.5, color: Colors.grey, height: 0),
          ],
        ),
        content: Padding(
          padding: EdgeInsets.only(top: 2.h),
          child: SingleChildScrollView(
            child: Html(
              data: notes,
              style: {
                "ul": Style(
                  fontSize: FontSize(14.sp),
                  lineHeight: LineHeight(1.5),
                  margin: Margins.zero,
                  padding: HtmlPaddings.zero,
                ),
                "li": Style(padding: HtmlPaddings.only(bottom: 6)),
              },
            ),
          ),
        ),
        actionsAlignment: MainAxisAlignment.spaceBetween,
        actions: [
          if (!isMandatory)
            OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.schedule, size: 18),
              label: Text('Nanti', style: TextStyle(fontSize: 14.sp)),
              style: OutlinedButton.styleFrom(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                backgroundColor: AppColors.textSecondary,
                foregroundColor: AppColors.background,
                side: BorderSide.none,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8.r),
                ),
              ),
            ),
          OutlinedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              onDownload();
            },
            icon: const Icon(Icons.download_rounded, size: 18),
            label: Text('Download', style: TextStyle(fontSize: 14.sp)),
            style: OutlinedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.background,
              side: BorderSide.none,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.r),
              ),
            ),
          ),
        ],
      ),
    );
  }

  static void showDownloadProgressDialog({
    required BuildContext context,
    required double progress,
    required UpdateProvider progressNotifier,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => Selector<UpdateProvider, double>(
        selector: (context, provider) => provider.downloadProgress,
        builder: (context, value, _) {
          return AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.r),
            ),
            contentPadding: EdgeInsets.all(20.r),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Lottie.asset('assets/SandyLoading.json'),
                Text(
                  'Mengunduh File APK . . .',
                  textAlign: TextAlign.center,
                  style:
                      TextStyle(fontSize: 18.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 20.h),
                LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  borderRadius: BorderRadius.circular(4.r),
                  valueColor:
                      const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  backgroundColor: AppColors.background,
                ),
                SizedBox(height: 12.h),
                Text(
                  '${(value * 100).toStringAsFixed(0)}%',
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
