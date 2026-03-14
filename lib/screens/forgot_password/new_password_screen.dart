import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/btn/btn_global.dart';
import 'package:internusa_group/providers/reset_password_provider.dart';
import 'package:internusa_group/screens/forgot_password/widgets/password_field.dart';

class NewPasswordScreen extends StatefulWidget {
  final String email;
  final String token;

  const NewPasswordScreen({
    super.key,
    required this.email,
    required this.token,
  });

  @override
  State<NewPasswordScreen> createState() => _NewPasswordScreenState();
}

class _NewPasswordScreenState extends State<NewPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit(SendEmailProvider provider) async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await provider.resetPassword(
        email: widget.email,
        token: widget.token,
        password: _passwordController.text.trim(),
        confirmPassword: _confirmController.text.trim(),
      );

      if (provider.errorMessage == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Password berhasil direset')),
        );
        Navigator.of(context).popUntil((route) => route.isFirst);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage!)),
        );
      }
    } catch (e) {
      final msg = provider.errorMessage ?? e.toString();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Reset Password")),
      body: Padding(
        padding: EdgeInsets.all(16.r),
        child: Consumer<SendEmailProvider>(
          builder: (_, provider, __) {
            return Form(
              key: _formKey,
              child: ListView(
                children: [
                  SizedBox(height: 20.h),
                  Text(
                    "Masukkan password baru untuk akun ${widget.email}",
                    style: Theme.of(context)
                        .textTheme
                        .bodyMedium
                        ?.copyWith(fontSize: 14.sp),
                  ),
                  SizedBox(height: 24.h),
                  PasswordField(
                    controller: _passwordController,
                    label: "Password baru",
                    hint: "Masukkan password baru",
                    obscureText: _obscurePassword,
                    toggle: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Password wajib diisi';
                      }
                      if (v.trim().length < 6) {
                        return 'Password minimal 6 karakter';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 16.h),
                  PasswordField(
                    controller: _confirmController,
                    label: "Konfirmasi password",
                    hint: "Masukkan kembali password",
                    obscureText: _obscureConfirm,
                    toggle: () =>
                        setState(() => _obscureConfirm = !_obscureConfirm),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Konfirmasi password wajib diisi';
                      }
                      if (v.trim() != _passwordController.text.trim()) {
                        return 'Password tidak cocok';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 28.h),
                  BtnGlobal(
                    title:
                        provider.isLoading ? "Memproses..." : "Reset Password",
                    onClick:
                        provider.isLoading ? null : () => _submit(provider),
                  ),
                  if (provider.errorMessage != null) ...[
                    SizedBox(height: 12.h),
                    Text(
                      provider.errorMessage!,
                      style: TextStyle(color: AppColors.error, fontSize: 13.sp),
                    ),
                  ]
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
