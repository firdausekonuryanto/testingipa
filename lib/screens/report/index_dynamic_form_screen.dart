import 'package:internusa_group/services/tokenmanager_service.dart';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/main.dart';
import 'package:provider/provider.dart';

import 'package:internusa_group/providers/dynamic_form_provider.dart';

import 'package:internusa_group/models/dynamic_form_model.dart';

import 'package:internusa_group/widgets/app_bottom_nav.dart';
import 'package:internusa_group/widgets/response_card.dart';

import 'package:internusa_group/utils/theme.dart';

class IndexDynamicFormScreen extends StatefulWidget {
  const IndexDynamicFormScreen({super.key});

  @override
  State<IndexDynamicFormScreen> createState() => _IndexDynamicFormScreenState();
}

class _IndexDynamicFormScreenState extends State<IndexDynamicFormScreen>
    with SingleTickerProviderStateMixin, RouteAware {
  int _selectedIndex = 0;
  int _userId = 0;
  String _searchKeyword = '';
  DateTimeRange? _selectedDateRange;
  String? _selectedFormNameFilter;
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  final DateFormat dateFormat = DateFormat('yyyy-MM-dd HH:mm');

  @override
  void initState() {
    super.initState();
    _loadUser();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _slideAnimation = Tween<Offset>(
      begin: Offset(0, 0.1.h),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );

    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.forward();
      _loadData();
    });
  }

  Future<void> _loadUser() async {
    final user = await Tokenmanager.getUser();
    final int userId = user?['id'];

    setState(() {
      _userId = userId;
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
    await Provider.of<DynamicFormProvider>(context, listen: false)
        .loadFormResponses();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/index-dynamic-forms');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/select-dynamic-forms');
    }
  }

  List<DynamicFormResponse> _filterResponses(DynamicFormProvider provider) {
    final keyword = _searchKeyword.toLowerCase();
    final formFilter = _selectedFormNameFilter;
    final range = _selectedDateRange;

    return provider.responses.where((response) {
      final matchKeyword = response.userName.toLowerCase().contains(keyword) ||
          response.formName.toLowerCase().contains(keyword) ||
          response.content.any((c) =>
              c.fieldName.toLowerCase().contains(keyword) ||
              (c.value?.toLowerCase().contains(keyword) ?? false));

      final matchForm = formFilter == null || response.formName == formFilter;

      final matchDate = range == null ||
          (response.createdAt
                  .isAfter(range.start.subtract(const Duration(days: 1))) &&
              response.createdAt
                  .isBefore(range.end.add(const Duration(days: 1))));

      return matchKeyword && matchForm && matchDate;
    }).toList();
  }

  Future<void> _pickDateRange() async {
    final now = DateTime.now();
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 1),
      initialDateRange: _selectedDateRange ??
          DateTimeRange(start: now.subtract(const Duration(days: 7)), end: now),
    );

    if (picked != null) setState(() => _selectedDateRange = picked);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = Theme.of(context).colorScheme;
    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "Semua Report",
          style: TextStyle(
              fontSize: AppDimens.fontTitle, fontWeight: FontWeight.bold),
        ),
        backgroundColor:
            theme.appBarTheme.backgroundColor ?? theme.primaryColorDark,
      ),
      body: Consumer<DynamicFormProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.responses.isEmpty) {
            return Center(
              child: Text(
                "Tidak Ada Report Ditemukan",
                style: TextStyle(fontSize: 14.sp),
              ),
            );
          }

          final uniqueFormNames = [
            "All Forms",
            ...provider.responses.map((r) => r.formName).toSet()
          ];

          final filteredResponses = _filterResponses(provider);
          return RefreshIndicator(
            onRefresh: _loadData,
            child: Column(
              children: [
                _buildSearchAndDateBar(theme, colorScheme.primary),
                if (_selectedDateRange != null) _buildDateRangeDisplay(theme),
                _buildFormFilterChips(theme, uniqueFormNames, context),
                Divider(height: 1.h),
                Expanded(
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: SlideTransition(
                      position: _slideAnimation,
                      child: ListView.builder(
                        padding: EdgeInsets.all(8.w),
                        itemCount: filteredResponses.length,
                        itemBuilder: (_, index) => ResponseCard(
                            response: filteredResponses[index],
                            userId: _userId),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }

  Widget _buildSearchAndDateBar(ThemeData theme, Color colorSchemePrimary) {
    return Padding(
      padding: EdgeInsets.all(8.w),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              onChanged: (val) => setState(() => _searchKeyword = val),
              style: TextStyle(fontSize: AppDimens.fontBody),
              decoration: InputDecoration(
                hintText: "Search by name, form, or field...",
                hintStyle: TextStyle(fontSize: AppDimens.fontBody),
                prefixIcon: Icon(Icons.search,
                    size: AppDimens.fontTitle, color: colorSchemePrimary),
                filled: true,
                fillColor: theme.cardColor,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.r),
                  borderSide: BorderSide.none,
                ),
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 10.w, vertical: 6.h),
              ),
            ),
          ),
          SizedBox(width: 8.w),
          IconButton(
            onPressed: _pickDateRange,
            icon: Icon(Icons.date_range, size: AppDimens.fontXL),
            color: colorSchemePrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeDisplay(ThemeData theme) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 12.w),
      child: Row(
        children: [
          Expanded(
            child: Text(
              "From ${dateFormat.format(_selectedDateRange!.start)} "
              "to ${dateFormat.format(_selectedDateRange!.end)}",
              style:
                  theme.textTheme.bodySmall?.copyWith(color: theme.hintColor),
            ),
          ),
          IconButton(
            onPressed: () => setState(() => _selectedDateRange = null),
            icon: Icon(Icons.close, size: 18.sp),
          ),
        ],
      ),
    );
  }

  Widget _buildFormFilterChips(
      ThemeData theme, List<String> formNames, BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      child: Row(
        children: formNames.map((formName) {
          final isSelected = _selectedFormNameFilter == formName ||
              (_selectedFormNameFilter == null && formName == "All Forms");

          return Padding(
            padding: EdgeInsets.only(right: 8.w),
            child: ChoiceChip(
              label: Text(
                formName,
                style: TextStyle(
                  fontSize: AppDimens.fontBody,
                  color: isSelected
                      ? colorScheme.onSecondary
                      : theme.textTheme.bodyMedium?.color,
                ),
              ),
              selected: isSelected,
              selectedColor: colorScheme.primary,
              onSelected: (_) => setState(() {
                _selectedFormNameFilter =
                    formName == "All Forms" ? null : formName;
              }),
            ),
          );
        }).toList(),
      ),
    );
  }
}
