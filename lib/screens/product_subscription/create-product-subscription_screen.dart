import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/customer_Subscription.dart';
import 'package:internusa_group/models/product.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/providers/master_provider.dart';
import 'package:internusa_group/providers/product_subscription_provider.dart';

class CreateProductSubscriptionScreen extends StatefulWidget {
  const CreateProductSubscriptionScreen({super.key});

  @override
  State<CreateProductSubscriptionScreen> createState() =>
      _CreateProductSubscriptionScreenState();
}

class _CreateProductSubscriptionScreenState
    extends State<CreateProductSubscriptionScreen> {
  List<Product> _products = [];
  int? _selectedProductId;
  final nameController = TextEditingController();
  final phoneController = TextEditingController();
  final addressController = TextEditingController();
  final _serialNumberController = TextEditingController();
  final _subscriptionPackageController = TextEditingController();
  final _terminationReasonController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  File? _selectedImage;
  bool _isSubmitting = false;
  DropdownSearchState<CustomerSubscription>? dropdownState;

  @override
  void initState() {
    super.initState();
    Future.microtask(() async {
      final masterProvider =
          Provider.of<MasterProvider>(context, listen: false);
      await masterProvider.refreshAll();

      setState(() {
        _products = masterProvider.products;
      });
    });
  }

  @override
  void dispose() {
    _serialNumberController.dispose();
    _subscriptionPackageController.dispose();
    _terminationReasonController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => _selectedImage = File(picked.path));
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final userId = 1;
    final provider =
        Provider.of<ProductSubscriptionProvider>(context, listen: false);

    setState(() => _isSubmitting = true);

    try {
      await provider.createSubscription(
        productId: _selectedProductId!,
        name: nameController.text.trim(),
        phone: phoneController.text.trim(),
        address: addressController.text.trim(),
        userId: userId,
        serialNumber: _serialNumberController.text.trim(),
        subscriptionPackage: _subscriptionPackageController.text.trim(),
        terminationReason: _terminationReasonController.text.trim(),
        modemPhoto: _selectedImage,
      );

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Putus Langganan berhasil disimpan")),
      );
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Gagal membuat menyimpan Putus Langganan: $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final masterProvider = Provider.of<MasterProvider>(context);
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
                "Tambah Putus Langganan",
                style: TextStyle(fontSize: 16.sp),
              ),
              backgroundColor: AppColors.primary,
              elevation: 0,
            ),
            body: masterProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : Padding(
                    padding: EdgeInsets.all(16.w),
                    child: Form(
                      key: _formKey,
                      child: ListView(
                        children: [
                          SizedBox(height: 10.h),

                          /// PRODUCT DROPDOWN
                          DropdownButtonFormField<int>(
                            value: _selectedProductId,
                            items: _products
                                .map((p) => DropdownMenuItem<int>(
                                      value: p.id,
                                      child: Text(p.name),
                                    ))
                                .toList(),
                            onChanged: (val) =>
                                setState(() => _selectedProductId = val),
                            decoration: InputDecoration(
                              labelText: "Pilih Produk",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 12.w, vertical: 10.h),
                            ),
                            validator: (val) =>
                                val == null ? "Produk Wajib Dipilih" : null,
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(
                              labelText: "Nama Pelanggan",
                              border: OutlineInputBorder(),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nama Pelanggan wajib diisi';
                              } else if (value.length < 3) {
                                return 'Nama terlalu pendek (min. 3 karakter)';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            controller: phoneController,
                            decoration: const InputDecoration(
                              labelText: "Nomor HP",
                              border: OutlineInputBorder(),
                            ),
                            keyboardType: TextInputType.phone,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Nomor HP wajib diisi';
                              }
                              final phoneRegex = RegExp(r'^[0-9]{9,15}$');
                              if (!phoneRegex.hasMatch(value)) {
                                return 'Nomor HP tidak valid (hanya angka, 9–15 digit)';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),
                          TextFormField(
                            controller: addressController,
                            decoration:
                                const InputDecoration(labelText: "Alamat"),
                            maxLines: 3,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Alamat wajib diisi';
                              } else if (value.length < 5) {
                                return 'Alamat terlalu pendek (min. 5 karakter)';
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 10.h),

                          /// SERIAL NUMBER
                          TextFormField(
                            controller: _serialNumberController,
                            decoration: InputDecoration(
                              labelText: "Serial Number",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? "Serial Number Wajib Diisi"
                                : null,
                          ),
                          SizedBox(height: 10.h),

                          /// SUBSCRIPTION PACKAGE
                          TextFormField(
                            controller: _subscriptionPackageController,
                            decoration: InputDecoration(
                              labelText: "Paket Langganan",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            validator: (val) => val == null || val.isEmpty
                                ? "Paket Langganan Wajib Diisi"
                                : null,
                          ),
                          SizedBox(height: 10.h),

                          /// TERMINATION REASON
                          TextFormField(
                            controller: _terminationReasonController,
                            decoration: InputDecoration(
                              labelText: "Alasan Putus (opsional)",
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                              alignLabelWithHint: true,
                            ),
                            maxLines: 4,
                          ),
                          SizedBox(height: 10.h),

                          /// MODEM PHOTO
                          Row(
                            children: [
                              _selectedImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(8.r),
                                      child: Image.file(
                                        _selectedImage!,
                                        width: 80.w,
                                        height: 80.w,
                                        fit: BoxFit.cover,
                                      ),
                                    )
                                  : const Icon(Icons.image,
                                      size: 80, color: AppColors.textSecondary),
                              SizedBox(width: 12.w),
                              ElevatedButton.icon(
                                onPressed: _pickImage,
                                icon: const Icon(Icons.upload_file),
                                label: const Text("Pilih Foto Modem"),
                                style: ElevatedButton.styleFrom(),
                              ),
                            ],
                          ),
                          SizedBox(height: 20.h),

                          /// SUBMIT BUTTON
                          ElevatedButton.icon(
                            onPressed: _isSubmitting ? null : _submit,
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(vertical: 14.h),
                              backgroundColor: colors.last,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.r),
                              ),
                            ),
                            icon: _isSubmitting
                                ? SizedBox(
                                    width: 20.w,
                                    height: 20.w,
                                    child: const CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: AppColors.textLight,
                                    ),
                                  )
                                : const Icon(Icons.save,
                                    color: AppColors.textLight),
                            label: Text(
                              _isSubmitting ? "Menyimpan..." : "Simpan",
                              style: TextStyle(
                                fontSize: 16.sp,
                                color: AppColors.textLight,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          );
        });
  }
}
