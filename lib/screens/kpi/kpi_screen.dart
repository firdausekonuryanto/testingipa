import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/widgets/dashboard_header.dart';

import 'package:internusa_group/providers/kpi_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/widgets/card_kpi_report.dart';

class KpiScreen extends StatefulWidget {
  const KpiScreen({super.key});

  @override
  State<KpiScreen> createState() => _KpiScreenState();
}

class _KpiScreenState extends State<KpiScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      final user = auth.currentUser;
      if (user != null) {
        await context.read<KpiProvider>().fetchKpiList(user.id);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<KpiProvider>();
    final colorScheme = Theme.of(context).colorScheme;
    final listKpis = provider.listKpis;
    final isLoading = provider.isLoading;
    final error = provider.error;
    return ValueListenableBuilder<List<Color>>(
        valueListenable: AppColors.gradientNotifier,
        builder: (context, colors, _) {
          return Scaffold(
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
                  "Daftar KPI",
                  style: TextStyle(
                      fontSize: AppDimens.fontTitle,
                      fontWeight: FontWeight.bold),
                )),
            body: Container(
              decoration: BoxDecoration(
                image: Theme.of(context).brightness == Brightness.dark
                    ? null
                    : const DecorationImage(
                        image: AssetImage("assets/images/bg.png"),
                        fit: BoxFit.cover,
                      ),
              ),
              width: double.infinity,
              height: double.infinity,
              child: Builder(
                builder: (_) {
                  if (isLoading) {
                    return Center(
                      child:
                          CircularProgressIndicator(color: colorScheme.primary),
                    );
                  }

                  if (error != null) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.r),
                        child: Text(
                          error,
                          style: TextStyle(
                              fontSize: AppDimens.fontTitle, color: Colors.red),
                        ),
                      ),
                    );
                  }

                  if (listKpis.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40.r),
                        child: Text(
                          "Tidak ada data ditemukan.",
                          style: TextStyle(
                              fontSize: AppDimens.fontTitle,
                              color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        DashboardHeader(
                          totalData: listKpis.length,
                          leftData: null,
                          rightData: null,
                          leftLabel: "-",
                          rightLabel: "-",
                          iconTotalData: Icons.data_usage,
                          iconLeftData: Icons.calendar_month,
                          iconRightData: Icons.production_quantity_limits,
                        ),
                        ListView.builder(
                          itemCount: listKpis.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemBuilder: (context, index) {
                            final listKpi = listKpis[index];

                            return CardKpiReport(
                                listKpis: listKpi, index: index);
                          },
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
          );
        });
  }
}
