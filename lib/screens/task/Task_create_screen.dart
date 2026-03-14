import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/providers/task_provider.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/image_section.dart';

class TaskCreateScreen extends StatefulWidget {
  const TaskCreateScreen({super.key});

  @override
  State<TaskCreateScreen> createState() => _TaskCreateScreenState();
}

class _TaskCreateScreenState extends State<TaskCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  final contentController = TextEditingController();
  final reasonController = TextEditingController();
  final ImagePicker picker = ImagePicker();

  XFile? selectedImageBefore;
  XFile? selectedImageAfter;

  String? imageBeforeError;
  String? imageAfterError;

  bool isSubmitting = false;

  @override
  void dispose() {
    contentController.dispose();
    reasonController.dispose();
    super.dispose();
  }

  bool _validateImages() {
    setState(() {
      imageBeforeError =
          selectedImageBefore == null ? 'Gambar sebelum harus diunggah' : null;
      imageAfterError =
          selectedImageAfter == null ? 'Gambar sesudah harus diunggah' : null;
    });

    return imageBeforeError == null && imageAfterError == null;
  }

  Future<void> _submitReport() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_validateImages()) return;

    setState(() => isSubmitting = true);

    final provider = context.read<TaskProvider>();
    final task = provider.currentTask;

    if (task == null) {
      Navigator.pop(context, false);
      return;
    }

    try {
      await provider.createTaskReport(
        taskId: task.id,
        content: contentController.text.trim(),
        reasonNotCompleted: reasonController.text.trim().isEmpty
            ? null
            : reasonController.text.trim(),
        imageBefore: selectedImageBefore,
        imageAfter: selectedImageAfter,
      );

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Laporan berhasil ditambahkan!'),
            backgroundColor: AppColors.attendanceInArea,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      setState(() => isSubmitting = false);

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menambahkan laporan: ${e.toString()}'),
            backgroundColor: AppColors.myLightRed,
          ),
        );
      }
    }
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp)),
        SizedBox(height: 8.h),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8.r),
            ),
            contentPadding: EdgeInsets.all(16.w),
          ),
          validator: validator,
          maxLines: 4,
          minLines: 3,
        ),
      ],
    );
  }

  Widget _buildImageSection({
    required String title,
    required XFile? image,
    required Function(XFile?) onImageSelected,
    required String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14.sp),
        ),
        SizedBox(height: 8.h),
        if (image == null)
          ImageSection(
            selectedImage: image,
            picker: picker,
            onImagePicked: (img) {
              onImageSelected(img);
              setState(() {
                if (title.contains('Sebelum')) imageBeforeError = null;
                if (title.contains('Sesudah')) imageAfterError = null;
              });
            },
          ),
        if (image != null)
          Column(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10.r),
                child: Image.file(
                  File(image.path),
                  width: double.infinity,
                  height: 180.h,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(height: 8.h),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton.icon(
                  onPressed: () {
                    onImageSelected(null);
                    setState(() {});
                  },
                  icon: Icon(Icons.delete, color: AppColors.error),
                  label:
                      Text("Hapus", style: TextStyle(color: AppColors.error)),
                ),
              ),
            ],
          ),
        if (errorText != null)
          Padding(
            padding: EdgeInsets.only(top: 6.h, left: 4.w),
            child: Text(
              errorText,
              style: TextStyle(color: AppColors.myLightRed, fontSize: 12.sp),
            ),
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Buat Laporan',
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.bold),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(
                label: 'Isi Laporan',
                hint: 'Tuliskan progres atau temuan Anda...',
                controller: contentController,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Isi laporan tidak boleh kosong';
                  }
                  if (value.trim().length < 10) {
                    return 'Isi laporan minimal 10 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              _buildTextField(
                label: 'Alasan (jika tidak selesai)',
                hint: 'Jelaskan mengapa tugas belum selesai...',
                controller: reasonController,
                validator: (value) {
                  if (value != null &&
                      value.trim().isNotEmpty &&
                      value.trim().length < 5) {
                    return 'Alasan minimal 5 karakter';
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.h),
              _buildImageSection(
                title: 'Gambar Sebelum',
                image: selectedImageBefore,
                onImageSelected: (img) {
                  setState(() => selectedImageBefore = img);
                },
                errorText: imageBeforeError,
              ),
              SizedBox(height: 20.h),
              _buildImageSection(
                title: 'Gambar Sesudah',
                image: selectedImageAfter,
                onImageSelected: (img) {
                  setState(() => selectedImageAfter = img);
                },
                errorText: imageAfterError,
              ),
              SizedBox(height: 30.h),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isSubmitting ? null : _submitReport,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.background,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    padding:
                        EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                  child: isSubmitting
                      ? SizedBox(
                          width: 16.w,
                          height: 16.w,
                          child: const CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                                AppColors.background),
                          ),
                        )
                      : Text('Kirim', style: TextStyle(fontSize: 14.sp)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
