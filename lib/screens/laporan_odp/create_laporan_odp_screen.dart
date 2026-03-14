import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/models/work_product.dart';

import 'package:internusa_group/providers/customerservice_provider.dart';
import 'package:internusa_group/providers/workproduct_provider.dart';
import 'package:internusa_group/providers/auth_provider.dart';

import 'package:internusa_group/utils/theme.dart';

class CreateLaporanOdpScreen extends StatefulWidget {
  const CreateLaporanOdpScreen({super.key});

  @override
  State<CreateLaporanOdpScreen> createState() => _CreateLaporanOdpScreenState();
}

class _CreateLaporanOdpScreenState extends State<CreateLaporanOdpScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> _branches = [];
  List<dynamic> _technicians = [];
  List<dynamic> _products = [];
  List<Map<String, dynamic>> itemIdList = [];
  List<WorkProducts> workproducts = [];
  List<Map<String, dynamic>> dataList = [];
  List<int> _selectedTechnicians = [];
  List<String> _selectedTechniciansName = [];
  final Map<String, bool> _productModemStatus = {};
  final Map<int, bool> _showSnFieldMap = {};
  int? _selectedBranchId;
  int? userID;

  final Map<String, String> purposes = {
    "psb": "Pasang Baru",
    "repair": "Perbaikan",
  };
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameWorkController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final auth = context.read<AuthProvider>();
      await auth.getCurrentUser();
      final user = auth.currentUser;
      if (user != null) {
        final data =
            await context.read<CustomerServiceProvider>().fetchFormData();
        setState(() {
          userID = user.id;
          _branches = List<Map<String, dynamic>>.from(data['branches'] ?? []);
          _technicians = data['technicians'] ?? [];
          _products = data['products'] ?? [];

          for (var product in _products) {
            _productModemStatus[product['id'].toString()] =
                product['is_modem'] == 1;
          }
        });

        await context.read<WorkproductProvider>().fetchWorkproducts(user.id);

        final provider = context.read<WorkproductProvider>();

        setState(() {
          workproducts = provider.workproducts;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
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
              title: const Text("Tambah Data"),
              actions: [
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                  padding: EdgeInsets.all(16.r),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        DropdownSearch<Map<String, dynamic>>(
                          items: _branches,
                          itemAsString: (branch) => branch["name"] ?? "",
                          selectedItem: _branches.firstWhere(
                            (b) => b["id"] == _selectedBranchId,
                            orElse: () => {},
                          ),
                          popupProps: PopupProps.menu(
                            showSearchBox: true,
                            searchFieldProps: TextFieldProps(
                              decoration: InputDecoration(
                                hintText: "Cari cabang...",
                                border: const OutlineInputBorder(),
                                contentPadding: EdgeInsets.symmetric(
                                    horizontal: 10.w, vertical: 8.h),
                              ),
                            ),
                          ),
                          dropdownDecoratorProps: const DropDownDecoratorProps(
                            dropdownSearchDecoration: InputDecoration(
                              labelText: "Pilih Cabang",
                              border: OutlineInputBorder(),
                            ),
                          ),
                          onChanged: (value) {
                            setState(() {
                              _selectedBranchId = value?["id"];
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return ' Cabang Wajib Dipilih';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        TextFormField(
                          controller: _nameWorkController,
                          decoration: const InputDecoration(
                            labelText: "Nama Pekerjaan",
                            alignLabelWithHint: true,
                            border: OutlineInputBorder(),
                          ),
                          minLines: 4,
                          maxLines: 4,
                          keyboardType: TextInputType.multiline,
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Nama Pekerjaan wajib diisi';
                            } else if (value.length < 10) {
                              return 'Nama Pekerjaan terlalu pendek (min. 10 karakter)';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        DropdownButtonFormField<String>(
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(
                              value: '',
                              child: SizedBox.shrink(),
                            ),
                          ],
                          onChanged: (_) {},
                          onTap: () async {
                            final List<int>? results = await showDialog(
                              context: context,
                              builder: (context) {
                                return AlertDialog(
                                  title: const Text("Pilih Technician"),
                                  content: StatefulBuilder(
                                    builder: (context, setStateSB) {
                                      return SingleChildScrollView(
                                        child: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          children: _technicians.map((tech) {
                                            return CheckboxListTile(
                                              value: _selectedTechnicians
                                                  .contains(tech['id']),
                                              title: Text(tech['name']),
                                              onChanged: (bool? checked) {
                                                setStateSB(() {
                                                  if (checked == true) {
                                                    _selectedTechnicians
                                                        .add(tech['id']);
                                                  } else {
                                                    _selectedTechnicians
                                                        .remove(tech['id']);
                                                  }
                                                });
                                              },
                                            );
                                          }).toList(),
                                        ),
                                      );
                                    },
                                  ),
                                  actions: [
                                    TextButton(
                                      onPressed: () {
                                        setState(() {
                                          _selectedTechniciansName =
                                              _selectedTechnicians
                                                  .map((id) =>
                                                      _technicians.firstWhere(
                                                              (t) => t['id'] == id,
                                                              orElse: () =>
                                                                  {})['name']
                                                          as String? ??
                                                      'Unknown')
                                                  .whereType<String>()
                                                  .toList();
                                        });
                                        Navigator.pop(
                                            context, _selectedTechnicians);
                                      },
                                      child: const Text("OK"),
                                    ),
                                  ],
                                );
                              },
                            );
                            if (results != null) {
                              setState(() {
                                _selectedTechnicians = List.from(results);
                              });
                            }
                          },
                          decoration: InputDecoration(
                            labelText: _selectedTechniciansName.isEmpty
                                ? "Pilih Teknisi"
                                : "Teknisi Terpilih (${_selectedTechniciansName.length})",
                            border: const OutlineInputBorder(),
                          ),
                          validator: (_) {
                            if (_selectedTechnicians.isEmpty) {
                              return 'Teknisi wajib dipilih';
                            }
                            return null;
                          },
                        ),
                        SizedBox(height: 16.h),
                        if (_selectedTechniciansName.isNotEmpty)
                          Padding(
                            padding: EdgeInsets.symmetric(vertical: 8.h),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text("Teknisi Terpilih:",
                                    style:
                                        TextStyle(fontWeight: FontWeight.bold)),
                                SizedBox(height: 4.h),
                                ..._selectedTechniciansName
                                    .asMap()
                                    .entries
                                    .map((entry) {
                                  return Text(
                                      "${entry.key + 1}. ${entry.value}");
                                }),
                              ],
                            ),
                          ),
                        SizedBox(height: 16.h),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text("Daftar Item",
                                style: TextStyle(fontWeight: FontWeight.bold)),
                            IconButton(
                              icon: const Icon(Icons.add),
                              onPressed: () {
                                setState(() {
                                  itemIdList.add({
                                    "product_id": null,
                                    "sn": "",
                                    "jumlah": 1,
                                  });
                                });
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 8.h),
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: <Widget>[
                            if (itemIdList.isNotEmpty)
                              Container(
                                margin: EdgeInsets.symmetric(horizontal: 4.w),
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                ),
                                child: Table(
                                  border: TableBorder.all(
                                    color: Colors.grey.shade400,
                                  ),
                                  columnWidths: const <int, TableColumnWidth>{
                                    0: FlexColumnWidth(35),
                                    1: FlexColumnWidth(35),
                                    2: FlexColumnWidth(15),
                                    3: FlexColumnWidth(15),
                                  },
                                  children: [
                                    TableRow(
                                      decoration: BoxDecoration(
                                          color: Theme.of(context).brightness ==
                                                  Brightness.dark
                                              ? AppColors.textPrimary
                                              : AppColors.surface),
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: const Text('Produk',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: const Text('SN Model',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: const Text('Qty',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                        Padding(
                                          padding: EdgeInsets.all(8.r),
                                          child: const Text('Aksi',
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold)),
                                        ),
                                      ],
                                    ),
                                    ...itemIdList.asMap().entries.map((entry) {
                                      final index = entry.key;
                                      final b = entry.value;

                                      return TableRow(
                                        children: [
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 0.h),
                                              child: DropdownButtonFormField<
                                                  String>(
                                                value:
                                                    b["product_id"]?.toString(),
                                                isDense: true,
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8.h,
                                                          horizontal: 4.w),
                                                  border: InputBorder.none,
                                                ),
                                                items: _products.map((p) {
                                                  return DropdownMenuItem<
                                                      String>(
                                                    value: p['id'].toString(),
                                                    child: Text(p['name'],
                                                        style: TextStyle(
                                                            color: Theme.of(context)
                                                                        .brightness ==
                                                                    Brightness
                                                                        .dark
                                                                ? AppColors
                                                                    .textLight
                                                                : Colors
                                                                    .black)),
                                                  );
                                                }).toList(),
                                                onChanged: (value) {
                                                  setState(() {
                                                    b["product_id"] =
                                                        int.tryParse(
                                                            value ?? '');
                                                    _showSnFieldMap[index] =
                                                        _productModemStatus[
                                                                value] ??
                                                            false;
                                                    if (!(_showSnFieldMap[
                                                            index] ??
                                                        false)) {
                                                      b["sn"] = null;
                                                    }
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 0.h),
                                              child:
                                                  (_showSnFieldMap[index] ??
                                                          false)
                                                      ? TextFormField(
                                                          initialValue:
                                                              b["sn"] ?? "",
                                                          style: TextStyle(
                                                              fontSize: 12.sp),
                                                          decoration:
                                                              InputDecoration(
                                                            isDense: true,
                                                            contentPadding:
                                                                EdgeInsets.symmetric(
                                                                    vertical:
                                                                        8.h,
                                                                    horizontal:
                                                                        4.w),
                                                            border: InputBorder
                                                                .none,
                                                            hintText:
                                                                "SN Modem",
                                                          ),
                                                          onChanged: (value) {
                                                            setState(() {
                                                              b["sn"] = value;
                                                            });
                                                          },
                                                        )
                                                      : const SizedBox.shrink(),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 4.w,
                                                  vertical: 0.h),
                                              child: TextFormField(
                                                initialValue:
                                                    b["jumlah"]?.toString() ??
                                                        "1",
                                                keyboardType:
                                                    TextInputType.number,
                                                style: const TextStyle(
                                                    fontSize: 12),
                                                decoration: InputDecoration(
                                                  isDense: true,
                                                  contentPadding:
                                                      EdgeInsets.symmetric(
                                                          vertical: 8.h,
                                                          horizontal: 4.w),
                                                  border: InputBorder.none,
                                                  hintText: "Jumlah",
                                                ),
                                                onChanged: (value) {
                                                  setState(() {
                                                    b["jumlah"] =
                                                        int.tryParse(value) ??
                                                            1;
                                                  });
                                                },
                                              ),
                                            ),
                                          ),
                                          TableCell(
                                            verticalAlignment:
                                                TableCellVerticalAlignment
                                                    .middle,
                                            child: IconButton(
                                              icon: const Icon(Icons.delete,
                                                  color: Colors.red),
                                              iconSize: 30,
                                              padding: EdgeInsets.zero,
                                              constraints:
                                                  const BoxConstraints(),
                                              onPressed: () {
                                                setState(() {
                                                  itemIdList.removeAt(index);
                                                  _showSnFieldMap.remove(index);
                                                });
                                              },
                                            ),
                                          ),
                                        ],
                                      );
                                    }),
                                  ],
                                ),
                              )
                            else
                              const Center(
                                  child: Text(
                                      "Tekan tombol + untuk menambah item")),
                          ],
                        ),
                      ],
                    ),
                  )),
            ),
            persistentFooterButtons: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Batal"),
              ),
              ElevatedButton(
                onPressed: () async {
                  try {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }
                    final newWorkProduct = WorkProducts(
                      branchId: _selectedBranchId ?? 0,
                      name: _nameWorkController.text,
                      itemId: itemIdList,
                      technician: _selectedTechnicians,
                    );
                    bool success = await context
                        .read<WorkproductProvider>()
                        .addWorkproduct(newWorkProduct, userID);
                    if (success) {
                      Navigator.pop(context, true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Laporan ODP / Bisnis  berhasil ditambahkan")),
                      );
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                            content: Text(
                                "Gagal menambahkan Laporan ODP / Bisnis ")),
                      );
                    }
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text("Error: $e")),
                    );
                  }
                },
                child: const Text("Simpan"),
              ),
            ],
          );
        });
  }
}
