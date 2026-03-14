import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/widgets/appbutton.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final user = context.read<AuthProvider>().currentUser;

    if (user != null) {
      _usernameController.text = user.username;
      _emailController.text = user.email;
    }
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
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
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  autovalidateMode: AutovalidateMode.onUserInteraction,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildEditableField(
                        "Username",
                        _usernameController,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Username is required";
                          }
                          return null;
                        },
                      ),
                      _buildEditableField(
                        "Email",
                        _emailController,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return "Email is required";
                          }
                          final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                          if (!emailRegex.hasMatch(value)) {
                            return "Invalid email format";
                          }
                          return null;
                        },
                      ),
                      _buildEditableField(
                        "Password",
                        _passwordController,
                        obscureText: true,
                        validator: (value) {
                          if (value != null &&
                              value.isNotEmpty &&
                              value.length < 6) {
                            return "Password must be at least 6 characters";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 30.h),
                      AppButton(
                        label: "Simpan Perubahan",
                        icon: Icons.save_rounded,
                        onPressed: () async {
                          if (!_formKey.currentState!.validate()) return;

                          final updatedUsername = _usernameController.text;
                          final updatedEmail = _emailController.text;
                          final updatedPassword = _passwordController.text;

                          final success = await context
                              .read<AuthProvider>()
                              .updateProfileAccount(
                                username: updatedUsername,
                                email: updatedEmail,
                                password: updatedPassword.isNotEmpty
                                    ? updatedPassword
                                    : null,
                              );

                          if (success && mounted) {
                            await context.read<AuthProvider>().logout();

                            if (!mounted) return;

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text(
                                      'Profile updated, please login again!')),
                            );

                            Navigator.pushNamedAndRemoveUntil(
                              context,
                              '/login',
                              (Route<dynamic> route) => false,
                            );
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Update failed!')),
                            );
                          }
                        },
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

  Widget _buildEditableField(
    String label,
    TextEditingController controller, {
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
    bool obscureText = false,
    String? Function(String?)? validator,
  }) {
    return FormField<String>(
      validator: validator,
      initialValue: controller.text,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      builder: (state) {
        final hasError = state.hasError;

        return Padding(
          padding: EdgeInsets.symmetric(vertical: 8.h),
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
              SizedBox(height: 4.h),
              TextFormField(
                controller: controller,
                keyboardType: keyboardType,
                maxLines: maxLines,
                obscureText: obscureText ? _obscurePassword : false,
                decoration: InputDecoration(
                  errorText: state.errorText,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: 12.h,
                    horizontal: 12.w,
                  ),
                  suffixIcon: obscureText
                      ? IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed: () {
                            setState(() {
                              _obscurePassword = !_obscurePassword;
                            });
                          },
                        )
                      : null,
                ),
                style: TextStyle(fontSize: AppDimens.fontBody),
                onChanged: (value) => state.didChange(value),
              ),
            ],
          ),
        );
      },
    );
  }
}
