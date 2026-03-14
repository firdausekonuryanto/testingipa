import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/appbutton.dart';

class PersonalInformationScreen extends StatefulWidget {
  const PersonalInformationScreen({super.key});

  @override
  State<PersonalInformationScreen> createState() =>
      _PersonalInformationScreenState();
}

class _PersonalInformationScreenState extends State<PersonalInformationScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().currentUser;
    if (user != null) {
      _nameController.text = user.employee?.name ?? "";
      _emailController.text = user.email;
      _phoneController.text = user.employee?.phone ?? "";
      _addressController.text = user.employee?.address ?? "";
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _validateAndSubmit() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final success = await context.read<AuthProvider>().updateProfile(
          name: _nameController.text.trim(),
          email: _emailController.text.trim(),
          phone: _phoneController.text.trim(),
          address: _addressController.text.trim(),
        );

    if (!mounted) return;

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile updated!")),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Update failed!")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Color>>(
      valueListenable: AppColors.gradientNotifier,
      builder: (context, colors, _) {
        return Scaffold(
          body: Consumer<AuthProvider>(
            builder: (context, auth, _) {
              return SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildInputField(
                        "Nama Lengkap",
                        _nameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Nama Lengkap Wajib Diisi !";
                          }
                          return null;
                        },
                      ),
                      _buildInputField(
                        "Email",
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email Wajib Diisi !";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return "Salah Format Pengisian email";
                          }
                          return null;
                        },
                      ),
                      _buildInputField(
                        "Telepon",
                        _phoneController,
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Nomor Telepon Wajib Diisi !";
                          }
                          final numberOnly = RegExp(r'^[0-9]+$');
                          if (!numberOnly.hasMatch(value)) {
                            return "Nomor Telepon Wajib Angka !";
                          }
                          if (value.length < 8) {
                            return "Nomor Telepon Kurang Dari 8 Digit !";
                          }
                          return null;
                        },
                      ),
                      _buildInputField(
                        "Alamat",
                        _addressController,
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Alamat Wajib Diisi !";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30.h),
                      AppButton(
                        label: "Simpan Perubahan",
                        icon: Icons.save_rounded,
                        onPressed: _validateAndSubmit,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildInputField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      initialValue: controller.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final bool hasError = state.hasError;

        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: hasError
                      ? Theme.of(context).brightness == Brightness.dark
                          ? AppColors.myLightRed
                          : AppColors.error
                      : Colors.grey[700],
                  fontWeight: FontWeight.w600,
                  fontSize: AppDimens.fontBody,
                ),
              ),
              const SizedBox(height: 4),
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                decoration: InputDecoration(
                  errorText: state.errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 12,
                    horizontal: 12,
                  ),
                ),
                style: TextStyle(fontSize: AppDimens.fontBody),
                onChanged: (value) {
                  state.didChange(value);
                },
              ),
            ],
          ),
        );
      },
    );
  }
}
