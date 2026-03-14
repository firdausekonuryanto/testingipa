import 'package:flutter/material.dart';
import 'package:internusa_group/screens/attendance/attendance_select_screen.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/screens/home/home_screen.dart';
import 'package:internusa_group/screens/profile/profile_screen.dart';
import 'package:internusa_group/screens/task/task_assign_screen.dart';
import 'package:internusa_group/screens/attendance/attendance_screen.dart';
import 'package:internusa_group/widgets/custom_nav_item.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const AttendanceSelectScreen(),
    const TaskAssignScreen(),
    const ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: Container(
        padding: EdgeInsets.symmetric(vertical: 10.h),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(20.r),
            topRight: Radius.circular(20.r),
          ),
          color: isDark ? AppColors.textPrimary : AppColors.textLight,
          boxShadow: [
            BoxShadow(
              color: AppColors.textSecondary.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            CustomNavItem(
              isActive: _currentIndex == 0,
              activeIcon: Icons.home_filled,
              inactiveIcon: Icons.home_outlined,
              label: "Home",
              onTap: () => setState(() => _currentIndex = 0),
            ),
            CustomNavItem(
              isActive: _currentIndex == 1,
              activeIcon: Icons.calendar_month,
              inactiveIcon: Icons.calendar_month_outlined,
              label: "Attendance",
              onTap: () => setState(() => _currentIndex = 1),
            ),
            CustomNavItem(
              isActive: _currentIndex == 2,
              activeIcon: Icons.task,
              inactiveIcon: Icons.task_outlined,
              label: "Task",
              onTap: () => setState(() => _currentIndex = 2),
            ),
            CustomNavItem(
              isActive: _currentIndex == 3,
              activeIcon: Icons.person,
              inactiveIcon: Icons.person_outline,
              label: "Profile",
              onTap: () => setState(() => _currentIndex = 3),
            ),
          ],
        ),
      ),
    );
  }
}
