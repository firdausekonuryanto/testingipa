class Customer {
  final int id;
  final int odpId;
  final String name;
  final String phone;
  final String address;
  final String latitude;
  final String longitude;
  final String createdAt;
  final String userCreated;
  final String purpose;
  final List<Technician> technicians;
  final Zone? zone;
  final Branch? branch;
  final List<TransactionProduct> transactionProducts;
  final String type;

  Customer({
    required this.id,
    required this.odpId,
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.createdAt,
    required this.userCreated,
    required this.purpose,
    required this.technicians,
    required this.type,
    this.zone,
    this.branch,
    required this.transactionProducts,
  });

  factory Customer.fromJson(Map<String, dynamic> json) {
    return Customer(
      id: json['id'] as int,
      odpId: json['odp_id'] as int,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      latitude: json['latitude']?.toString() ?? '',
      longitude: json['longitude']?.toString() ?? '',
      createdAt: json['created_at']?.toString() ?? '',
      userCreated: json['user_created']?.toString() ?? '',
      purpose: json['purpose']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
      technicians: (json['technicians'] as List<dynamic>?)
              ?.map((e) => Technician.fromJson(e))
              .toList() ??
          [],
      zone: json['zone'] != null ? Zone.fromJson(json['zone']) : null,
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      transactionProducts: (json['transaction_products'] as List<dynamic>?)
              ?.map((e) => TransactionProduct.fromJson(e))
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "odp_id": odpId,
      "name": name,
      "phone": phone,
      "address": address,
      "latitude": latitude,
      "longitude": longitude,
      "created_at": createdAt,
      "user_created": userCreated,
      "purpose": purpose,
      "type": type,
      "technicians": technicians.map((e) => e.toJson()).toList(),
      "zone": zone?.toJson(),
      "branch": branch?.toJson(),
      "transaction_products":
          transactionProducts.map((e) => e.toJson()).toList(),
    };
  }
}

class Technician {
  final int id;
  final String name;

  Technician({required this.id, required this.name});

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as int,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }
}

class Zone {
  final int? id;
  final String name;

  Zone({this.id, required this.name});

  factory Zone.fromJson(Map<String, dynamic> json) {
    return Zone(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class Branch {
  final int? id;
  final String name;

  Branch({this.id, required this.name});

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int?,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
    };
  }
}

class TransactionProduct {
  final String productName;
  final int quantity;
  final String snModem;

  TransactionProduct(
      {required this.productName,
      required this.quantity,
      required this.snModem});

  factory TransactionProduct.fromJson(Map<String, dynamic> json) {
    return TransactionProduct(
      productName: json['product_name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity'] as String) ?? 0,
      snModem: json['sn_modem']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "product_name": productName,
      "quantity": quantity,
      "sn_modem": snModem,
    };
  }
}
