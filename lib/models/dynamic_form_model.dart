import 'dart:convert';

class DynamicForm {
  final int id;
  final String formName;
  final List<FormFieldItem> fields;

  DynamicForm({
    required this.id,
    required this.formName,
    required this.fields,
  });

  factory DynamicForm.fromJson(Map<String, dynamic> json) {
    return DynamicForm(
      id: json['id'],
      formName: json['formName'],
      fields: (json['fields'] as List)
          .map((f) => FormFieldItem.fromJson(f))
          .toList(),
    );
  }

  @override
  String toString() {
    return 'DynamicForm(id: $id, formName: "$formName", fields: $fields)';
  }
}

class FormFieldItem {
  final int id;
  final int dynamicFormId;
  final String label;
  final String name;
  final String type;
  final List<String>? options;
  final bool required;
  final bool multipled;
  final List<String>? value;
  final int? valueId;

  FormFieldItem({
    required this.id,
    required this.dynamicFormId,
    required this.label,
    required this.name,
    required this.type,
    this.options,
    this.value,
    this.required = false,
    this.multipled = false,
    this.valueId,
  });

  factory FormFieldItem.fromJson(Map<String, dynamic> json) {
    /// ================= OPTIONS =================
    List<String>? parsedOptions;
    final opt = json['options'];

    if (opt != null) {
      if (opt is List) {
        parsedOptions = opt.map((e) => e.toString()).toList();
      } else if (opt is String && opt.isNotEmpty) {
        try {
          final decoded = jsonDecode(opt);
          if (decoded is List) {
            parsedOptions = decoded.map((e) => e.toString()).toList();
          }
        } catch (_) {
          parsedOptions = opt
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    }

    List<String>? parsedValue;
    final val = json['value'];

    if (val != null) {
      if (val is List) {
        parsedValue = val.map((e) => e.toString()).toList();
      } else if (val is String && val.isNotEmpty) {
        try {
          final decoded = jsonDecode(val);
          if (decoded is List) {
            parsedValue = decoded.map((e) => e.toString()).toList();
          } else {
            parsedValue = [val];
          }
        } catch (_) {
          final cleaned = val.replaceAll('[', '').replaceAll(']', '');
          parsedValue = cleaned
              .split(',')
              .map((s) => s.trim())
              .where((s) => s.isNotEmpty)
              .toList();
        }
      }
    }

    return FormFieldItem(
      id: json['id'],
      dynamicFormId: int.tryParse(json['dynamic_form_id'].toString()) ?? 0,
      label: json['label'],
      name: json['name'],
      type: json['type'],
      options: parsedOptions,
      required: json['required'] ?? false,
      multipled: json['multipled'] ?? false,
      value: parsedValue,
      valueId: json['valueId'] is int
          ? json['valueId']
          : int.tryParse(json['valueId']?.toString() ?? ''),
    );
  }

  @override
  String toString() {
    return 'FormFieldItem('
        'id: $id, '
        'dynamicFormId: $dynamicFormId, '
        'label: $label, '
        'name: $name, '
        'type: $type, '
        'options: $options, '
        'required: $required, '
        'multipled: $multipled, '
        'value: $value, '
        'valueId: $valueId'
        ')';
  }
}

class DynamicField {
  final String name;
  final String label;
  final String type;
  final bool required;
  final bool multipled;
  final List<String>? options;

  DynamicField({
    required this.name,
    required this.label,
    required this.type,
    this.required = false,
    this.multipled = false,
    this.options,
  });

  factory DynamicField.fromJson(Map<String, dynamic> json) {
    return DynamicField(
      name: json['name'] ?? '',
      label: json['label'] ?? '',
      type: json['type'] ?? 'text',
      required: json['required'] ?? false,
      multipled: json['multipled'] ?? false,
      options:
          json['options'] != null ? List<String>.from(json['options']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'label': label,
      'type': type,
      'required': required,
      'multipled': multipled,
      'options': options,
    };
  }
}

class DynamicFormValue {
  final int id;
  final int dynamicFormResponseId;
  final String fieldName;
  final String? value;
  final DateTime createdAt;
  final DateTime updatedAt;

  DynamicFormValue({
    required this.id,
    required this.dynamicFormResponseId,
    required this.fieldName,
    required this.value,
    required this.createdAt,
    required this.updatedAt,
  });

  factory DynamicFormValue.fromJson(Map<String, dynamic> json) {
    return DynamicFormValue(
      id: json['id'],
      dynamicFormResponseId: json['dynamic_form_response_id'],
      fieldName: json['field_name'],
      value: json['value'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

class DynamicFormResponse {
  final int id;
  final String userName;
  final String formName;
  final String? imgProfile;
  final DateTime createdAt;
  final List<FormContent> content;

  DynamicFormResponse({
    required this.id,
    required this.userName,
    required this.formName,
    required this.imgProfile,
    required this.createdAt,
    required this.content,
  });

  factory DynamicFormResponse.fromJson(Map<String, dynamic> json) {
    var contentList = (json['content'] as List<dynamic>? ?? [])
        .map((e) => FormContent.fromJson(e))
        .toList();

    return DynamicFormResponse(
      id: json['id'],
      userName: json['userName'],
      formName: json['formName'],
      imgProfile: json['imgProfile'],
      createdAt: DateTime.parse(json['createdAt']),
      content: contentList,
    );
  }
  @override
  String toString() {
    return 'DynamicFormResponse(userName: "$userName", formName: "${formName ?? 'null'}", imgProfile: "$imgProfile")';
  }
}

class FormContent {
  final String fieldName;
  final dynamic value;

  FormContent({
    required this.fieldName,
    this.value,
  });

  factory FormContent.fromJson(Map<String, dynamic> json) {
    return FormContent(
      fieldName: json['fieldName'],
      value: json['value'],
    );
  }
  @override
  String toString() {
    return 'FormContent(fieldName: "$fieldName", value: "${value ?? 'null'}")';
  }
}
