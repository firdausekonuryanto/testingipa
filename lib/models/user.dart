import 'employee.dart';
import 'office.dart';

class User {
  final int id;
  final String username;
  final String email;
  final bool isBlock;
  final String? picture;
  final Employee? employee;
  final Office? office;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.isBlock,
    this.picture,
    this.employee,
    this.office,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] != null
          ? (json['id'] is String ? int.parse(json['id']) : json['id'] as int)
          : 0,
      username: json['username']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      picture: json['picture']?.toString() ?? '',
      isBlock: json['is_block'] == 1 || json['is_block'] == true,
      employee:
          json['employee'] != null ? Employee.fromJson(json['employee']) : null,
      office: json['office'] != null ? Office.fromJson(json['office']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'picture': picture,
      'is_block': isBlock ? 1 : 0,
      'employee': employee?.toJson(),
      'office': office?.toJson(),
    };
  }

  String toString() {
    return toJson().toString();
  }
}
