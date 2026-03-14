import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:internusa_group/utils/theme.dart';
import 'package:internusa_group/widgets/app_bottom_nav.dart';
import 'package:internusa_group/providers/dynamic_form_provider.dart';
import 'package:internusa_group/screens/report/widgets/slide_page_route.dart';
import 'package:internusa_group/screens/report/widgets/multiple_input_row.dart';

class EditDynamicFormScreen extends StatefulWidget {
  final int formId;
  final int id;

  const EditDynamicFormScreen({
    super.key,
    required this.formId,
    required this.id,
  });

  @override
  State<EditDynamicFormScreen> createState() => _EditDynamicFormScreenState();
}

class _EditDynamicFormScreenState extends State<EditDynamicFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final Map<String, dynamic> _formValues = {};
  final Map<String, List<Map<String, dynamic>>> _multipleTextValues = {};
  final Map<String, List<TextEditingController>> _controllers = {};
  final Map<String, Map<String, dynamic>> _singleTextValues = {};
  final Map<String, TextEditingController> _singleControllers = {};
  final Map<String, List<Map<String, dynamic>>> _multipleSelectValues = {};
  final Map<String, Map<String, dynamic>> _singleSelectApiValues = {};
  final Map<String, List<Map<String, dynamic>>> _multipleSelectApiValues = {};
  final Map<String, List<Map<String, dynamic>>> _multipleImageValues = {};
  final Map<String, Map<String, dynamic>> _singleImageValues = {};
  final Map<String, List<String?>> _multipleApiValues = {};
  final baseImage = dotenv.env['DEVBASEIMAGE'] ?? '';
  final ImagePicker _picker = ImagePicker();
  Map<String, List<int>> modemStatus = {};
  int _selectedIndex = 1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDataEdit();
    });
  }

  Future<void> _pickMultipleImages(String fieldName) async {
    final pickedFiles = await _picker.pickMultiImage();

    if (pickedFiles.isNotEmpty) {
      setState(() {
        final files = pickedFiles.map((x) {
          return {
            "id": null,
            "value": null,
            "url": null,
            "file": File(x.path),
          };
        }).toList();

        _multipleImageValues[fieldName] ??= [];
        _multipleImageValues[fieldName]!.addAll(files);

        _formValues[fieldName] = _multipleImageValues[fieldName];
      });
    }
  }

  Future<void> _loadDataEdit() async {
    final provider = context.read<DynamicFormProvider>();

    _formValues.clear();
    _multipleTextValues.clear();
    _singleTextValues.clear();
    _multipleSelectValues.clear();
    _multipleImageValues.clear();
    _singleImageValues.clear();

    for (final list in _controllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }
    _controllers.clear();

    for (final c in _singleControllers.values) {
      c.dispose();
    }
    _singleControllers.clear();

    await provider.editLoadFormById(widget.id);
  }

  @override
  void dispose() {
    for (final list in _controllers.values) {
      for (final c in list) {
        c.dispose();
      }
    }

    for (final c in _singleControllers.values) {
      c.dispose();
    }

    _multipleImageValues.clear();
    _singleImageValues.clear();
    _multipleSelectValues.clear();
    _multipleTextValues.clear();
    _singleTextValues.clear();
    _formValues.clear();

    super.dispose();
  }

  void _onItemTapped(int index) {
    setState(() => _selectedIndex = index);
    if (index == 0) {
      Navigator.pushReplacementNamed(context, '/index-dynamic-forms');
    } else if (index == 1) {
      Navigator.pushReplacementNamed(context, '/select-dynamic-forms');
    }
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

  Future<void> _submitForm(int formId) async {
    final provider = context.read<DynamicFormProvider>();
    final payload = Map<String, dynamic>.from(_formValues);

    payload.forEach((field, value) {
      /// ================= SINGLE =================
      if (value is Map<String, dynamic>) {
        // debugPrint('TYPE : SINGLE');
        // debugPrint('  id    : ${value["id"]}');
        // debugPrint('  value : ${value["value"]}');
        // debugPrint('  file  : ${value["file"]}');

        if (value["file"] is File) {
          final f = value["file"] as File;
          // debugPrint('  FILE PATH   : ${f.path}');
          // debugPrint('  FILE EXIST : ${f.existsSync()}');
        }
      }

      /// ================= MULTIPLE =================
      if (value is List) {
        // debugPrint('TYPE : MULTIPLE (TOTAL ${value.length})');

        for (var i = 0; i < value.length; i++) {
          final item = value[i];

          if (item is Map<String, dynamic>) {
            // debugPrint('  [$i] id    : ${item["id"]}');
            // debugPrint('  [$i] value : ${item["value"]}');
            // debugPrint('  [$i] file  : ${item["file"]}');

            if (item["file"] is File) {
              final f = item["file"] as File;
              // debugPrint('  [$i] FILE PATH   : ${f.path}');
              // debugPrint('  [$i] FILE EXIST : ${f.existsSync()}');
            }
          }
        }
      }
    });

    if (payload.isEmpty) {
      debugPrint('SUBMIT DIBATALKAN: PAYLOAD KOSONG');
      return;
    }

    await provider.submitFormEdit(formId, payload);

    if (!mounted) return;

    if (provider.errorMessage != null) {
      debugPrint('API ERROR: ${provider.errorMessage}');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(provider.errorMessage!)),
      );
      return;
    }

    // debugPrint('FORM BERHASIL DIUPDATE');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Form berhasil diupdate")),
    );

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        transitionDuration: const Duration(milliseconds: 400),
        pageBuilder: (_, __, ___) => const SlidePageRoute(),
        transitionsBuilder: (_, animation, __, child) {
          final offset = Tween(
            begin: const Offset(1, 0),
            end: Offset.zero,
          ).animate(animation);

          return SlideTransition(position: offset, child: child);
        },
      ),
    );
  }

  Future<File?> _pickImage() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (picked == null) return null;
    return File(picked.path);
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DynamicFormProvider>();

    if (provider.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (provider.errorMessage != null) {
      return Scaffold(
        body: Center(child: Text(provider.errorMessage!)),
      );
    }

    if (provider.forms.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Form tidak ditemukan")),
      );
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
                /// ================= MULTIPLED TEXT =================
                if (field.type == 'text' && field.multipled == true) {
                  if (!_multipleTextValues.containsKey(field.name)) {
                    final initialValues =
                        (field.value != null && field.value!.isNotEmpty)
                            ? List.generate(field.value!.length, (i) {
                                return {
                                  "id": field.valueId,
                                  "value": field.value![i],
                                };
                              })
                            : [
                                {"id": null, "value": ""}
                              ];

                    _multipleTextValues[field.name] = initialValues;

                    _controllers[field.name] = initialValues
                        .map((v) => TextEditingController(
                              text: v["value"]?.toString() ?? '',
                            ))
                        .toList();

                    _formValues[field.name] = initialValues;
                  }

                  final values = _multipleTextValues[field.name]!;
                  final ctrls = _controllers[field.name]!;

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
                      ...List.generate(values.length, (index) {
                        return Padding(
                          key: ValueKey("${field.name}_$index"),
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: TextFormField(
                                  controller: ctrls[index],
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  onChanged: (val) {
                                    values[index]["value"] = val;
                                    _formValues[field.name] = values;
                                  },
                                  validator: field.required == true
                                      ? (v) {
                                          if (v == null || v.isEmpty) {
                                            return '${field.label} wajib diisi';
                                          }
                                          return null;
                                        }
                                      : null,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              IconButton(
                                icon: const Icon(Icons.add),
                                onPressed: () {
                                  setState(() {
                                    values.insert(index + 1, {
                                      "id": null,
                                      "value": "",
                                    });
                                    ctrls.insert(
                                      index + 1,
                                      TextEditingController(),
                                    );
                                  });
                                },
                              ),
                              IconButton(
                                icon:
                                    const Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  if (values.length > 1) {
                                    setState(() {
                                      values.removeAt(index);
                                      ctrls[index].dispose();
                                      ctrls.removeAt(index);
                                    });
                                  }
                                },
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),
                    ],
                  );
                }

                /// ================= SINGLE TEXT =================
                if (field.type == 'text' && field.multipled != true) {
                  if (!_singleTextValues.containsKey(field.name)) {
                    final initialValue =
                        (field.value != null && field.value!.isNotEmpty)
                            ? field.value!.first
                            : '';

                    _singleTextValues[field.name] = {
                      "id": field.valueId,
                      "value": initialValue,
                    };

                    _singleControllers[field.name] =
                        TextEditingController(text: initialValue);

                    _formValues[field.name] = _singleTextValues[field.name];
                  }

                  final ctrl = _singleControllers[field.name]!;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: TextFormField(
                      controller: ctrl,
                      decoration: InputDecoration(
                        labelText: field.label,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _singleTextValues[field.name]!["value"] = v;
                        _formValues[field.name] = _singleTextValues[field.name];
                      },
                      validator: field.required == true
                          ? (v) {
                              if (v == null || v.isEmpty) {
                                return '${field.label} wajib diisi';
                              }
                              return null;
                            }
                          : null,
                    ),
                  );
                }

                /// ================= SINGLE TEXTAREA =================
                if (field.type == 'textarea') {
                  if (!_singleTextValues.containsKey(field.name)) {
                    final initialValue =
                        (field.value != null && field.value!.isNotEmpty)
                            ? field.value!.first
                            : '';

                    _singleTextValues[field.name] = {
                      "id": field.valueId,
                      "value": initialValue,
                    };

                    _singleControllers[field.name] =
                        TextEditingController(text: initialValue);

                    _formValues[field.name] = _singleTextValues[field.name];
                  }

                  final ctrl = _singleControllers[field.name]!;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: TextFormField(
                      controller: ctrl,
                      maxLines: 10,
                      decoration: InputDecoration(
                        labelText: field.label,
                        border: const OutlineInputBorder(),
                      ),
                      onChanged: (v) {
                        _singleTextValues[field.name]!["value"] = v;
                        _formValues[field.name] = _singleTextValues[field.name];
                      },
                      validator: field.required == true
                          ? (v) {
                              if (v == null || v.isEmpty) {
                                return '${field.label} wajib diisi';
                              }
                              return null;
                            }
                          : null,
                    ),
                  );
                }

                /// ================= SINGLE DATE =================
                if (field.type == 'date') {
                  if (!_singleTextValues.containsKey(field.name)) {
                    final initialValue =
                        (field.value != null && field.value!.isNotEmpty)
                            ? field.value!.first
                            : '';
                    _singleTextValues[field.name] = {
                      "id": field.valueId,
                      "value": initialValue,
                    };

                    _singleControllers[field.name] =
                        TextEditingController(text: initialValue);

                    _formValues[field.name] = _singleTextValues[field.name];
                  }

                  final ctrl = _singleControllers[field.name]!;

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: TextFormField(
                      controller: ctrl,
                      readOnly: true,
                      decoration: InputDecoration(
                        labelText: field.label,
                        border: const OutlineInputBorder(),
                        suffixIcon: const Icon(Icons.calendar_today),
                      ),
                      onTap: () async {
                        DateTime initialDate;
                        if (ctrl.text.isNotEmpty) {
                          try {
                            initialDate = DateTime.parse(ctrl.text);
                          } catch (_) {
                            initialDate = DateTime.now();
                          }
                        } else {
                          initialDate = DateTime.now();
                        }

                        final pickedDate = await showDatePicker(
                          context: context,
                          initialDate: initialDate,
                          firstDate: DateTime(1900),
                          lastDate: DateTime(2100),
                        );

                        if (pickedDate != null) {
                          final formattedDate =
                              pickedDate.toIso8601String().split('T').first;
                          ctrl.text = formattedDate;
                          _singleTextValues[field.name]!["value"] =
                              formattedDate;
                          _formValues[field.name] =
                              _singleTextValues[field.name];
                        }
                      },
                      validator: field.required == true
                          ? (v) {
                              if (v == null || v.isEmpty) {
                                return '${field.label} wajib diisi';
                              }
                              return null;
                            }
                          : null,
                    ),
                  );
                }

                // STAR - SELECT BY MODEL

                final optionsData = field.options as Object?;
                bool isApiSource = false;
                String? apiUrl;
                String? cekData;
                if (optionsData is List &&
                    optionsData.length == 1 &&
                    optionsData.first is String) {
                  final potentialUrl = optionsData.first as String;
                  cekData = optionsData.first as String;
                  // print("cekData : ");
                  // print(cekData);

                  if (cekData?.contains('#') ?? false) {
                    String cleanData = cekData!.replaceAll('#', '');

                    final url = "${dotenv.env['DEVBASEURL']}/master/$cleanData";

                    /* ===== SELECT BY MODEL MULTIPLE  ===== */
                    if (field.multipled == true) {
                      if (!_multipleApiValues.containsKey(field.name)) {
                        _multipleApiValues[field.name] = [null];
                      }

                      _multipleApiValues.putIfAbsent(field.name, () => [null]);
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
                                key: ValueKey("${field.name}_dynamic_$index"),
                                padding: EdgeInsets.only(bottom: 12.h),
                                child:
                                    FutureBuilder<List<Map<String, dynamic>>>(
                                  future: provider.fetchOptionsByUrl(
                                      url, field.name),
                                  builder: (context, snapshot) {
                                    bool isLoading = snapshot.connectionState ==
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

                                          final selected = options.firstWhere(
                                            (e) => e["name"].toString() == val,
                                            orElse: () => {"modem": 0},
                                          );

                                          _formValues["${field.name}_modem_0"] =
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
                }
                // END - SELECT BY MODEL

                /// ================= SINGLE SELECT =================
                if (field.type == 'select' && field.multipled != true) {
                  if (!_singleTextValues.containsKey(field.name)) {
                    final initialValue =
                        (field.value != null && field.value!.isNotEmpty)
                            ? field.value!.first
                            : null;

                    _singleTextValues[field.name] = {
                      "id": field.valueId,
                      "value": initialValue,
                    };

                    _formValues[field.name] = _singleTextValues[field.name];
                  }

                  final currentValue = _singleTextValues[field.name]!["value"];
                  final List<String> staticOptions =
                      List<String>.from(field.options ?? []);

                  return Padding(
                    padding: EdgeInsets.only(bottom: 16.h),
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: field.label,
                        border: const OutlineInputBorder(),
                      ),
                      value: staticOptions.contains(currentValue)
                          ? currentValue
                          : null,
                      items: staticOptions
                          .map(
                            (option) => DropdownMenuItem<String>(
                              value: option,
                              child: Text(
                                option,
                                style: TextStyle(fontSize: 12.sp),
                              ),
                            ),
                          )
                          .toList(),
                      onChanged: (val) {
                        _singleTextValues[field.name]!["value"] = val;
                        _formValues[field.name] = _singleTextValues[field.name];
                      },
                      validator: field.required == true
                          ? (v) {
                              if (v == null || v.isEmpty) {
                                return '${field.label} wajib dipilih';
                              }
                              return null;
                            }
                          : null,
                      isDense: true,
                      isExpanded: true,
                    ),
                  );
                }

                /// ================= MULTIPLE SELECT =================
                if (field.type == 'select' && field.multipled == true) {
                  final List<String> staticOptions =
                      List<String>.from(field.options ?? []);

                  if (!_multipleSelectValues.containsKey(field.name)) {
                    final initialValues =
                        (field.value != null && field.value!.isNotEmpty)
                            ? List.generate(field.value!.length, (i) {
                                return {
                                  "id": field.valueId,
                                  "value": field.value![i],
                                };
                              })
                            : [
                                {"id": null, "value": null}
                              ];

                    _multipleSelectValues[field.name] = initialValues;
                    _formValues[field.name] = initialValues;
                  }

                  final values = _multipleSelectValues[field.name]!;

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
                      ...List.generate(values.length, (index) {
                        final currentValue = values[index]["value"];

                        return Padding(
                          key: ValueKey("${field.name}_select_$index"),
                          padding: EdgeInsets.only(bottom: 12.h),
                          child: Row(
                            children: [
                              Expanded(
                                child: DropdownButtonFormField<String>(
                                  decoration: const InputDecoration(
                                    border: OutlineInputBorder(),
                                  ),
                                  value: staticOptions.contains(currentValue)
                                      ? currentValue
                                      : null,
                                  items: staticOptions
                                      .map(
                                        (option) => DropdownMenuItem<String>(
                                          value: option,
                                          child: Text(
                                            option,
                                            style: TextStyle(fontSize: 12.sp),
                                          ),
                                        ),
                                      )
                                      .toList(),
                                  onChanged: (val) {
                                    values[index]["value"] = val;
                                    _formValues[field.name] = values;
                                    setState(() {});
                                  },
                                  validator: field.required == true
                                      ? (v) {
                                          if (v == null || v.isEmpty) {
                                            return '${field.label} wajib dipilih';
                                          }
                                          return null;
                                        }
                                      : null,
                                  isExpanded: true,
                                  isDense: true,
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.grey.shade400),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.add),
                                  onPressed: () {
                                    setState(() {
                                      values.insert(index + 1, {
                                        "id": null,
                                        "value": null,
                                      });
                                    });
                                  },
                                ),
                              ),
                              SizedBox(width: 8.w),
                              Container(
                                height: 48,
                                width: 48,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: Colors.red.shade300),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  onPressed: () {
                                    if (values.length > 1) {
                                      setState(() {
                                        values.removeAt(index);
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      SizedBox(height: 16.h),
                    ],
                  );
                }

                /// ================= MULTIPLED IMAGE =================
                if (field.type == 'file' && field.multipled == true) {
                  /// ================= INIT MULTIPLED IMAGE (EDIT MODE) =================
                  if (field.type == 'file' &&
                      field.multipled == true &&
                      !_multipleImageValues.containsKey(field.name)) {
                    if (field.value != null && field.value!.isNotEmpty) {
                      _multipleImageValues[field.name] =
                          field.value!.map((url) {
                        return {
                          "id": field.valueId,
                          "value": url,
                          "url": url,
                          "file": null,
                        };
                      }).toList();

                      _formValues[field.name] =
                          _multipleImageValues[field.name];
                    } else {
                      _multipleImageValues[field.name] = [];
                    }
                  }

                  final images = _multipleImageValues[field.name] ?? [];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        field.label,
                        style: TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 13.sp),
                      ),
                      SizedBox(height: 8.h),

                      // BUTTON PICK
                      ElevatedButton.icon(
                        onPressed: () => _pickMultipleImages(field.name),
                        icon: const Icon(Icons.upload_file),
                        label: const Text("Pilih Gambar"),
                      ),

                      SizedBox(height: 12.h),

                      if (images.isNotEmpty)
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: images.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8.w,
                            mainAxisSpacing: 8.h,
                          ),
                          itemBuilder: (context, i) {
                            final item = images[i];
                            final File? file = item["file"];
                            final String? url = item["url"];

                            return Stack(
                              children: [
                                // IMAGE
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(8.r),
                                  child: file != null
                                      ? Image.file(
                                          file,
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        )
                                      : Image.network(
                                          url!.startsWith('http')
                                              ? url
                                              : '$baseImage$url',
                                          fit: BoxFit.cover,
                                          width: double.infinity,
                                          height: double.infinity,
                                        ),
                                ),

                                // DELETE
                                Positioned(
                                  top: 4,
                                  right: 4,
                                  child: GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        images.removeAt(i);

                                        if (images.isEmpty) {
                                          _multipleImageValues
                                              .remove(field.name);
                                          _formValues.remove(field.name);
                                        } else {
                                          _formValues[field.name] = images;
                                        }
                                      });
                                    },
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        color: Colors.black54,
                                        shape: BoxShape.circle,
                                      ),
                                      padding: const EdgeInsets.all(4),
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
                      SizedBox(height: 16.h),
                    ],
                  );
                }

                /// ================= SINGLE IMAGE =================
                if (field.type == 'file' && field.multipled != true) {
                  if (!_singleImageValues.containsKey(field.name)) {
                    final initialValue =
                        (field.value != null && field.value!.isNotEmpty)
                            ? field.value!.first
                            : null;

                    _singleImageValues[field.name] = {
                      "id": field.valueId,
                      "value": initialValue,
                      "file": null,
                    };

                    _formValues[field.name] = _singleImageValues[field.name];
                  }

                  final item = _singleImageValues[field.name]!;
                  final File? file = item["file"];
                  final String? value = item["value"];

                  final baseImage = dotenv.env['DEVBASEIMAGE'] ?? '';

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
                      GestureDetector(
                        onTap: () async {
                          final picked = await _pickImage();
                          if (picked != null) {
                            setState(() {
                              item["file"] = picked;
                              item["value"] = picked.path;
                              _formValues[field.name] = item;
                            });
                          }
                        },
                        child: Container(
                          width: 120.w,
                          height: 120.w,
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: file != null
                                ? Image.file(
                                    file,
                                    fit: BoxFit.cover,
                                  )
                                : (value != null && value.isNotEmpty)
                                    ? Image.network(
                                        value.startsWith('http')
                                            ? value
                                            : '$baseImage$value',
                                        fit: BoxFit.cover,
                                      )
                                    : const Icon(Icons.camera_alt, size: 40),
                          ),
                        ),
                      ),
                      if (field.required == true && value == null)
                        Padding(
                          padding: EdgeInsets.only(top: 6.h),
                          child: Text(
                            '${field.label} wajib diisi',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 11.sp,
                            ),
                          ),
                        ),
                      SizedBox(height: 16.h),
                    ],
                  );
                }

                return Text("Tipe ${field.type} belum didukung");
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
                  label: Text(
                    "Submit Form",
                    style: TextStyle(
                      fontSize: 16.sp,
                      color: AppColors.textLight,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(vertical: 12.h),
                    backgroundColor: AppColors.primaryLight,
                  ),
                ),
              ),
            ],
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
