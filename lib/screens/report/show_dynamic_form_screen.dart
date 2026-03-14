import 'dart:convert';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/models/dynamic_form_model.dart';

import 'package:internusa_group/utils/constans.dart';
import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/widgets/app_bottom_nav.dart';

class ShowDynamicFormScreen extends StatefulWidget {
  final DynamicFormResponse response;

  const ShowDynamicFormScreen({super.key, required this.response});

  @override
  State<ShowDynamicFormScreen> createState() => _ShowDynamicFormScreenState();
}

class _ShowDynamicFormScreenState extends State<ShowDynamicFormScreen> {
  int _selectedIndex = 0;

  final List<String> _imageExtensions = const [
    'jpg',
    'png',
    'jpeg',
    'gif',
    'webp',
    'svg'
  ];

  List<String>? _getImagePaths(String? value) {
    if (value == null || value.isEmpty) return null;

    try {
      final decoded = jsonDecode(value);

      if (decoded is List) {
        final List<String> validPaths = [];

        for (var path in decoded) {
          if (path is String && path.isNotEmpty) {
            final ext = path.split('.').last.toLowerCase();
            if (_imageExtensions.contains(ext)) {
              validPaths.add(path);
            }
          }
        }

        return validPaths.isNotEmpty ? validPaths : null;
      }
    } catch (_) {}

    final ext = value.split('.').last.toLowerCase();
    if (_imageExtensions.contains(ext)) {
      return [value];
    }

    return null;
  }

  Widget _buildValueWidget(
      BuildContext context, String? value, ThemeData theme) {
    final List<String>? imagePaths = _getImagePaths(value);
    if (imagePaths != null && imagePaths.isNotEmpty) {
      return GridView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: imagePaths.length,
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          crossAxisSpacing: 8.w,
          mainAxisSpacing: 8.h,
          childAspectRatio: 1,
        ),
        itemBuilder: (context, index) {
          final String path = imagePaths[index];
          final String fullUrl = path.startsWith('http') ? path : '$path';

          return GestureDetector(
            onTap: () => showImagePreview(context, fullUrl),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6.r),
              child: Image.network(
                fullUrl,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return Container(
                    color: Colors.grey.shade200,
                    child: const Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  );
                },
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    color: Colors.grey.shade300,
                    child: Center(
                      child: Text(
                        'Gagal',
                        style: theme.textTheme.bodySmall
                            ?.copyWith(color: AppColors.error),
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        },
      );
    }

    if (value == null || value.isEmpty) {
      return Text(
        '-',
        style:
            theme.textTheme.bodyMedium?.copyWith(fontSize: AppDimens.fontBody),
      );
    }

    String cleanValue = value.trim().replaceAll('[', '').replaceAll(']', '');

    List<String> items = cleanValue
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();

    if (items.isEmpty) {
      return Text(
        '-',
        style:
            theme.textTheme.bodyMedium?.copyWith(fontSize: AppDimens.fontBody),
      );
    }

    if (items.length == 1) {
      return Text(
        items.first,
        style:
            theme.textTheme.bodyMedium?.copyWith(fontSize: AppDimens.fontBody),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: items.asMap().entries.map((entry) {
        int index = entry.key + 1;
        String item = entry.value;

        return Text('$index. $item',
            style: TextStyle(fontSize: AppDimens.fontBody));
      }).toList(),
    );
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/index-dynamic-forms');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/select-dynamic-forms');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final response = widget.response;
    final dateFormat = DateFormat('MMM dd, yyyy HH:mm');

    final fotoItem = response.content.firstWhere(
      (e) {
        final n = e.fieldName.toLowerCase();
        return n.contains('foto') ||
            n.contains('image') ||
            n.contains('gbr1') ||
            n.contains('gambar');
      },
      orElse: () => FormContent(fieldName: '', value: null),
    );

    String? imageUrl;

    if (fotoItem.value != null && fotoItem.value!.isNotEmpty) {
      final List<String>? paths = _getImagePaths(fotoItem.value!);

      if (paths != null && paths.isNotEmpty) {
        final firstPath = paths.first;
        imageUrl = firstPath.startsWith('http') ? firstPath : '$firstPath';
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          response.formName,
          style: TextStyle(
              fontSize: AppDimens.fontTitle, fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColorDark,
      ),
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(theme, response),
            SizedBox(height: 16.h),
            Text(
              "Full Content",
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.fontBody,
              ),
            ),
            SizedBox(height: 10.h),
            ...response.content.map((item) {
              if (item.fieldName == 'map') return const SizedBox();

              return Container(
                margin: EdgeInsets.only(bottom: 8.h),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: theme.cardColor,
                  borderRadius: BorderRadius.circular(8.r),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            capitalizeFirst(
                                item.fieldName.replaceAll('_', ' ')),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontSize: AppDimens.fontBody,
                            ),
                          ),
                          SizedBox(height: 4.h),
                          _buildValueWidget(context, item.value, theme),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }).toList(),
            SizedBox(height: 12.h),
            Text(
              "Created At: ${dateFormat.format(response.createdAt)}",
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.hintColor,
                fontSize: AppDimens.fontCaption,
              ),
            ),
            SizedBox(height: 20.h),
          ],
        ),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildHeader(ThemeData theme, DynamicFormResponse response) {
    return Row(
      children: [
        CircleAvatar(
          radius: 25.r,
          backgroundColor: AppColors.primary.withOpacity(0.2),
          backgroundImage: NetworkImage(
            "${response.imgProfile}",
          ),
        ),
        SizedBox(width: 12.w),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              capitalizeFirst(response.userName),
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: AppDimens.fontTitle,
              ),
            ),
            Text(
              response.formName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.hintColor,
                fontSize: AppDimens.fontCaption,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
