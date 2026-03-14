class Assignment {
  final int id;
  final int employee_id;
  final String employee_name;
  final String period;
  final String place;

  Assignment({
    required this.id,
    required this.employee_id,
    required this.employee_name,
    required this.period,
    required this.place,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      employee_id: json['employee_id'] is String
          ? int.parse(json['employee_id'])
          : json['employee_id'] as int,
      employee_name: json['employee_name']?.toString() ?? '',
      period: json['period']?.toString() ?? '',
      place: json['place']?.toString() ?? '',
    );
  }
  @override
  String toString() {
    return 'Assignment(employee_id: $employee_id, employee_name: $employee_name, period: $period, place: $place)';
  }
}
