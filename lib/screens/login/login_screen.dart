import 'package:flutter/material.dart';
import 'package:internusa_group/widgets/btn/btn_global.dart';
import 'package:internusa_group/widgets/loading/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/input/input_form.dart';
import 'package:internusa_group/screens/login/widgets/weave_clipper.dart';
import 'package:internusa_group/routes/namedroutes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _loginController = TextEditingController();
  final _passwordController = TextEditingController();
  // bool _rememberMe = false;
  bool _showError = false;

  Future<void> _handleLogin() async {
    setState(() {
      _showError = true;
    });

    if (_loginController.text.isEmpty || _passwordController.text.isEmpty) {
      return;
    }

    final auth = context.read<AuthProvider>();
    final success = await auth.login(
      _loginController.text.trim(),
      _passwordController.text.trim(),
    );

    if (!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(context, RoutesNames.home);
    } else if (auth.error != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.warning_amber_rounded,
                color: AppColors.textPrimary,
              ),
              SizedBox(width: 10.w),
              Expanded(
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                    children: [
                      const TextSpan(text: "Upps.. "),
                      const TextSpan(
                        text: "Error Exception: ",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      TextSpan(
                        text: auth.error!,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.myLightRed,
          duration: const Duration(seconds: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppColors.textPrimary
          : AppColors.surface,
      body: Stack(
        children: [
          Positioned.fill(
              child: Theme.of(context).brightness == Brightness.dark
                  ? Image.asset(
                      'assets/images/bgdark.jpg',
                      fit: BoxFit.cover,
                    )
                  : Image.asset(
                      'assets/images/bg.png',
                      fit: BoxFit.cover,
                    )),
          SingleChildScrollView(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: MediaQuery.of(context).size.height,
              ),
              child: IntrinsicHeight(
                child: Column(
                  children: [
                    ClipPath(
                      clipper: WaveClipper(),
                      child: Container(
                        height: 250.h,
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(left: 24.w, top: 100.h),
                          child: Text(
                            "Sign in",
                            style: Theme.of(context)
                                .textTheme
                                .displayMedium
                                ?.copyWith(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.background
                                      : AppColors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.symmetric(horizontal: 24.w),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 20.h),
                            Text(
                              "Email",
                              style: TextStyle(
                                fontSize: AppDimens.fontMedium,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            InputForm(
                              controller: _loginController,
                              hintText: "Username / Email",
                              prefixIcon: Icons.email_outlined,
                              showError: _showError,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Masukkan Username / Email"
                                  : null,
                            ),
                            SizedBox(height: 20.h),
                            Text(
                              "Password",
                              style: TextStyle(
                                fontSize: AppDimens.fontMedium,
                                color: Theme.of(context).colorScheme.onSurface,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 8.h),
                            InputForm(
                              controller: _passwordController,
                              hintText: "Password",
                              isPassword: true,
                              prefixIcon: Icons.lock_outline,
                              showError: _showError,
                              validator: (v) => v == null || v.isEmpty
                                  ? "Masukkan Password"
                                  : null,
                            ),
                            SizedBox(height: 10.h),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    Navigator.pushNamed(
                                        context, RoutesNames.forgotPassword);
                                  },
                                  child: Text(
                                    "Forgot Password?",
                                    style: TextStyle(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .onSurface,
                                      fontWeight: FontWeight.w500,
                                      fontSize: AppDimens.fontXS,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            Consumer<AuthProvider>(
                              builder: (context, auth, child) {
                                if (auth.isLoading) {
                                  return const Center(child: LoadingWidget());
                                }
                                return BtnGlobal(
                                  icon: const Icon(Icons.send_rounded),
                                  onClick: () {
                                    _handleLogin();
                                  },
                                  title: "Login",
                                );
                              },
                            ),
                            SizedBox(height: 40.h),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
