import 'dart:convert';
import 'package:latlong2/latlong.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/providers/auth_provider.dart';
import 'package:internusa_group/providers/customerservice_provider.dart';

import 'package:internusa_group/models/customer.dart';

import 'package:internusa_group/utils/theme.dart';

class CreateLaporanRetailScreen extends StatefulWidget {
  const CreateLaporanRetailScreen({super.key});

  @override
  State<CreateLaporanRetailScreen> createState() =>
      _CreateLaporanRetailScreenState();
}

class _CreateLaporanRetailScreenState extends State<CreateLaporanRetailScreen> {
  bool isLoading = true;
  List<Map<String, dynamic>> _branches = [];
  List<Map<String, dynamic>> _zones = [];
  List<dynamic> _technicians = [];
  List<dynamic> _products = [];
  List<Customer> customers = [];
  List<Map<String, dynamic>> itemIdList = [];
  List<int> _selectedTechnicians = [];
  List<String> _selectedTechniciansName = [];
  LatLng? selectedLocation;
  final Map<String, bool> _productModemStatus = {};
  final Map<int, bool> _showSnFieldMap = {};
  int? userID;
  int? _selectedBranchId;
  int? _selectedZoneId;
  String? _selectedOdpId;
  String? _selectedPurpose;

  final Map<String, String> purposes = {
    "psb": "Pasang Baru",
    "repair": "Perbaikan",
  };

  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameCustomerController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _searchController = TextEditingController();

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
          _zones = List<Map<String, dynamic>>.from(data['zones'] ?? []);
          _technicians = data['technicians'] ?? [];
          _products = List<Map<String, dynamic>>.from(data['products'] ?? []);

          for (var product in _products) {
            _productModemStatus[product['id'].toString()] =
                product['is_modem'] == 1;
          }
        });

        await context.read<CustomerServiceProvider>().fetchCustomers(user.id);

        final provider = context.read<CustomerServiceProvider>();

        setState(() {
          customers = provider.customers;
        });
      }
    });
  }

  @override
  void dispose() {
    _nameCustomerController.dispose();
    _phoneController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  Future<Map<String, dynamic>?> searchPlace(String query) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?q=$query&format=json&limit=5');

    final response =
        await http.get(url, headers: {"User-Agent": "flutter_map_example"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data.isNotEmpty) {
        // Ambil hasil pertama
        final lat = double.parse(data[0]['lat']);
        final lon = double.parse(data[0]['lon']);
        final addressName = data[0]['display_name'];
        return {
          "lat": lat,
          "lon": lon,
          "address": addressName,
        };
      }
    }
    return null;
  }

  Future<String?> getAddressFromLatLng(double lat, double lon) async {
    final url = Uri.parse(
        'https://nominatim.openstreetmap.org/reverse?lat=$lat&lon=$lon&format=json');

    final response =
        await http.get(url, headers: {"User-Agent": "flutter_map_example"});

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data["display_name"];
    }
    return null;
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
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: "Tipe Laporan"),
                        value: _selectedPurpose,
                        items: purposes.entries.map((entry) {
                          return DropdownMenuItem<String>(
                            value: entry.key,
                            child: Text(entry.value),
                          );
                        }).toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedPurpose = value;
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Tipe Laporan Wajib Dipilih';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
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
                              border: OutlineInputBorder(),
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
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _nameCustomerController,
                        decoration:
                            const InputDecoration(labelText: "Nama Pelanggan"),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nama Pelanggan wajib diisi';
                          } else if (value.length < 3) {
                            return 'Nama terlalu pendek (min. 3 karakter)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      DropdownSearch<Map<String, dynamic>>(
                        items: _zones,
                        itemAsString: (zone) => zone["name"] ?? "",
                        selectedItem: _zones.firstWhere(
                          (b) => b["id"] == _selectedZoneId,
                          orElse: () => {},
                        ),
                        popupProps: PopupProps.menu(
                          showSearchBox: true,
                          searchFieldProps: TextFieldProps(
                            decoration: InputDecoration(
                              hintText: "Cari Zone...",
                              border: const OutlineInputBorder(),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: 10.w, vertical: 8.h),
                            ),
                          ),
                        ),
                        dropdownDecoratorProps: const DropDownDecoratorProps(
                          dropdownSearchDecoration: InputDecoration(
                            labelText: "Pilih Zone",
                            border: OutlineInputBorder(),
                          ),
                        ),
                        onChanged: (value) {
                          setState(() {
                            _selectedZoneId = value?["id"];
                          });
                        },
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Zona Wajib Dipilih';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      DropdownButtonFormField<String>(
                        decoration:
                            const InputDecoration(labelText: "Pilih ODP"),
                        value: _selectedOdpId,
                        items: ["Option 1", "Option 2"]
                            .map((c) =>
                                DropdownMenuItem(value: c, child: Text(c)))
                            .toList(),
                        onChanged: (v) => setState(() => _selectedOdpId = v),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'ODP Wajib Dipilih';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _phoneController,
                        decoration: const InputDecoration(labelText: "No HP"),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Nomor HP wajib diisi';
                          }
                          final phoneRegex = RegExp(r'^[0-9]{9,15}$');
                          if (!phoneRegex.hasMatch(value)) {
                            return 'Nomor HP tidak valid (hanya angka, 9–15 digit)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          labelText: "Cari alamat...",
                          suffixIcon: IconButton(
                            icon: const Icon(Icons.search),
                            onPressed: () async {
                              final query = _searchController.text;
                              if (query.isNotEmpty) {
                                final result = await searchPlace(query);
                                if (result != null) {
                                  setState(() {
                                    selectedLocation = LatLng(
                                      double.parse(result["lat"].toString()),
                                      double.parse(result["lon"].toString()),
                                    );

                                    _latitudeController.text =
                                        result["lat"].toStringAsFixed(6);
                                    _longitudeController.text =
                                        result["lon"].toStringAsFixed(6);
                                    _addressController.text = result["address"];
                                  });
                                }
                              }
                            },
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _latitudeController,
                        decoration:
                            const InputDecoration(labelText: "Latitude"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Latitude wajib diisi';
                          }
                          final latitude = double.tryParse(value);
                          if (latitude == null ||
                              latitude < -90 ||
                              latitude > 90) {
                            return 'Latitude harus antara -90 dan 90';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 8.h),
                      TextFormField(
                        controller: _longitudeController,
                        decoration:
                            const InputDecoration(labelText: "Longitude"),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Longitude wajib diisi';
                          }
                          final longitude = double.tryParse(value);
                          if (longitude == null ||
                              longitude < -180 ||
                              longitude > 180) {
                            return 'Longitude harus antara -180 dan 180';
                          }
                          return null;
                        },
                        keyboardType: TextInputType.number,
                      ),
                      SizedBox(height: 8.h),
                      SizedBox(
                        height: 300.h,
                        child: FlutterMap(
                          options: MapOptions(
                            initialCenter: selectedLocation ??
                                LatLng(-8.240626619492808, 114.35510709912761),
                            initialZoom: 13,
                            onTap: (tapPos, latlng) async {
                              setState(() {
                                selectedLocation = latlng;
                                _latitudeController.text =
                                    latlng.latitude.toStringAsFixed(6);
                                _longitudeController.text =
                                    latlng.longitude.toStringAsFixed(6);
                              });
                              final address = await getAddressFromLatLng(
                                latlng.latitude,
                                latlng.longitude,
                              );

                              if (address != null) {
                                setState(() {
                                  _addressController.text = address;
                                });
                              }
                            },
                          ),
                          children: [
                            TileLayer(
                              urlTemplate:
                                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            ),
                            if (selectedLocation != null)
                              MarkerLayer(
                                markers: [
                                  Marker(
                                    point: selectedLocation!,
                                    width: 40.w,
                                    height: 40.h,
                                    child: Icon(
                                      Icons.location_pin,
                                      color: Colors.red,
                                      size: 40.sp,
                                    ),
                                  ),
                                ],
                              ),
                          ],
                        ),
                      ),
                      SizedBox(height: 5.h),
                      TextFormField(
                        controller: _addressController,
                        decoration: const InputDecoration(labelText: "Alamat"),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Alamat wajib diisi';
                          } else if (value.length < 5) {
                            return 'Alamat terlalu pendek (min. 5 karakter)';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 5.h),
                      DropdownButtonFormField<String>(
                        isExpanded: true,
                        value: _selectedTechniciansName.isEmpty
                            ? null
                            : 'selected',
                        items: const [
                          DropdownMenuItem(
                            value: 'selected',
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
                                                      orElse: () => {},
                                                    )['name'] as String? ??
                                                    'Unknown')
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
                      SizedBox(height: 10.h),
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
                                return Text("${entry.key + 1}. ${entry.value}");
                              }),
                            ],
                          ),
                        ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text("Daftar Item"),
                          IconButton(
                            icon: const Icon(Icons.add),
                            onPressed: () {
                              setState(() {
                                itemIdList.add({
                                  "product_id": null,
                                  "sn": null,
                                  "jumlah": 1,
                                });
                              });
                            },
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          if (itemIdList.isNotEmpty)
                            Container(
                              margin: EdgeInsets.all(3.r),
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
                                  // Header Row
                                  TableRow(
                                    decoration: BoxDecoration(
                                        color: Theme.of(context).brightness ==
                                                Brightness.dark
                                            ? AppColors.textPrimary
                                            : Color(0xFFEFEFEF)),
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
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w, vertical: 0.h),
                                            child:
                                                DropdownButtonFormField<String>(
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
                                                return DropdownMenuItem<String>(
                                                  value: p['id'].toString(),
                                                  child: Text(p['name'],
                                                      style: TextStyle(
                                                          color: Theme.of(context)
                                                                      .brightness ==
                                                                  Brightness
                                                                      .dark
                                                              ? AppColors
                                                                  .textLight
                                                              : Colors.black)),
                                                );
                                              }).toList(),
                                              onChanged: (value) {
                                                setState(() {
                                                  b["product_id"] =
                                                      int.tryParse(value ?? '');
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
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w, vertical: 0.h),
                                            child: (_showSnFieldMap[index] ??
                                                    false)
                                                ? TextFormField(
                                                    initialValue: b["sn"] ?? "",
                                                    style: TextStyle(
                                                        fontSize: 12.sp),
                                                    decoration: InputDecoration(
                                                      isDense: true,
                                                      contentPadding:
                                                          EdgeInsets.symmetric(
                                                              vertical: 8.h,
                                                              horizontal: 4.w),
                                                      border: InputBorder.none,
                                                      hintText: "SN Modem",
                                                    ),
                                                    onChanged: (value) {
                                                      setState(() {
                                                        b["sn"] = value;
                                                      });
                                                    },
                                                  )
                                                : SizedBox.shrink(),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 4.w, vertical: 0.h),
                                            child: TextFormField(
                                              initialValue:
                                                  b["jumlah"]?.toString() ??
                                                      "1",
                                              keyboardType:
                                                  TextInputType.number,
                                              style: TextStyle(fontSize: 12.sp),
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
                                                      int.tryParse(value) ?? 1;
                                                });
                                              },
                                            ),
                                          ),
                                        ),
                                        TableCell(
                                          verticalAlignment:
                                              TableCellVerticalAlignment.middle,
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            iconSize: 30.sp,
                                            padding: EdgeInsets.zero,
                                            constraints: const BoxConstraints(),
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
                                  }).toList(),
                                ],
                              ),
                            )
                          else
                            const Center(
                                child:
                                    Text("Tekan tombol + untuk menambah item")),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              // ),
            ),
            bottomNavigationBar: Padding(
              padding: EdgeInsets.all(16.r),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
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

                        final payload = {
                          "branch_id": _selectedBranchId,
                          "zone_id": _selectedZoneId,
                          "name": _nameCustomerController.text,
                          "phone": _phoneController.text,
                          "address": _addressController.text,
                          "latitude": _latitudeController.text,
                          "longitude": _longitudeController.text,
                          "odp_id": 1,
                          "purpose": _selectedPurpose ?? "psb",
                          "type": "out",
                          "technician": _selectedTechnicians,
                          "item_id": itemIdList
                              .map((item) => {
                                    "product_id": item["product_id"],
                                    "jumlah": item["jumlah"] ?? 0,
                                    "sn": item["sn"] ?? "",
                                  })
                              .toList(),
                        };
                        bool success = await context
                            .read<CustomerServiceProvider>()
                            .addCustomer(payload, userID);

                        if (success) {
                          Navigator.pop(context, true);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text(
                                    "Laporan Retail berhasil ditambahkan")),
                          );
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content:
                                    Text("Gagal menambahkan Laporan Retail")),
                          );
                        }
                      } catch (e, st) {
                        print("Error: $e\n$st");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Error: $e")),
                        );
                      }
                    },
                    child: const Text("Simpan"),
                  ),
                ],
              ),
            ),
          );
        });
  }
}
