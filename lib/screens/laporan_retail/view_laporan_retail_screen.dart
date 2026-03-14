import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/customer.dart';

import 'package:internusa_group/utils/theme.dart';

import 'package:internusa_group/widgets/background_decoration.dart';
import 'package:internusa_group/widgets/tablerow.dart';

class ViewLaporanRetailScreen extends StatefulWidget {
  const ViewLaporanRetailScreen({super.key});

  @override
  State<ViewLaporanRetailScreen> createState() =>
      _ViewLaporanRetailScreenState();
}

class _ViewLaporanRetailScreenState extends State<ViewLaporanRetailScreen> {
  @override
  Widget build(BuildContext context) {
    final customer = ModalRoute.of(context)!.settings.arguments as Customer;
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
              title: Text("Detail Data", style: TextStyle(fontSize: 16.sp)),
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
                    _buildCustomerInfoCard(context, customer),
                    SizedBox(height: 16.h),
                    _buildProductDetailCard(customer),
                  ],
                ),
              ),
            ),
          );
        });
  }

  Widget _buildCustomerInfoCard(BuildContext context, Customer customer) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(Icons.person, "Informasi Pelanggan", context),
            SizedBox(height: 12.h),
            Table(
              columnWidths: const {
                0: IntrinsicColumnWidth(),
                1: FlexColumnWidth(),
              },
              border: TableBorder.all(
                color: Colors.grey.shade400,
                width: 1.w,
              ),
              children: [
                TableRowLabel.build("Tipe Laporan",
                    customer.purpose == 'psb' ? "Pasang Baru" : "Perbaikan"),
                TableRowLabel.build("Cabang", customer.branch?.name ?? "-"),
                TableRowLabel.build("Zona", customer.zone?.name ?? "-"),
                TableRowLabel.build("Pelanggan", customer.name),
                TableRowLabel.build("No HP", customer.phone),
                TableRowLabel.build("Alamat", customer.address),
                TableRowLabel.build("Latitude", customer.latitude),
                TableRowLabel.build("Longitude", customer.longitude),
                TableRowLabel.build("ODP ID", customer.odpId.toString()),
                TableRowLabel.build(
                  "Teknisi",
                  customer.technicians.isNotEmpty
                      ? customer.technicians.map((t) => t.name).join(", ")
                      : "-",
                ),
                TableRowLabel.build("Penginput", customer.userCreated),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductDetailCard(Customer customer) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16.r),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionTitle(Icons.shopping_bag, "Detail Produk", context),
            SizedBox(height: 12.h),
            Table(
              border: TableBorder.all(
                color: Colors.grey.shade400,
                width: 1.w,
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
                    _buildHeaderCell('No'),
                    _buildHeaderCell('Nama'),
                    _buildHeaderCell('SN Modem'),
                    _buildHeaderCell('Qty'),
                  ],
                ),
                if (customer.transactionProducts.isEmpty)
                  TableRow(
                    children: [
                      Padding(
                        padding: EdgeInsets.all(16.r),
                        child: Center(
                          child: Text("Tidak ada data produk",
                              style: TextStyle(fontSize: 12.sp)),
                        ),
                      ),
                      const SizedBox(),
                      const SizedBox(),
                      const SizedBox(),
                    ],
                  )
                else
                  ...customer.transactionProducts.asMap().entries.map(
                    (entry) {
                      final index = entry.key + 1;
                      final item = entry.value;
                      return TableRow(
                        children: [
                          _buildDataCell(index.toString(),
                              align: TextAlign.center),
                          _buildDataCell(item.productName),
                          _buildDataCell(item.snModem, align: TextAlign.center),
                          _buildDataCell(item.quantity.toString(),
                              align: TextAlign.center),
                        ],
                      );
                    },
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(IconData icon, String title, BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: AppColors.primary, size: 20.sp),
        SizedBox(width: 8.w),
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontSize: 14.sp,
                fontWeight: FontWeight.bold,
              ),
        ),
      ],
    );
  }

  Widget _buildHeaderCell(String text) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.bold),
      ),
    );
  }

  Widget _buildDataCell(String text, {TextAlign align = TextAlign.start}) {
    return Padding(
      padding: EdgeInsets.all(8.r),
      child: Text(text, textAlign: align, style: TextStyle(fontSize: 12.sp)),
    );
  }
}
