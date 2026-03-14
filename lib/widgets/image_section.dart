import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/theme.dart';

class ImageSection extends StatelessWidget {
  final XFile? selectedImage;
  final ImagePicker picker;
  final Function(XFile?) onImagePicked;

  const ImageSection({
    super.key,
    required this.selectedImage,
    required this.picker,
    required this.onImagePicked,
  });

  Future<void> _pickImage(ImageSource source, BuildContext context) async {
    try {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 80,
      );

      if (image != null) {
        onImagePicked(image);
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Gagal memilih gambar: ${e.toString()}',
            style: TextStyle(fontSize: 14.sp),
          ),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            // border: Border.all(color: Colors.grey[300]!),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Column(
            children: [
              if (selectedImage != null) ...[
                Container(
                  height: 150.h,
                  padding: EdgeInsets.all(8.w),
                  child: Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8.r),
                        child: Image.file(
                          File(selectedImage!.path),
                          width: double.infinity,
                          height: double.infinity,
                          fit: BoxFit.cover,
                        ),
                      ),
                      Positioned(
                        top: 8.h,
                        right: 8.w,
                        child: GestureDetector(
                          onTap: () => onImagePicked(null),
                          child: Container(
                            padding: EdgeInsets.all(4.w),
                            decoration: const BoxDecoration(
                              color: Colors.red,
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16.sp,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                Divider(height: 1.h),
              ],
              Padding(
                padding: EdgeInsets.all(5.w),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _pickImage(ImageSource.camera, context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.camera_alt, size: 28.sp),
                            SizedBox(height: 6.h),
                            Text("Camera", style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: 12.w),
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () =>
                            _pickImage(ImageSource.gallery, context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide.none,
                          foregroundColor: AppColors.primary,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.photo_library, size: 28.sp),
                            SizedBox(height: 6.h),
                            Text("Gallery", style: TextStyle(fontSize: 14.sp)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
