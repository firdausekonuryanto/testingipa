import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/helper/globalhelper.dart';
import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/models/work_product.dart';

import 'package:internusa_group/widgets/tablerow.dart';
import 'package:internusa_group/widgets/background_decoration.dart';

class ViewLaporanOdpScreen extends StatefulWidget {
  const ViewLaporanOdpScreen({super.key});

  @override
  State<ViewLaporanOdpScreen> createState() => _ViewLaporanOdpScreenState();
}

class _ViewLaporanOdpScreenState extends State<ViewLaporanOdpScreen> {
  @override
  Widget build(BuildContext context) {
    final workproduct =
        ModalRoute.of(context)!.settings.arguments as WorkProducts;
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
                "Detail Data",
                style: TextStyle(fontSize: 16.sp),
              ),
              actions: [
                IconButton(
                  icon: Icon(Icons.close, size: 22.sp),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: BackgroundDecoration(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(16.r),
                child: Column(
                  children: [
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.person,
                                    color: AppColors.primary),
                                SizedBox(width: 8.w),
                                Text(
                                  'Informasi Laporan ODP / Bisnis',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Table(
                              columnWidths: const {
                                0: IntrinsicColumnWidth(),
                                1: FlexColumnWidth(),
                              },
                              border: TableBorder.all(
                                color: Colors.grey.shade400,
                              ),
                              children: [
                                TableRowLabel.build(
                                  "Tanggal Dibuat",
                                  formatDate(workproduct.createdAt ?? "-",
                                      "d MMMM yyyy"),
                                ),
                                TableRowLabel.build(
                                  "Nama Pekerjaan",
                                  workproduct.name,
                                ),
                                TableRowLabel.build(
                                  "Cabang",
                                  workproduct.transaction?.branch?.name ?? "-",
                                ),
                                TableRowLabel.build(
                                  "Teknisi Bertugas",
                                  (workproduct.transaction?.technicians
                                              .isNotEmpty ??
                                          false)
                                      ? workproduct.transaction!.technicians
                                          .map((tech) => tech.name)
                                          .toSet()
                                          .join(', ')
                                      : "-",
                                ),
                                TableRowLabel.build(
                                  "Dibuat Oleh",
                                  workproduct.transaction?.userName ?? "-",
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    SizedBox(height: 16.h),
                    Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.shopping_bag,
                                    color: AppColors.primary),
                                SizedBox(width: 8.w),
                                Text(
                                  'Detail Produk',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                              ],
                            ),
                            SizedBox(height: 12.h),
                            Table(
                              border: TableBorder.all(
                                color: Colors.grey.shade400,
                              ),
                              columnWidths: const <int, TableColumnWidth>{
                                0: FlexColumnWidth(15),
                                1: FlexColumnWidth(35),
                                2: FlexColumnWidth(30),
                                3: FlexColumnWidth(20),
                              },
                              children: [
                                TableRow(
                                  children: [
                                    Padding(
                                      padding: EdgeInsets.all(8.r),
                                      child: Text(
                                        'No',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.r),
                                      child: Text(
                                        'Nama',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.r),
                                      child: Text(
                                        'SN Model',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                    Padding(
                                      padding: EdgeInsets.all(8.r),
                                      child: Text(
                                        'Qty',
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12.sp),
                                      ),
                                    ),
                                  ],
                                ),
                                if (workproduct.transactionProducts.isEmpty)
                                  TableRow(
                                    children: [
                                      Padding(
                                        padding: EdgeInsets.all(16.r),
                                        child: Center(
                                          child: Text("Tidak ada data produk",
                                              style:
                                                  TextStyle(fontSize: 12.sp)),
                                        ),
                                      ),
                                      const SizedBox(),
                                      const SizedBox(),
                                      const SizedBox(),
                                    ],
                                  )
                                else
                                  ...workproduct.transactionProducts
                                      .asMap()
                                      .entries
                                      .map((entry) {
                                    final index = entry.key;
                                    final item = entry.value;

                                    return TableRow(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: Center(
                                            child: Text(
                                              (index + 1).toString(),
                                              style: TextStyle(fontSize: 12.sp),
                                            ),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: Text(item.productName,
                                              style:
                                                  TextStyle(fontSize: 12.sp)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: Center(
                                            child: Text(item.snModem ?? '-',
                                                style:
                                                    TextStyle(fontSize: 12.sp)),
                                          ),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: Center(
                                            child: Text(
                                                item.quantity.toString(),
                                                style:
                                                    TextStyle(fontSize: 12.sp)),
                                          ),
                                        ),
                                      ],
                                    );
                                  }),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        });
  }
}
