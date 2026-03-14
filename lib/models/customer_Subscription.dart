class CustomerSubscription {
  final int id;
  final int? branchId;
  final int? zoneId;
  final String? odpId;
  final String name;
  final String? phone;
  final String? address;
  final String? latitude;
  final String? longitude;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  CustomerSubscription({
    required this.id,
    this.branchId,
    this.zoneId,
    this.odpId,
    required this.name,
    this.phone,
    this.address,
    this.latitude,
    this.longitude,
    this.createdAt,
    this.updatedAt,
  });

  factory CustomerSubscription.fromJson(Map<String, dynamic> json) {
    return CustomerSubscription(
      id: int.tryParse(json['id'].toString()) ?? 0,
      branchId: json['branch_id'] != null
          ? int.tryParse(json['branch_id'].toString())
          : null,
      zoneId: json['zone_id'] != null
          ? int.tryParse(json['zone_id'].toString())
          : null,
      odpId: json['odp_id']?.toString(),
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString(),
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'branch_id': branchId,
      'zone_id': zoneId,
      'odp_id': odpId,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
