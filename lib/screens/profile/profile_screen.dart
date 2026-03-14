import 'dart:io';
import 'package:flutter/material.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/user.dart';

import 'package:internusa_group/routes/namedroutes.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/utils/constans.dart';

import 'package:internusa_group/widgets/global_widget/chipbox.dart';

import 'package:internusa_group/providers/auth_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();
  File? _imageFile;
  String currentVersion = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<AuthProvider>().getCurrentUser();
      }
    });
    checkVersion();
  }

  Future<void> checkVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      currentVersion = packageInfo.version;
    });
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final colorSchemePrimary = colorScheme.primary;
    return WillPopScope(
        onWillPop: () async {
          // Navigator.pushNamedAndRemoveUntil(
          //   context,
          //   RoutesNames.home,
          //   (route) => false,
          // ); // back to home first
          SystemNavigator.pop(); // auto close app
          return false;
        },
        child: Scaffold(
          backgroundColor: Theme.of(context).colorScheme.surface.withAlpha(50),
          body: Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              if (authProvider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: AppColors.primary),
                );
              }

              final user = authProvider.currentUser;
              if (user == null) {
                return const Center(
                  child: Text(
                    'User tidak ditemukan',
                    style:
                        TextStyle(fontSize: 16, color: AppColors.textSecondary),
                  ),
                );
              }

              return SingleChildScrollView(
                child: Column(
                  children: [
                    _buildHeader(context, user, authProvider),
                    _buildMenuList(context, user, colorSchemePrimary),
                    SizedBox(height: 30.h),
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.phone_iphone,
                            size: 40.sp,
                          ),
                          SizedBox(width: 6.w),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Internusa App",
                                style: TextStyle(
                                  fontSize: AppDimens.fontHeading,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 4.h),
                              Text(
                                "Version ${currentVersion}",
                                style: TextStyle(
                                  fontSize: AppDimens.fontCaption,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    )
                  ],
                ),
              );
            },
          ),
        ));
  }

  Widget _buildHeader(BuildContext context, User user, AuthProvider auth) {
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return Container(
            width: double.infinity,
            height: 250.h,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: Theme.of(context).brightness == Brightness.dark
                    ? [AppColors.textSecondary, AppColors.textPrimary]
                    : colors,
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(30.r),
                bottomRight: Radius.circular(30.r),
              ),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => Dialog(
                            insetPadding: const EdgeInsets.all(16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(16),
                              child: InteractiveViewer(
                                panEnabled: true,
                                minScale: 1,
                                maxScale: 4,
                                child: Image(
                                  image: _buildAvatarImage(user),
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                          ),
                        );
                      },
                      child: CircleAvatar(
                        radius: 50.w,
                        backgroundColor:
                            Theme.of(context).colorScheme.surface.withAlpha(39),
                        backgroundImage: _buildAvatarImage(user),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: _buildCameraButton(auth),
                    ),
                  ],
                ),
                SizedBox(height: 10.h),
                Text(
                  capitalizeFirst(user.employee?.name ?? "-"),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Theme.of(context).colorScheme.onPrimary),
                  maxLines: 1,
                ),
                SizedBox(height: 5.h),
                Chipbox(title: user.employee?.position?.name ?? "-"),
              ],
            ),
          );
        });
  }

  ImageProvider _buildAvatarImage(User user) {
    if (user.picture != null && user.picture!.isNotEmpty) {
      return NetworkImage("${user.picture}");
    }
    final gender = user.employee?.gender;
    final fallback = gender == 'male' ? 'male.png' : 'female.png';
    return NetworkImage("$fallback");
  }

  Widget _buildCameraButton(AuthProvider auth) {
    return InkWell(
      onTap: () async {
        final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
        if (pickedFile != null) {
          setState(() {
            _imageFile = File(pickedFile.path);
          });

          try {
            await auth.updateProfilePicture(pickedFile.path);
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Foto profil berhasil diperbarui')),
            );
          } catch (e) {
            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Gagal update foto: $e')),
            );
          }
        }
      },
      child: Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Theme.of(context).colorScheme.surface.withAlpha(70),
        ),
        padding: EdgeInsets.all(6.w),
        child: Icon(
          Icons.camera_alt,
          color: AppColors.textLight,
          size: 20.w,
        ),
      ),
    );
  }

  Widget _buildMenuList(BuildContext context, User user, colorSchemePrimary) {
    final menuItems = [
      {
        'icon': Icons.person,
        'title': 'Personal Information',
        'route': '/edit-profile',
        'color': Theme.of(context).brightness == Brightness.dark
            ? AppColors.textLight
            : AppColors.textPrimary
      },
      {
        'icon': Icons.settings,
        'title': 'Settings',
        'route': '/settings-theme',
        'color': Theme.of(context).brightness == Brightness.dark
            ? AppColors.textLight
            : AppColors.textPrimary
      },
      {
        'icon': Icons.help_outline,
        'title': 'Help Center',
        'route': '/help',
        'color': Theme.of(context).brightness == Brightness.dark
            ? AppColors.textLight
            : AppColors.textPrimary
      },
      {
        'icon': Icons.logout,
        'title': 'Log Out',
        'route': '/logout',
        'color': colorSchemePrimary
      },
    ];

    return Padding(
      padding:
          EdgeInsets.symmetric(horizontal: AppDimens.padding, vertical: 20.r),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.textSecondary.withValues(alpha: 0.2)
              : AppColors.textLight,
          borderRadius: BorderRadius.circular(16.r),
          boxShadow: [
            BoxShadow(
              color: AppColors.textPrimary.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          children: List.generate(menuItems.length, (index) {
            final item = menuItems[index];
            final isLogout = item['title'] == 'Log Out';
            return Column(
              children: [
                InkWell(
                  borderRadius: BorderRadius.vertical(
                    top: index == 0 ? Radius.circular(16.r) : Radius.zero,
                    bottom: index == menuItems.length - 1
                        ? Radius.circular(16.r)
                        : Radius.zero,
                  ),
                  onTap: () {
                    if (item['route'] == '/logout') {
                      _showLogoutDialog(context);
                    } else if (item['route'] == RoutesNames.editProfile) {
                      Navigator.pushNamed(
                        context,
                        item['route'] as String,
                        arguments: user,
                      );
                    } else {
                      Navigator.pushNamed(context, item['route'] as String);
                    }
                  },
                  child: Padding(
                    padding: EdgeInsets.all(AppDimens.padding),
                    child: Row(
                      children: [
                        Icon(
                          item['icon'] as IconData,
                          size: AppDimens.fontBody,
                          color:
                              item['color'] as Color? ?? AppColors.textPrimary,
                        ),
                        SizedBox(width: 16.w),
                        Text(
                          item['title'] as String,
                          style: TextStyle(
                            fontSize: AppDimens.fontBody,
                            color: item['color'] as Color? ??
                                Theme.of(context).colorScheme.onSurface,
                            fontWeight:
                                isLogout ? FontWeight.w900 : FontWeight.normal,
                            letterSpacing: isLogout ? 0.3 : null,
                            fontFamily: isLogout ? 'Roboto' : null,
                          ),
                        ),
                        const Spacer(),
                        const Icon(Icons.chevron_right,
                            color: AppColors.textSecondary),
                      ],
                    ),
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(dialogContext).pop(),
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(dialogContext).pop();
                await context.read<AuthProvider>().logout();
                if (mounted) {
                  Navigator.of(context).pushReplacementNamed(RoutesNames.login);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.error,
                foregroundColor: AppColors.textLight,
              ),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}
