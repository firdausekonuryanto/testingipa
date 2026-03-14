class Product {
  final int id;
  final int unitId;
  final String name;
  final String description;
  final int isModem;
  final String? createdAt;
  final String? updatedAt;
  final Unit? unit;

  Product({
    required this.id,
    required this.unitId,
    required this.name,
    required this.description,
    required this.isModem,
    this.createdAt,
    this.updatedAt,
    this.unit,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? 0,
      unitId: int.tryParse(json['unit_id'].toString()) ?? 0,
      name: json['name'] ?? '-',
      description: json['description'] ?? '',
      isModem: int.tryParse(json['is_modem'].toString()) ?? 0,
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      unit: json['unit'] != null ? Unit.fromJson(json['unit']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'unit_id': unitId,
      'name': name,
      'description': description,
      'is_modem': isModem,
      'created_at': createdAt,
      'updated_at': updatedAt,
      'unit': unit?.toJson(),
    };
  }
}

class Unit {
  final int id;
  final String name;
  final String? createdAt;
  final String? updatedAt;

  Unit({
    required this.id,
    required this.name,
    this.createdAt,
    this.updatedAt,
  });

  factory Unit.fromJson(Map<String, dynamic> json) {
    return Unit(
      id: json['id'] ?? 0,
      name: json['name'] ?? '-',
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
  }
}
