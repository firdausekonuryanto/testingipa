class ProductSubscription {
  final int id;
  final int productId;
  final int userId;
  final String name;
  final String phone;
  final String address;
  final String serialNumber;
  final String subscriptionPackage;
  final String terminationReason;
  final String? modemPhoto;
  final String? productName;
  final String? userName;
  final DateTime? createdAt;

  ProductSubscription({
    required this.id,
    required this.productId,
    required this.name,
    required this.phone,
    required this.address,
    required this.userId,
    required this.serialNumber,
    required this.subscriptionPackage,
    required this.terminationReason,
    this.modemPhoto,
    this.productName,
    this.userName,
    required this.createdAt,
  });

  factory ProductSubscription.fromJson(Map<String, dynamic> json) {
    return ProductSubscription(
      id: json['id'] as int,
      productId: int.tryParse(json['productId'].toString()) as int,
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
      userId: int.tryParse(json['userId'].toString()) as int,
      serialNumber: json['serialNumber']?.toString() ?? '',
      subscriptionPackage: json['subscriptionPackage']?.toString() ?? '',
      terminationReason: json['terminationReason']?.toString() ?? '',
      modemPhoto: json['modemPhoto']?.toString() ?? '',
      productName: json['product']?['name']?.toString(),
      userName: json['user']?['name']?.toString(),
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'].toString())
          : null,
    );
  }
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'productId': productId,
      'name': name,
      'phone': phone,
      'address': address,
      'userId': userId,
      'serialNumber': serialNumber,
      'subscriptionPackage': subscriptionPackage,
      'terminationReason': terminationReason,
      'modemPhoto': modemPhoto,
      'productName': productName,
      'userName': userName,
      'createdAt': createdAt,
    };
  }
}
