import 'package:flutter/material.dart';
import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/screens/profile/personal_information_screen.dart';
import 'package:internusa_group/screens/profile/settings_screen.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:provider/provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
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

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return DefaultTabController(
            length: 2,
            child: Scaffold(
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
                  'Profile Information',
                  style: TextStyle(
                      fontSize: AppDimens.fontTitle,
                      fontWeight: FontWeight.w600),
                ),
                bottom: const TabBar(
                  labelColor: AppColors.textLight,
                  unselectedLabelColor: Colors.white70,
                  tabs: [
                    Tab(text: 'Employee Information'),
                    Tab(text: 'Account Setting'),
                  ],
                ),
              ),
              body: const TabBarView(
                children: [
                  PersonalInformationScreen(),
                  SettingsScreen(),
                ],
              ),
            ),
          );
        });
  }
}
