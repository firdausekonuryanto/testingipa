import 'company.dart';
import 'position.dart';
import 'departement.dart';

class Employee {
  final int id;
  final String name;
  final Position? position;
  final Department? department;
  final Company? company;
  final String? gender;
  final String? phone;
  final String? address;

  Employee({
    required this.id,
    required this.name,
    required this.gender,
    required this.phone,
    required this.address,
    this.position,
    this.department,
    this.company,
  });

  factory Employee.fromJson(Map<String, dynamic> json) {
    return Employee(
      id: json['id'],
      name: json['name'],
      gender: json['gender'],
      phone: json['phone'],
      address: json['address'],
      position:
          json['position'] != null ? Position.fromJson(json['position']) : null,
      department: json['department'] != null
          ? Department.fromJson(json['department'])
          : null,
      company:
          json['company'] != null ? Company.fromJson(json['company']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'gender': gender,
      'phone': phone,
      'address': address,
      'position': position?.toJson(),
      'department': department?.toJson(),
      'company': company?.toJson(),
    };
  }
}
