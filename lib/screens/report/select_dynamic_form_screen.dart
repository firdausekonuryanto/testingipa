import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/routes/namedroutes.dart';
import 'package:provider/provider.dart';

import 'package:internusa_group/main.dart';
import 'package:internusa_group/providers/dynamic_form_provider.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/app_bottom_nav.dart';

class SelectDynamicFormScreen extends StatefulWidget {
  const SelectDynamicFormScreen({super.key});

  @override
  State<SelectDynamicFormScreen> createState() =>
      _SelectDynamicFormScreenState();
}

class _SelectDynamicFormScreenState extends State<SelectDynamicFormScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  int _selectedIndex = 1;

  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0.15, 0), end: Offset.zero).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _loadData();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    _controller.dispose();
    super.dispose();
  }

  @override
  void didPopNext() {
    _controller.reset();
    _controller.forward();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DynamicFormProvider>(context, listen: false);
    await provider.loadAllForms();
  }

  Future<void> _handleRefresh() async {
    _controller.reset();
    _controller.forward();

    await _loadData();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, RoutesNames.indexdynamicfrom);
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, RoutesNames.selectdynamicfrom);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DynamicFormProvider>(context);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Pilih Template Report",
          style: TextStyle(fontSize: 16.sp, fontWeight: FontWeight.w700),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColorDark,
      ),
      body: provider.isLoading && provider.allForms.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : provider.errorMessage != null
              ? Center(child: Text(provider.errorMessage!))
              : provider.allForms.isEmpty
                  ? RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: ListView(
                        physics: const AlwaysScrollableScrollPhysics(),
                        children: [
                          Center(
                            child: Padding(
                              padding: EdgeInsets.only(top: 200.h),
                              child: Text(
                                "Template belum disetting",
                                style: TextStyle(
                                  fontSize: 16.sp,
                                  color: Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ))
                  : RefreshIndicator(
                      onRefresh: _handleRefresh,
                      child: FadeTransition(
                        opacity: _fadeAnimation,
                        child: SlideTransition(
                          position: _slideAnimation,
                          child: GridView.builder(
                            padding: EdgeInsets.all(16.w),
                            itemCount: provider.allForms.length,
                            gridDelegate:
                                SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 12.h,
                              crossAxisSpacing: 12.w,
                              childAspectRatio: 0.75,
                            ),
                            itemBuilder: (context, index) {
                              final form = provider.allForms[index];
                              return GestureDetector(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    RoutesNames.createdynamicfrom,
                                    arguments: {'formId': form.id},
                                  );
                                },
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 200),
                                  padding: EdgeInsets.all(14.w),
                                  decoration: BoxDecoration(
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? AppColors.myLightYellow
                                            .withOpacity(0.1)
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(16.r),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.05),
                                        blurRadius: 8.r,
                                        offset: Offset(0, 4.h),
                                      ),
                                    ],
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        form.formName,
                                        style: TextStyle(
                                            fontSize: 14.sp,
                                            fontWeight: FontWeight.w800,
                                            color:
                                                Theme.of(context).brightness ==
                                                        Brightness.dark
                                                    ? AppColors.myLightGreen
                                                    : AppColors.textPrimary),
                                      ),
                                      Divider(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.myLightYellow
                                              : AppColors.textPrimary),
                                      Expanded(
                                        child: ListView.builder(
                                          itemCount: form.fields.take(3).length,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          itemBuilder: (context, i) {
                                            final field = form.fields[i];
                                            return Padding(
                                              padding:
                                                  EdgeInsets.only(bottom: 8.h),
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Text(
                                                    field.label,
                                                    style: TextStyle(
                                                      fontSize: 11.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                  SizedBox(height: 2.h),
                                                  Text(
                                                    "Please enter",
                                                    style: TextStyle(
                                                      color:
                                                          Colors.grey.shade500,
                                                      fontSize: 9.sp,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
                        ),
                      ),
                    ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
