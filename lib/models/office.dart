class Office {
  final int id;
  final int companyId;
  final String name;
  final String? address;
  final String? latitude;
  final String? longitude;

  Office({
    required this.id,
    required this.companyId,
    required this.name,
    this.address,
    this.latitude,
    this.longitude,
  });

  factory Office.fromJson(Map<String, dynamic> json) {
    return Office(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      companyId: json['company_id'] is String
          ? int.parse(json['company_id'])
          : json['company_id'] as int,
      name: json['name']?.toString() ?? '',
      address: json['address']?.toString(),
      latitude: json['latitude']?.toString(),
      longitude: json['longitude']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'company_id': companyId,
      'name': name,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
    };
  }
}
