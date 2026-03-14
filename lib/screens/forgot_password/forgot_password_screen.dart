import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/routes/namedroutes.dart';
import 'package:internusa_group/providers/reset_password_provider.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/btn/btn_global.dart';
import 'package:internusa_group/widgets/input/input_form.dart';

class ForgotPassowordScreen extends StatefulWidget {
  const ForgotPassowordScreen({super.key});

  @override
  State<ForgotPassowordScreen> createState() => _ForgotPassowordScreenState();
}

class _ForgotPassowordScreenState extends State<ForgotPassowordScreen> {
  final _emailcontroller = TextEditingController();
  bool _animate = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 100), () {
      setState(() => _animate = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedSlide(
          duration: const Duration(milliseconds: 500),
          curve: Curves.easeOut,
          offset: _animate ? const Offset(0, 0) : const Offset(-0.3, 0),
          child: AnimatedOpacity(
              duration: const Duration(milliseconds: 500),
              opacity: _animate ? 1 : 0,
              child: Stack(
                children: [
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimary
                              : AppColors.primary,
                          Theme.of(context).brightness == Brightness.dark
                              ? AppColors.textPrimary
                              : AppColors.primary.withValues(alpha: 0.05)
                        ],
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: 80.h,
                        ),
                        Padding(
                          padding: EdgeInsetsGeometry.all(AppDimens.padding),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Lottie.asset('assets/Loader.json'),
                              SizedBox(
                                height: 5.h,
                              ),
                              Text(
                                "Lupa Kata Sandi",
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineLarge
                                    ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                textAlign: TextAlign.start,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 340.h,
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: Container(
                      width: double.infinity,
                      height: double.infinity,
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.dark
                            ? const Color.fromARGB(255, 0, 0, 0)
                            : AppColors.background,
                        borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(24.r),
                          topRight: Radius.circular(24.r),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: EdgeInsets.all(AppDimens.padding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            SizedBox(height: 10.h),
                            Container(
                              padding: EdgeInsets.all(16.r),
                              decoration: BoxDecoration(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? AppColors.textPrimary
                                    : Colors.blue.withValues(alpha: 0.05),
                                borderRadius: BorderRadius.circular(12.r),
                                border: Border.all(
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? AppColors.textSecondary
                                      : Colors.blue.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Icon(
                                    Icons.info_outline,
                                    size: 26.sp,
                                    color:
                                        Theme.of(context).colorScheme.primary,
                                  ),
                                  SizedBox(width: 12.w),
                                  Expanded(
                                    child: Text(
                                      "Masukkan email Anda untuk mengatur ulang kata sandi. "
                                      "Kami akan mengirimkan link reset ke email Anda.",
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            color: Theme.of(context)
                                                .colorScheme
                                                .onSurface
                                                .withValues(alpha: 0.7),
                                            height: 1.4,
                                          ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            SizedBox(height: 20.h),
                            InputForm(
                              controller: _emailcontroller,
                              hintText: "Email",
                              prefixIcon: Icons.email_outlined,
                            ),
                            SizedBox(height: 20.h),
                            Consumer<SendEmailProvider>(
                              builder: (_, provider, __) {
                                return BtnGlobal(
                                  icon: provider.isLoading
                                      ? const Icon(Icons.hourglass_top_rounded)
                                      : const Icon(Icons.send_rounded),
                                  title: provider.isLoading
                                      ? "Mengirim..."
                                      : "Kirim Link Reset",
                                  onClick: provider.isLoading
                                      ? null
                                      : () {
                                          provider.sendResetLink(
                                            _emailcontroller.text.trim(),
                                          );
                                        },
                                );
                              },
                            ),
                            SizedBox(height: 20.h),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                    context, RoutesNames.login);
                              },
                              child: Text(
                                "Kembali ke halaman masuk?",
                                textAlign: TextAlign.center,
                                style: Theme.of(context)
                                    .textTheme
                                    .bodyMedium
                                    ?.copyWith(
                                      color:
                                          Theme.of(context).colorScheme.primary,
                                    ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ))),
    );
  }
}
