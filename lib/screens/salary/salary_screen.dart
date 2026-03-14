import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:internusa_group/providers/salary_provider.dart';

import 'package:internusa_group/models/salary.dart';

import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/widgets/card_salary_report.dart';
import 'package:internusa_group/widgets/account_summary_card.dart';

import 'package:internusa_group/utils/theme.dart';

class SalaryScreen extends StatefulWidget {
  const SalaryScreen({super.key});

  @override
  State<SalaryScreen> createState() => _SalaryScreenState();
}

class _SalaryScreenState extends State<SalaryScreen> {
  String profileImageUrl = '';

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;

      if (user != null) {
        await context.read<SalaryProvider>().fetchSalary(user.id);
      }
    });
  }

  Future<void> _refresh() async {
    final auth = context.read<AuthProvider>();
    final user = auth.currentUser;

    if (user != null) {
      await context.read<SalaryProvider>().fetchSalary(user.id);
    }
  }

  void _showSalaryDetail(BuildContext context, Salary salary) {
    final currency = NumberFormat.currency(
      locale: "id_ID",
      symbol: "Rp ",
      decimalDigits: 0,
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          insetPadding: EdgeInsets.symmetric(horizontal: 16.r),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.r)),
          title: const Text("Detail Gaji"),
          content: SizedBox(
            width: MediaQuery.of(context).size.width,
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Table(
                    columnWidths: const {
                      0: IntrinsicColumnWidth(),
                      1: FixedColumnWidth(12),
                      2: FlexColumnWidth(),
                    },
                    children: [
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Gaji Pokok")),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(":")),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            currency.format(
                                double.tryParse(salary.basicSalaryAmount) ?? 0),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Bonus")),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(":")),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            currency.format(double.tryParse(salary.bonus) ?? 0),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Potongan")),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(":")),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            currency
                                .format(double.tryParse(salary.deduction) ?? 0),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Tunjangan")),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(":")),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            currency
                                .format(double.tryParse(salary.allowance) ?? 0),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Total Gaji")),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(":")),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            currency.format(
                                double.tryParse(salary.totalSalary) ?? 0),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                      TableRow(children: [
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text("Created At")),
                        const Padding(
                            padding: EdgeInsets.symmetric(vertical: 4),
                            child: Text(":")),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Text(
                            DateFormat("dd MMM yyyy • HH:mm", "id_ID")
                                .format(DateTime.parse(salary.createdAt)),
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ]),
                    ],
                  ),
                  const Divider(),
                  if (salary.deductions.isNotEmpty) ...[
                    const Text(
                      "Detail Potongan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...salary.deductions.map(
                      (d) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(d.name)),
                            const Text(" : "),
                            Text(
                              currency.format(double.tryParse(d.amount) ?? 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 6.h),
                  ],
                  if (salary.allowances.isNotEmpty) ...[
                    const Text(
                      "Detail Tunjangan:",
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    ...salary.allowances.map(
                      (a) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 2),
                        child: Row(
                          children: [
                            Expanded(child: Text(a.name)),
                            const Text(" : "),
                            Text(
                              currency.format(double.tryParse(a.amount) ?? 0),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Close"),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final salaryProvider = context.watch<SalaryProvider>();
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final isLoading = salaryProvider.isLoading;
    final salaries = salaryProvider.salary;
    final error = salaryProvider.error;

    final sumTotalSalary = salaries.fold<double>(
      0,
      (prev, e) => prev + (double.tryParse(e.totalSalary) ?? 0),
    );
    final sumTotalAllowance = salaries.fold<double>(
      0,
      (prev, e) => prev + (double.tryParse(e.allowance) ?? 0),
    );
    final sumTotalDeduction = salaries.fold<double>(
      0,
      (prev, e) => prev + (double.tryParse(e.deduction) ?? 0),
    );
    profileImageUrl = (user?.picture != null && user!.picture!.isNotEmpty)
        ? user.picture!
        : user?.employee?.gender == "male"
            ? "male.png"
            : "female.png";

    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: Container(
          decoration: BoxDecoration(
            image: Theme.of(context).brightness == Brightness.dark
                ? null
                : const DecorationImage(
                    image: AssetImage("assets/images/bg.png"),
                    fit: BoxFit.cover,
                  ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AccountSummaryCard(
                name: user?.employee?.name ?? '-',
                company:
                    "${user?.employee?.position?.name ?? '—'} - ${user?.employee?.department?.name ?? 'Department'}",
                profileImageUrl: profileImageUrl,
                currentBalance: sumTotalSalary,
                allowance: sumTotalAllowance,
                deduction: sumTotalDeduction,
              ),
              SizedBox(height: 10.h),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                child: Text(
                  "Transactions History",
                  style: TextStyle(
                      fontSize: AppDimens.fontHeading,
                      fontWeight: FontWeight.bold),
                ),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.h),
                child: Row(
                  children: [
                    Icon(Icons.summarize,
                        size: AppDimens.fontBody,
                        color: Theme.of(context).brightness == Brightness.dark
                            ? AppColors.myLightYellow
                            : Colors.grey),
                    SizedBox(width: 6.w),
                    Text(
                      "Total ${salaries.length} Data",
                      style: TextStyle(
                          fontSize: AppDimens.fontCaption,
                          color: Theme.of(context).brightness == Brightness.dark
                              ? AppColors.myLightYellow
                              : Colors.grey),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : error != null
                        ? Center(child: Text("Terjadi kesalahan: $error"))
                        : salaries.isEmpty
                            ? const Center(child: Text("Tidak ada data gaji."))
                            : ListView.builder(
                                padding: EdgeInsets.all(12.r),
                                itemCount: salaries.length,
                                itemBuilder: (context, index) {
                                  final salary = salaries[index];
                                  return CardSalaryReport(
                                    salary: salary,
                                    index: index,
                                    onTapDetail: (salary) =>
                                        _showSalaryDetail(context, salary),
                                  );
                                },
                              ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
