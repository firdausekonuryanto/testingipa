import 'package:internusa_group/providers/dynamic_form_provider.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'dart:convert';
import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/models/dynamic_form_model.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:provider/provider.dart';

class ResponseCard extends StatelessWidget {
  final DynamicFormResponse response;
  final int userId;
  const ResponseCard({super.key, required this.response, required this.userId});

  void _showDeleteConfirmation(BuildContext context, dynamic response) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Konfirmasi Hapus",
              style: TextStyle(
                  fontSize: AppDimens.fontHeading,
                  fontWeight: FontWeight.bold)),
          content: Text(
              "Apakah Anda yakin ingin menghapus data ini secara permanen?",
              style: TextStyle(fontSize: AppDimens.fontBody)),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Batal", style: TextStyle(color: Colors.grey)),
            ),
            TextButton(
              onPressed: () async {
                Navigator.pop(context);

                final provider =
                    Provider.of<DynamicFormProvider>(context, listen: false);
                bool success = await provider.deleteResponse(response.id!);

                if (success) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Data berhasil dihapus")),
                  );
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content:
                            Text("Gagal menghapus: ${provider.errorMessage}")),
                  );
                }
              },
              child: const Text("Hapus",
                  style: TextStyle(
                      color: AppColors.myLightRed,
                      fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = response.content;

    final fotoItem = content.firstWhere(
      (e) {
        final n = e.fieldName.toLowerCase();
        return n.contains('foto') ||
            n.contains('image') ||
            n.contains('gbr') ||
            n.contains('gambar');
      },
      orElse: () => FormContent(fieldName: '', value: null),
    );

    String? imageUrl;

    if (fotoItem.value != null && fotoItem.value!.isNotEmpty) {
      try {
        final List<dynamic> imageList = jsonDecode(fotoItem.value!);

        if (imageList.isNotEmpty) {
          final String firstImagePath = imageList[0] as String;

          imageUrl = firstImagePath.startsWith('http')
              ? firstImagePath
              : '${AppConfig.baseImageUrl}$firstImagePath';
        }
      } catch (e) {
        print("Error decoding JSON string to List: $e");

        imageUrl = fotoItem.value!.startsWith('http')
            ? fotoItem.value!
            : '${AppConfig.baseImageUrl}${fotoItem.value!}';
      }
    }

    return Card(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
      elevation: 2,
      color: theme.cardColor,
      child: Padding(
        padding: EdgeInsets.all(12.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(context, theme),
            SizedBox(height: 12.h),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                    child:
                        _buildContentPreview(context, theme, content, userId)),
                SizedBox(width: 10.w),
                if (imageUrl != null)
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10.r),
                    child: Image.network(
                      imageUrl,
                      width: 90.w,
                      height: 90.w,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return SizedBox(
                          width: 90.w,
                          height: 90.w,
                          child: Center(
                            child: CircularProgressIndicator(
                              strokeWidth: 2.w,
                              value: progress.expectedTotalBytes != null
                                  ? progress.cumulativeBytesLoaded /
                                      (progress.expectedTotalBytes ?? 1)
                                  : null,
                            ),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stack) => Container(
                        width: 90.w,
                        height: 90.w,
                        color: Colors.grey[200],
                        child: Icon(Icons.broken_image,
                            size: 36.sp, color: Colors.grey),
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ThemeData theme) {
    final name = response.userName;
    final formName = response.formName;
    final imgProfile = response.imgProfile;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 20.r,
          backgroundColor: Colors.grey[300],
          backgroundImage: NetworkImage(
            "${imgProfile}",
          ),
        ),
        SizedBox(width: 10.w),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                capitalizeFirst(name),
                style: theme.textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: AppDimens.fontBody,
                ),
              ),
              Text(
                formName,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.hintColor,
                  fontSize: AppDimens.fontCaption,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContentPreview(BuildContext context, ThemeData theme,
      List<FormContent> content, userId) {
    final previewItems = content.where((i) => i.value != null).take(3).toList();
    final userIdResponse = userId;
    final formIdResponse = response.id;
    final IdResponse = response.id;
    final timeCreated = response.createdAt;
    final now = DateTime.now();

    final isToday = timeCreated.year == now.year &&
        timeCreated.month == now.month &&
        timeCreated.day == now.day;

    return Padding(
      padding: EdgeInsets.only(left: 4.w),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...previewItems.map((item) {
          //   return Padding(
          //     padding: EdgeInsets.only(bottom: 6.h),
          //     child: Text(
          //       "${item.fieldName.replaceAll('_', ' ')}: ${item.value}",
          //       style: theme.textTheme.bodyMedium
          //           ?.copyWith(fontSize: AppDimens.fontBody),
          //       maxLines: 10,
          //       overflow: TextOverflow.visible,
          //     ),
          //   );
          // }),
          if (previewItems.isNotEmpty)
            Padding(
              padding: EdgeInsets.only(bottom: 6.h),
              child: Text(
                "${previewItems[0].fieldName.replaceAll('_', ' ')}: ${previewItems[0].value}",
                style: theme.textTheme.bodyMedium
                    ?.copyWith(fontSize: AppDimens.fontBody),
                maxLines: 10,
                overflow: TextOverflow.visible,
              ),
            ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Created At : ${DateFormat('MMM dd, yyyy HH:mm').format(response.createdAt)}",
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.hintColor,
                  fontSize: AppDimens.fontCaption,
                ),
              ),
              SizedBox(height: 8.h),
              Row(mainAxisSize: MainAxisSize.min, children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      RoutesNames.showdynamicfrom,
                      arguments: {'response': response},
                    );
                  },
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark
                          ? AppColors.myLightYellow.withValues(alpha: 0.15)
                          : AppColors.primary.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(6.r),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.remove_red_eye_rounded,
                          size: 14.sp,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightYellow
                              : AppColors.textPrimary,
                        ),
                      ],
                    ),
                  ),
                ),
                if (userIdResponse == userId && isToday) ...[
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        RoutesNames.editdynamicfrom,
                        arguments: {'formId': formIdResponse, "id": IdResponse},
                      );
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.secondaryLight.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.edit,
                            size: 14.sp,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.secondaryLight
                                    : AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(width: 10.w),
                  GestureDetector(
                    onTap: () {
                      _showDeleteConfirmation(context, response);
                    },
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.myLightRed.withValues(alpha: 0.15)
                            : AppColors.primary.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(6.r),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.delete,
                            size: 14.sp,
                            color:
                                Theme.of(context).brightness == Brightness.dark
                                    ? AppColors.myLightRed
                                    : AppColors.textPrimary,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]
              ]),
            ],
          )
        ],
      ),
    );
  }
}
