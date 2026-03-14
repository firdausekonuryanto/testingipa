class WorkProducts {
  final int? id;
  final String name;
  final String? createdAt;
  final int branchId;
  final List<int> technician;
  final List<Map<String, dynamic>> itemId;
  final Transaction? transaction;
  final List<TransactionProduct> transactionProducts;

  WorkProducts({
    this.id,
    required this.name,
    this.createdAt,
    required this.branchId,
    required this.technician,
    required this.itemId,
    this.transaction,
    this.transactionProducts = const [],
  });

  factory WorkProducts.fromJson(Map<String, dynamic> json) {
    return WorkProducts(
      id: json['id'] as int?,
      name: json['name'] as String,
      createdAt: json['created_at']?.toString(),
      branchId: json['branch_id'] ?? 0,
      technician: (json['technician'] as List<dynamic>? ?? []).cast<int>(),
      itemId: (json['item_id'] as List<dynamic>? ?? [])
          .map((e) => Map<String, dynamic>.from(e))
          .toList(),
      transaction: json['transaction'] != null
          ? Transaction.fromJson(json['transaction'])
          : null,
      transactionProducts:
          (json['transaction_products'] as List<dynamic>? ?? [])
              .map((e) => TransactionProduct.fromJson(e))
              .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
      "created_at": createdAt,
      "branch_id": branchId,
      "technician": technician,
      "item_id": itemId,
      "transaction": transaction?.toJson(),
      "transaction_products":
          transactionProducts.map((e) => e.toJson()).toList(),
    };
  }
}

class Transaction {
  final int? id;
  final int userId;
  final String userName;
  final Branch? branch;
  final List<Technician> technicians;

  Transaction({
    this.id,
    required this.userId,
    required this.userName,
    this.branch,
    required this.technicians,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] as int?,
      userId: json['user_id'] as int? ?? 0,
      userName: json['user_name']?.toString() ?? '',
      branch: json['branch'] != null ? Branch.fromJson(json['branch']) : null,
      technicians: (json['technicians'] as List<dynamic>? ?? [])
          .map((e) => Technician.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "user_id": userId,
      "user_name": userName,
      "branch": branch?.toJson(),
      "technicians": technicians.map((e) => e.toJson()).toList(),
    };
  }

  @override
  String toString() =>
      "Transaction(id: $id, userId: $userId, userName: $userName, branch: ${branch?.name}, technicians: $technicians)";
}

class Branch {
  final int id;
  final String name;

  Branch({
    required this.id,
    required this.name,
  });

  factory Branch.fromJson(Map<String, dynamic> json) {
    return Branch(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }

  @override
  String toString() => "Branch(id: $id, name: $name)";
}

class Technician {
  final int id;
  final String name;

  Technician({required this.id, required this.name});

  factory Technician.fromJson(Map<String, dynamic> json) {
    return Technician(
      id: json['id'] as int? ?? 0,
      name: json['name']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "name": name,
    };
  }

  @override
  String toString() => "Technician(id: $id, name: $name)";
}

class TransactionProduct {
  final int id;
  final String productName;
  final int quantity;
  final String? snModem;

  TransactionProduct({
    required this.id,
    required this.productName,
    required this.quantity,
    this.snModem,
  });

  factory TransactionProduct.fromJson(Map<String, dynamic> json) {
    return TransactionProduct(
      id: json['id'] as int? ?? 0,
      productName: json['product_name']?.toString() ?? '',
      quantity: int.tryParse(json['quantity'] as String) ?? 0,
      snModem: json['sn_modem']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "product_name": productName,
      "quantity": quantity,
      "sn_modem": snModem,
    };
  }

  @override
  String toString() =>
      "TransactionProduct(id: $id, productName: $productName, quantity: $quantity, snModem: $snModem)";
}
