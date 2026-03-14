import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/appbutton.dart';
import 'package:provider/provider.dart';
import 'package:internusa_group/providers/leave_provider.dart';
import 'package:image_picker/image_picker.dart';

class LeaveCreateScreen extends StatefulWidget {
  const LeaveCreateScreen({super.key});

  @override
  State<LeaveCreateScreen> createState() => _LeaveCreateScreenState();
}

class _LeaveCreateScreenState extends State<LeaveCreateScreen> {
  final _formKey = GlobalKey<FormState>();
  DateTimeRange? _selectedRange;
  String? _jenisCuti;
  final TextEditingController _alasanController = TextEditingController();

  final Map<String, String> _leaveTypes = {
    'annual': 'Tahunan',
    'sick': 'Sakit',
    'maternity': 'Melahirkan',
    'marriage': 'Menikah',
    'other': 'Lainnya',
  };
  File? _selectedFile;

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
      initialDateRange: _selectedRange,
      helpText: 'Pilih Rentang Tanggal Cuti',
      confirmText: 'PILIH',
      cancelText: 'BATAL',
    );
    if (picked != null) setState(() => _selectedRange = picked);
  }

  @override
  void dispose() {
    _alasanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
              title: Text("Tambah Pengajuan Cuti",
                  style: TextStyle(
                      fontSize: AppDimens.fontTitle,
                      fontWeight: FontWeight.bold)),
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            body: Padding(
              padding: EdgeInsets.all(16.w),
              child: _buildFormView(colors.last, context),
            ),
          );
        });
  }

  Widget _buildFormView(colors, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return Form(
      key: _formKey,
      child: ListView(
        children: [
          SizedBox(height: 8.h),
          FormField<DateTimeRange>(
            validator: (value) {
              if (_selectedRange == null) {
                return "Rentang tanggal wajib dipilih";
              }
              return null;
            },
            builder: (field) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: _pickDateRange,
                  child: Container(
                    padding:
                        EdgeInsets.symmetric(horizontal: 12.w, vertical: 12.h),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: field.hasError
                            ? Theme.of(context).brightness == Brightness.dark
                                ? AppColors.myLightRed
                                : Colors.red
                            : AppColors.textSecondary,
                      ),
                      borderRadius: BorderRadius.circular(8.r),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: AppDimens.fontBody,
                          color: colorScheme.primary,
                        ),
                        SizedBox(width: 10.w),
                        Expanded(
                          child: Text(
                            _selectedRange == null
                                ? "Pilih rentang tanggal"
                                : "${_selectedRange!.start.day}/${_selectedRange!.start.month}/${_selectedRange!.start.year} - "
                                    "${_selectedRange!.end.day}/${_selectedRange!.end.month}/${_selectedRange!.end.year}",
                            style: TextStyle(
                              fontSize: AppDimens.fontBody,
                              color: field.hasError
                                  ? (Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.myLightRed
                                      : Colors.red)
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyMedium!
                                      .color,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                if (field.hasError)
                  Padding(
                    padding: EdgeInsets.only(top: 4.h, left: 4.w),
                    child: Text(
                      field.errorText ?? '',
                      style: TextStyle(
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightRed
                              : Colors.red,
                          fontSize: 12.sp),
                    ),
                  ),
              ],
            ),
          ),
          SizedBox(height: 8.h),
          DropdownButtonFormField<String>(
            value: _jenisCuti,
            decoration: InputDecoration(
              labelText: "Pilih Jenis Cuti",
              prefixIcon: const Icon(Icons.work_history),
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            items: _leaveTypes.entries
                .map((entry) => DropdownMenuItem(
                      value: entry.key,
                      child: Text(entry.value),
                    ))
                .toList(),
            onChanged: (val) {
              setState(() {
                _jenisCuti = val;
              });
            },
            validator: (val) =>
                val == null || val.isEmpty ? "Jenis Cuti wajib dipilih" : null,
          ),
          SizedBox(height: 8.h),
          TextFormField(
            controller: _alasanController,
            maxLines: 3,
            decoration: InputDecoration(
              hintText: "Tulis alasan cuti",
              labelText: "Alasan Cuti",
              prefixIcon: const Icon(Icons.description),
              alignLabelWithHint: true,
              border:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(8.r)),
            ),
            validator: (val) =>
                val == null || val.isEmpty ? "Alasan wajib diisi" : null,
          ),
          if (_jenisCuti == "sick") ...[
            SizedBox(height: 16.h),
            Text("Upload Surat Dokter", style: TextStyle(fontSize: 14.sp)),
            SizedBox(height: 8.h),
            OutlinedButton.icon(
              onPressed: () async {
                final ImagePicker picker = ImagePicker();
                final XFile? pickedFile =
                    await picker.pickImage(source: ImageSource.gallery);

                if (pickedFile != null) {
                  setState(() {
                    _selectedFile = File(pickedFile.path);
                  });
                }
              },
              icon: const Icon(Icons.upload_file),
              label: const Text("Pilih File"),
            ),
            if (_selectedFile != null) ...[
              SizedBox(height: 8.h),
              Image.file(
                _selectedFile!,
                height: 120.h,
                fit: BoxFit.cover,
              ),
            ]
          ],
          SizedBox(height: 8.h),
          AppButton(
            label: "Ajukan",
            onPressed: _submitForm,
            icon: Icons.send,
          ),
        ],
      ),
    );
  }

  void _submitForm() {
    if (!_formKey.currentState!.validate() || _selectedRange == null) {
      return;
    }

    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.help_outline, color: AppColors.primary),
              SizedBox(width: 8),
              Text('Konfirmasi '),
            ],
          ),
          content: const Text('Apakah Anda yakin ingin mengajukan cuti ini?'),
          actions: <Widget>[
            TextButton(
              child: const Text('TIDAK'),
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
            ),
            TextButton(
              child: const Text('YA',
                  style: TextStyle(fontWeight: FontWeight.bold)),
              onPressed: () {
                Navigator.of(dialogContext).pop();
                _executeLeaveRequest(context);
              },
            ),
          ],
        );
      },
    );
  }

  void _executeLeaveRequest(BuildContext context) async {
    final String leaveType = _jenisCuti!;
    final String reason = _alasanController.text;
    final DateTime startDate = _selectedRange!.start;
    final DateTime endDate = _selectedRange!.end;

    if (leaveType == "sick" && _selectedFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Mohon upload surat dokter terlebih dahulu')),
      );
      return;
    }

    try {
      final leaveProv = Provider.of<LeaveProvider>(context, listen: false);

      await leaveProv.createLeave(
        leaveType: leaveType,
        reason: reason,
        startDate: startDate,
        endDate: endDate,
        imageFile: (leaveType == "sick") ? _selectedFile : null,
      );

      if (leaveProv.isSuccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Pengajuan cuti berhasil dikirim!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal: ${leaveProv.error ?? 'Terjadi kesalahan.'}'),
          ),
        );
        _alasanController.clear();
        setState(() {
          _selectedRange = null;
          _jenisCuti = null;
          _selectedFile = null;
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
