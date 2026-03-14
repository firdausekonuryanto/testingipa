import 'dart:io';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_map/flutter_map.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/utils/helper/globalhelper.dart';

import 'package:internusa_group/widgets/app_bottom_nav.dart';
import 'package:internusa_group/providers/dynamic_form_provider.dart';

import 'package:internusa_group/screens/report/widgets/multiple_input_row.dart';
import 'package:internusa_group/screens/report/widgets/slide_page_route.dart';

class CreateDynamicFormScreen extends StatefulWidget {
  final int formId;
  const CreateDynamicFormScreen({super.key, required this.formId});

  @override
  State<CreateDynamicFormScreen> createState() =>
      _CreateDynamicFormScreenState();
}

class _CreateDynamicFormScreenState extends State<CreateDynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formValues = {};
  final ImagePicker _picker = ImagePicker();
  int _selectedIndex = 1;
  LatLng? selectedLocation;
  final TextEditingController _latitudeController = TextEditingController();
  final TextEditingController _longitudeController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  List<File?> files = [null];
  Map<String, List<File>> multipleFiles = {};
  Map<String, List<int>> modemStatus = {};
  final Map<String, List<String>> _multipleTextValues = {};
  final Map<String, List<TextEditingController>> _controllers = {};
  final Map<String, List<String?>> _multipleSelectValues = {};
  final Map<String, List<String?>> _multipleApiValues = {};

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final provider = Provider.of<DynamicFormProvider>(context, listen: false);
    await provider.loadFormById(widget.formId);
  }

  Future<void> _pickFile(String fieldName, {bool multiple = false}) async {
    if (multiple) {
      final pickedFiles = await _picker.pickMultiImage();

      if (pickedFiles.isNotEmpty) {
        setState(() {
          final files = pickedFiles
              .map((x) => File(x.path))
              .where((f) => f.path.isNotEmpty)
              .toList();

          multipleFiles[fieldName] = files;
          _formValues[fieldName] = files;
        });
      }
    } else {
      final picked = await _picker.pickImage(source: ImageSource.gallery);

      if (picked != null) {
        setState(() {
          final file = File(picked.path);
          _formValues[fieldName] = file;
        });
      }
    }
  }

  bool isImageFile(String path) {
    final ext = path.toLowerCase();
    return ext.endsWith('.jpg') ||
        ext.endsWith('.jpeg') ||
        ext.endsWith('.png') ||
        ext.endsWith('.webp');
  }

  Widget buildMultipleInputRow({
    required dynamic field,
    required int index,
    required List<Map<String, dynamic>> options,
    required bool isLoading,
    required bool hasError,
    required int modemValue,
  }) {
    return MultipleInputRow(
      dropdown: DropdownButtonFormField<String>(
        decoration: const InputDecoration(
          border: OutlineInputBorder(),
        ),
        value: _multipleApiValues[field.name]![index],
        hint: Text(
          hasError ? "Gagal memuat data" : "Pilih ${field.label}",
        ),
        items: options.map((opt) {
          return DropdownMenuItem<String>(
            value: opt["name"].toString(),
            child: Text(opt["label"].toString()),
          );
        }).toList(),
        onChanged: (isLoading || hasError)
            ? null
            : (val) {
                setState(() {
                  _multipleApiValues[field.name]![index] = val;
                  _formValues[field.name] = _multipleApiValues[field.name];

                  final selected = options.firstWhere(
                    (e) => e["name"].toString() == val.toString(),
                    orElse: () => {"modem": 0},
                  );

                  modemStatus[field.name]![index] = selected["modem"] ?? 0;
                });
              },
        isDense: true,
        isExpanded: true,
      ),
      showSerialInput: modemValue == 1,
      onSerialChanged: (value) {
        _formValues["${field.name}_serial_$index"] = value;
      },
      onAdd: () {
        setState(() {
          _multipleApiValues[field.name]!.insert(index + 1, null);
          modemStatus[field.name]!.insert(index + 1, 0);
        });
      },
      onDelete: () {
        setState(() {
          if (_multipleApiValues[field.name]!.length > 1) {
            _multipleApiValues[field.name]!.removeAt(index);
            modemStatus[field.name]!.removeAt(index);
          }
        });
      },
    );
  }

  Future<void> _submitForm(int id) async {
    final provider = Provider.of<DynamicFormProvider>(context, listen: false);

    try {
      final payload = Map<String, dynamic>.from(_formValues);

      final serialEntries = payload.entries.where(
        (e) => RegExp(r'_serial_\d+$').hasMatch(e.key),
      );

      for (final entry in serialEntries) {
        final parts = entry.key.split('_serial_');
        final baseName = parts[0];
        final index = int.tryParse(parts[1]) ?? 0;
        final serialValue = entry.value.toString();

        final mainValue = payload[baseName];

        if (mainValue is List) {
          final updated = List<String>.from(mainValue);
          if (index < updated.length) {
            updated[index] = "${updated[index]}-$serialValue";
          }
          payload[baseName] = updated;
        } else if (mainValue is String) {
          payload[baseName] = "$mainValue-$serialValue";
        }
      }

      await provider.submitForm(id, payload);
      if (!mounted) return;

      if (provider.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Gagal: ${provider.errorMessage}")),
        );
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Form berhasil disubmit!")),
      );

      setState(() => _formValues.clear());

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;

      Navigator.of(context).pushReplacement(
        PageRouteBuilder(
          transitionDuration: const Duration(milliseconds: 400),
          pageBuilder: (_, animation, __) => const SlidePageRoute(),
          transitionsBuilder: (_, animation, __, child) {
            final offset = Tween(
              begin: const Offset(1.0, 0.0),
              end: Offset.zero,
            ).animate(
              CurvedAnimation(parent: animation, curve: Curves.easeInOut),
            );
            return SlideTransition(position: offset, child: child);
          },
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Terjadi kesalahan: $e")),
      );
    }
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/index-dynamic-forms');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/select-dynamic-forms');
    }
  }

  bool _isUrl(String? s) {
    if (s == null) return false;
    try {
      final uri = Uri.tryParse(s);
      return uri != null &&
          (uri.scheme == 'http' || uri.scheme == 'https') &&
          uri.hasAuthority;
    } catch (e) {
      return false;
    }
  }

  @override
  void dispose() {
    _latitudeController.dispose();
    _longitudeController.dispose();
    _addressController.dispose();
    super.dispose();
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
    final provider = Provider.of<DynamicFormProvider>(context);

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (provider.errorMessage != null) {
      return Scaffold(body: Center(child: Text(provider.errorMessage!)));
    }

    if (provider.forms.isEmpty) {
      return const Scaffold(
          body: Center(child: Text("Tidak ada form ditemukan")));
    }

    final form = provider.forms.first;

    return Scaffold(
      appBar: AppBar(
        title: Text(form.formName, style: TextStyle(fontSize: 16.sp)),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.w),
        child: Form(
            key: _formKey,
            child: ListView(
              children: [
                ...form.fields.map((field) {
                  switch (field.type) {
                    /* ===== INPUT TEXT ===== */
                    case 'text':
                      if (field.name == 'latitude') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TextFormField(
                            controller: _latitudeController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => _formValues[field.name] = val,
                            validator: field.required == true
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return '${field.label} tidak boleh kosong';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        );
                      } else if (field.name == 'longitude') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TextFormField(
                            controller: _longitudeController,
                            keyboardType: const TextInputType.numberWithOptions(
                                decimal: true, signed: true),
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => _formValues[field.name] = val,
                            validator: field.required == true
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return '${field.label} tidak boleh kosong';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        );
                      } else {
                        if (field.multipled == true &&
                            !_multipleTextValues.containsKey(field.name)) {
                          _multipleTextValues[field.name] = [''];

                          _controllers[field.name] = [
                            TextEditingController(text: ''),
                          ];
                        }

                        if (field.multipled == true) {
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.label,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13.sp,
                                ),
                              ),
                              SizedBox(height: 8.h),
                              ...List.generate(
                                _multipleTextValues[field.name]!.length,
                                (index) {
                                  return Padding(
                                    key: ValueKey("${field.name}_$index"),
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TextFormField(
                                            controller: _controllers[
                                                field.name]![index],
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            onChanged: (val) {
                                              _multipleTextValues[field.name]![
                                                  index] = val;
                                              _formValues[field.name] =
                                                  _multipleTextValues[
                                                      field.name];
                                            },
                                            validator: field.required == true
                                                ? (value) {
                                                    if (value == null ||
                                                        value.isEmpty) {
                                                      return '${field.label} tidak boleh kosong';
                                                    }
                                                    return null;
                                                  }
                                                : null,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                _multipleTextValues[field.name]!
                                                    .insert(index + 1, '');

                                                _controllers[field.name]!
                                                    .insert(
                                                  index + 1,
                                                  TextEditingController(
                                                      text: ''),
                                                );
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.red.shade300),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                if (_multipleTextValues[
                                                            field.name]!
                                                        .length >
                                                    1) {
                                                  _multipleTextValues[
                                                          field.name]!
                                                      .removeAt(index);
                                                  _controllers[field.name]!
                                                      .removeAt(index);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        }

                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TextFormField(
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => _formValues[field.name] = val,
                            validator: field.required == true
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return '${field.label} tidak boleh kosong';
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        );
                      }

                    /* ===== INPUT FILE ===== */
                    case 'file':
                      final isMultiple = field.multipled == true;

                      if (isMultiple && multipleFiles[field.name] == null) {
                        multipleFiles[field.name] = [];
                      }

                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(field.label,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp)),
                            SizedBox(height: 8.h),

                            /* ===== INPUT FILE SINGLE ===== */
                            if (!isMultiple)
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ElevatedButton.icon(
                                    onPressed: () =>
                                        _pickFile(field.name, multiple: false),
                                    icon: Icon(Icons.upload_file, size: 18.sp),
                                    label: Text("Pilih File",
                                        style: TextStyle(fontSize: 12.sp)),
                                  ),
                                  SizedBox(width: 12.w),
                                  if (_formValues[field.name] != null &&
                                      (_formValues[field.name] as File)
                                          .path
                                          .isNotEmpty)
                                    SizedBox(
                                      width: 80.w,
                                      height: 80.h,
                                      child: Stack(
                                        children: [
                                          // IMAGE
                                          ClipRRect(
                                            borderRadius:
                                                BorderRadius.circular(8.r),
                                            child: Image.file(
                                              _formValues[field.name],
                                              width: 80.w,
                                              height: 80.h,
                                              fit: BoxFit.cover,
                                            ),
                                          ),

                                          // DELETE BUTTON (TOP RIGHT OF IMAGE)
                                          Positioned(
                                            top: 4,
                                            right: 4,
                                            child: GestureDetector(
                                              onTap: () {
                                                setState(() {
                                                  _formValues
                                                      .remove(field.name);
                                                });
                                              },
                                              child: Container(
                                                decoration: const BoxDecoration(
                                                  color: Colors.black54,
                                                  shape: BoxShape.circle,
                                                ),
                                                padding:
                                                    const EdgeInsets.all(4),
                                                child: const Icon(
                                                  Icons.close,
                                                  size: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                ],
                              ),

                            /* ===== INPUT FILE MULTIPLE ===== */
                            if (isMultiple)
                              Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    ElevatedButton.icon(
                                      onPressed: () =>
                                          _pickFile(field.name, multiple: true),
                                      icon: const Icon(Icons.upload_file),
                                      label: Text("Pilih File"),
                                    ),
                                    SizedBox(height: 12.h),
                                    if (multipleFiles[field.name] != null &&
                                        multipleFiles[field.name]!.isNotEmpty)
                                      GridView.builder(
                                        shrinkWrap: true,
                                        physics:
                                            const NeverScrollableScrollPhysics(),
                                        itemCount:
                                            multipleFiles[field.name]!.length,
                                        gridDelegate:
                                            SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 3,
                                          crossAxisSpacing: 8.w,
                                          mainAxisSpacing: 8.h,
                                        ),
                                        itemBuilder: (context, i) {
                                          final file =
                                              multipleFiles[field.name]![i];

                                          return Stack(
                                            children: [
                                              // IMAGE
                                              ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(8.r),
                                                child: Image.file(
                                                  file,
                                                  width: double.infinity,
                                                  height: double.infinity,
                                                  fit: BoxFit.cover,
                                                ),
                                              ),

                                              // DELETE BUTTON (TOP RIGHT)
                                              Positioned(
                                                top: 4,
                                                right: 4,
                                                child: GestureDetector(
                                                  onTap: () {
                                                    setState(() {
                                                      multipleFiles[field.name]!
                                                          .removeAt(i);
                                                      _formValues[field.name] =
                                                          multipleFiles[
                                                              field.name];
                                                    });
                                                  },
                                                  child: Container(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black54,
                                                      shape: BoxShape.circle,
                                                    ),
                                                    padding:
                                                        const EdgeInsets.all(4),
                                                    child: const Icon(
                                                      Icons.close,
                                                      size: 16,
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          );
                                        },
                                      ),
                                  ])
                          ],
                        ),
                      );

                    /* ===== INPUT NUMBER ===== */
                    case 'number':
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: TextFormField(
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: const OutlineInputBorder(),
                          ),
                          onChanged: (val) {
                            _formValues[field.name] = int.tryParse(val) ?? 0;
                          },
                          validator: field.required == true
                              ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return "${field.label} wajib diisi";
                                  }
                                  if (int.tryParse(value) == null) {
                                    return "${field.label} harus berupa angka";
                                  }
                                  return null;
                                }
                              : null,
                        ),
                      );

                    /* ===== INPUT TEXTAREA ===== */
                    case 'textarea':
                      if (field.name == 'alamat_map') {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TextFormField(
                            controller: _addressController,
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => _formValues[field.name] = val,
                            validator: field.required == true
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return "${field.label} wajib diisi";
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        );
                      } else {
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: TextFormField(
                            maxLines: 5,
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: const OutlineInputBorder(),
                            ),
                            onChanged: (val) => _formValues[field.name] = val,
                            validator: field.required == true
                                ? (value) {
                                    if (value == null || value.isEmpty) {
                                      return "${field.label} wajib diisi";
                                    }
                                    return null;
                                  }
                                : null,
                          ),
                        );
                      }

                    /* ===== INPUT DATE ===== */
                    case 'date':
                      return Padding(
                        padding: EdgeInsets.only(bottom: 16.h),
                        child: TextFormField(
                          readOnly: true,
                          controller: TextEditingController(
                            text: _formValues[field.name]?.toString() ?? '',
                          ),
                          decoration: InputDecoration(
                            labelText: field.label,
                            border: const OutlineInputBorder(),
                            suffixIcon: const Icon(Icons.calendar_today),
                          ),
                          validator: field.required == true
                              ? (value) {
                                  if (value == null || value.isEmpty) {
                                    return '${field.label} tidak boleh kosong';
                                  }
                                  return null;
                                }
                              : null,
                          onTap: () async {
                            final pickedDate = await showDatePicker(
                              context: context,
                              firstDate: DateTime(2000),
                              lastDate: DateTime(2100),
                              initialDate: DateTime.now(),
                            );
                            if (pickedDate != null) {
                              setState(() {
                                _formValues[field.name] = pickedDate
                                    .toIso8601String()
                                    .split('T')
                                    .first;
                              });
                            }
                          },
                        ),
                      );

                    /* ===== INPUT SELECT ===== */
                    case 'select':
                      final optionsData = field.options as Object?;
                      bool isApiSource = false;
                      String? apiUrl;
                      String? cekData;
                      if (optionsData is List &&
                          optionsData.length == 1 &&
                          optionsData.first is String) {
                        final potentialUrl = optionsData.first as String;
                        cekData = optionsData.first as String;

                        if (_isUrl(potentialUrl)) {
                          isApiSource = true;
                          apiUrl = potentialUrl;
                        }
                      }

                      /* ===== SELECT BY URL  ===== */
                      if (isApiSource && apiUrl != null) {
                        final url = apiUrl;

                        /* ===== SELECT BY URL MULTIPLE  ===== */
                        if (field.multipled == true) {
                          if (!_multipleApiValues.containsKey(field.name)) {
                            _multipleApiValues[field.name] = [null];
                          }

                          _multipleApiValues.putIfAbsent(
                              field.name, () => [null]);
                          modemStatus.putIfAbsent(field.name, () => [0]);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.label,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp),
                              ),
                              SizedBox(height: 8.h),
                              ...List.generate(
                                _multipleApiValues[field.name]!.length,
                                (index) {
                                  return Padding(
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: FutureBuilder<
                                        List<Map<String, dynamic>>>(
                                      future: provider.fetchOptionsByUrl(
                                          url, field.name),
                                      builder: (context, snapshot) {
                                        final isLoading =
                                            snapshot.connectionState ==
                                                ConnectionState.waiting;

                                        final hasError = snapshot.hasError ||
                                            (snapshot.hasData &&
                                                snapshot.data!.any((e) =>
                                                    e["label"] ==
                                                    "Gagal memuat data"));

                                        final List<Map<String, dynamic>>
                                            options = (!isLoading &&
                                                    !hasError &&
                                                    snapshot.hasData)
                                                ? snapshot.data!
                                                : [];

                                        final modemList =
                                            modemStatus[field.name] ?? [];
                                        final modemValue =
                                            (modemList.length > index)
                                                ? modemList[index]
                                                : 0;
                                        return buildMultipleInputRow(
                                          field: field,
                                          index: index,
                                          options: options,
                                          isLoading: isLoading,
                                          hasError: hasError,
                                          modemValue: modemValue,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        }
                        /* ===== SELECT BY URL SINGLE ===== */
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: provider.fetchOptionsByUrl(url, field.name),
                            builder: (context, snapshot) {
                              final isLoading = snapshot.connectionState ==
                                  ConnectionState.waiting;

                              final hasError = snapshot.hasError ||
                                  (snapshot.hasData &&
                                      snapshot.data!.any((e) =>
                                          e["label"] == "Gagal memuat data"));

                              final List<Map<String, dynamic>> options =
                                  (!isLoading && !hasError && snapshot.hasData)
                                      ? snapshot.data!
                                      : [];

                              final currentValue =
                                  _formValues[field.name] as String?;

                              int modemValue = 0;
                              if (currentValue != null && options.isNotEmpty) {
                                final selected = options.firstWhere(
                                  (e) => e["name"].toString() == currentValue,
                                  orElse: () => {"modem": 0},
                                );
                                modemValue = selected["modem"] ?? 0;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: field.label,
                                      border: const OutlineInputBorder(),
                                    ),
                                    value: currentValue,
                                    items: options.map((opt) {
                                      return DropdownMenuItem(
                                        value: opt["name"].toString(),
                                        child: Text(opt["label"].toString(),
                                            style: TextStyle(fontSize: 12.sp)),
                                      );
                                    }).toList(),
                                    onChanged: isLoading
                                        ? null
                                        : (val) {
                                            setState(() {
                                              _formValues[field.name] = val;

                                              final selected =
                                                  options.firstWhere(
                                                (e) =>
                                                    e["name"].toString() == val,
                                                orElse: () => {"modem": 0},
                                              );

                                              _formValues[
                                                      "${field.name}_modem_0"] =
                                                  selected["modem"] ?? 0;
                                            });
                                          },
                                  ),
                                  const SizedBox(height: 10),
                                  if (modemValue == 1)
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: "Serial Number",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        _formValues["${field.name}_serial_0"] =
                                            value;
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                        );
                      }

                      /* ===== SELECT BY MODEL ===== */
                      if (cekData?.contains('#') ?? false) {
                        String cleanData = cekData!.replaceAll('#', '');

                        final url =
                            "${dotenv.env['DEVBASEURL']}/master/$cleanData";

                        /* ===== SELECT BY MODEL MULTIPLE  ===== */
                        if (field.multipled == true) {
                          if (!_multipleApiValues.containsKey(field.name)) {
                            _multipleApiValues[field.name] = [null];
                          }

                          _multipleApiValues.putIfAbsent(
                              field.name, () => [null]);
                          modemStatus.putIfAbsent(field.name, () => [0]);

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(field.label,
                                  style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13.sp)),
                              SizedBox(height: 8.h),
                              ...List.generate(
                                _multipleApiValues[field.name]!.length,
                                (index) {
                                  return Padding(
                                    key: ValueKey(
                                        "${field.name}_dynamic_$index"),
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: FutureBuilder<
                                        List<Map<String, dynamic>>>(
                                      future: provider.fetchOptionsByUrl(
                                          url, field.name),
                                      builder: (context, snapshot) {
                                        bool isLoading =
                                            snapshot.connectionState ==
                                                ConnectionState.waiting;
                                        bool hasError = snapshot.hasError ||
                                            (snapshot.hasData &&
                                                snapshot.data!.any((opt) =>
                                                    opt["label"] ==
                                                    "Gagal memuat data"));

                                        List<Map<String, dynamic>> options =
                                            (!hasError && snapshot.hasData)
                                                ? snapshot.data!
                                                : [];

                                        final modemList =
                                            modemStatus[field.name] ?? [];
                                        final modemValue =
                                            (modemList.length > index)
                                                ? modemList[index]
                                                : 0;

                                        return buildMultipleInputRow(
                                          field: field,
                                          index: index,
                                          options: options,
                                          isLoading: isLoading,
                                          hasError: hasError,
                                          modemValue: modemValue,
                                        );
                                      },
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        }

                        /* ===== SELECT BY MODEL SINGLE  ===== */
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: FutureBuilder<List<Map<String, dynamic>>>(
                            future: provider.fetchOptionsByUrl(url, field.name),
                            builder: (context, snapshot) {
                              bool isLoading = snapshot.connectionState ==
                                  ConnectionState.waiting;

                              bool hasError = snapshot.hasError ||
                                  (snapshot.hasData &&
                                      snapshot.data!.any((opt) =>
                                          opt["label"] == "Gagal memuat data"));

                              List<Map<String, dynamic>> options =
                                  (!hasError && snapshot.hasData)
                                      ? snapshot.data!
                                      : [];

                              final currentValue =
                                  _formValues[field.name] as String?;

                              int modemValue = 0;
                              if (currentValue != null && options.isNotEmpty) {
                                final selected = options.firstWhere(
                                  (e) => e["name"].toString() == currentValue,
                                  orElse: () => {"modem": 0},
                                );
                                modemValue = selected["modem"] ?? 0;
                              }

                              return Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  DropdownButtonFormField<String>(
                                    decoration: InputDecoration(
                                      labelText: field.label,
                                      border: const OutlineInputBorder(),
                                    ),
                                    value: currentValue,
                                    items: options.map((opt) {
                                      return DropdownMenuItem(
                                        value: opt["name"].toString(),
                                        child: Text(opt["label"].toString(),
                                            style: TextStyle(fontSize: 12.sp)),
                                      );
                                    }).toList(),
                                    onChanged: isLoading
                                        ? null
                                        : (val) {
                                            setState(() {
                                              _formValues[field.name] = val;

                                              final selected =
                                                  options.firstWhere(
                                                (e) =>
                                                    e["name"].toString() == val,
                                                orElse: () => {"modem": 0},
                                              );

                                              _formValues[
                                                      "${field.name}_modem_0"] =
                                                  selected["modem"] ?? 0;
                                            });
                                          },
                                  ),
                                  const SizedBox(height: 10),
                                  if (modemValue == 1)
                                    TextFormField(
                                      decoration: const InputDecoration(
                                        labelText: "Serial Number",
                                        border: OutlineInputBorder(),
                                      ),
                                      onChanged: (value) {
                                        _formValues["${field.name}_serial_0"] =
                                            value;
                                      },
                                    ),
                                ],
                              );
                            },
                          ),
                        );
                      } else if (cekData == '@map') {
                        return Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(
                                height: 300.h,
                                child: FlutterMap(
                                  options: MapOptions(
                                    initialCenter: selectedLocation ??
                                        const LatLng(-8.240626619492808,
                                            114.35510709912761),
                                    initialZoom: 13,
                                    onTap: (tapPos, latlng) async {
                                      setState(() {
                                        selectedLocation = latlng;
                                        _latitudeController.text =
                                            latlng.latitude.toStringAsFixed(6);
                                        _longitudeController.text =
                                            latlng.longitude.toStringAsFixed(6);
                                        _formValues['latitude'] =
                                            latlng.latitude.toStringAsFixed(6);
                                        _formValues['longitude'] =
                                            latlng.longitude.toStringAsFixed(6);
                                      });

                                      final address =
                                          await getAddressFromLatLng(
                                        latlng.latitude,
                                        latlng.longitude,
                                      );

                                      if (address != null) {
                                        setState(() {
                                          _addressController.text = address;
                                          _formValues['alamat_map'] = address;
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
                            ]);
                      }

                      /* ===== SELECT MANUAL  ===== */
                      else {
                        final List<String> staticOptions = (optionsData
                                is List<dynamic>)
                            ? optionsData.map((e) => e.toString()).toList()
                            : (optionsData is String && optionsData.isNotEmpty)
                                ? optionsData
                                    .split(',')
                                    .map((s) => s.trim())
                                    .toList()
                                : [];

                        /* ===== SELECT MANUAL MULTIPLE ===== */
                        if (field.multipled == true) {
                          if (!_multipleSelectValues.containsKey(field.name)) {
                            _multipleSelectValues[field.name] = [null];
                          }

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                field.label,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13.sp),
                              ),
                              SizedBox(height: 8.h),
                              ...List.generate(
                                _multipleSelectValues[field.name]!.length,
                                (index) {
                                  return Padding(
                                    key:
                                        ValueKey("${field.name}_select_$index"),
                                    padding: EdgeInsets.only(bottom: 12.h),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child:
                                              DropdownButtonFormField<String>(
                                            decoration: const InputDecoration(
                                              border: OutlineInputBorder(),
                                            ),
                                            value: _multipleSelectValues[
                                                field.name]![index],
                                            items: staticOptions
                                                .map(
                                                  (option) => DropdownMenuItem(
                                                    value: option,
                                                    child: Text(option,
                                                        style: TextStyle(
                                                            fontSize: 12.sp)),
                                                  ),
                                                )
                                                .toList(),
                                            onChanged: (val) {
                                              setState(() {
                                                _multipleSelectValues[
                                                    field.name]![index] = val;
                                                _formValues[field.name] =
                                                    _multipleSelectValues[
                                                        field.name];
                                              });
                                            },
                                            isExpanded: true,
                                            isDense: true,
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.grey.shade400),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.add),
                                            onPressed: () {
                                              setState(() {
                                                _multipleSelectValues[
                                                        field.name]!
                                                    .insert(index + 1, null);
                                              });
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8.w),
                                        Container(
                                          height: 48,
                                          width: 48,
                                          decoration: BoxDecoration(
                                            border: Border.all(
                                                color: Colors.red.shade300),
                                            borderRadius:
                                                BorderRadius.circular(6),
                                          ),
                                          child: IconButton(
                                            icon: const Icon(Icons.delete,
                                                color: Colors.red),
                                            onPressed: () {
                                              setState(() {
                                                if (_multipleSelectValues[
                                                            field.name]!
                                                        .length >
                                                    1) {
                                                  _multipleSelectValues[
                                                          field.name]!
                                                      .removeAt(index);
                                                }
                                              });
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                              ),
                              SizedBox(height: 16.h),
                            ],
                          );
                        }

                        /* ===== SELECT MANUAL SINGLE ===== */
                        return Padding(
                          padding: EdgeInsets.only(bottom: 16.h),
                          child: DropdownButtonFormField<String>(
                            decoration: InputDecoration(
                              labelText: field.label,
                              border: const OutlineInputBorder(),
                            ),
                            value: _formValues[field.name] as String?,
                            items: staticOptions
                                .map((option) => DropdownMenuItem(
                                      value: option,
                                      child: Text(option,
                                          style: TextStyle(fontSize: 12.sp)),
                                    ))
                                .toList(),
                            onChanged: (val) {
                              setState(() => _formValues[field.name] = val);
                            },
                            isDense: true,
                            isExpanded: true,
                          ),
                        );
                      }

                    default:
                      return Text(
                        "Tipe input '${field.type}' belum didukung",
                        style: TextStyle(fontSize: 12.sp),
                      );
                  }
                }),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () {
                      if (_formKey.currentState!.validate()) {
                        _submitForm(form.id);
                      }
                    },
                    icon: const Icon(Icons.send, color: AppColors.textLight),
                    label: Text("Submit Form",
                        style: TextStyle(
                          fontSize: 16.sp,
                          color: AppColors.textLight,
                        )),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(vertical: 12.h),
                      backgroundColor: AppColors.primaryLight,
                    ),
                  ),
                ),
              ],
            )),
      ),
      bottomNavigationBar: AppBottomNav(
        currentIndex: _selectedIndex,
        onItemTapped: _onItemTapped,
      ),
    );
  }
}
