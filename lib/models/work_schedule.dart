import 'employee.dart';

class WorkSchedule {
  final int id;
  final Employee? employee;
  final Shift? shift;
  final String scheduleDate;
  final String status;
  final String createdAt;

  WorkSchedule({
    required this.id,
    this.employee,
    this.shift,
    required this.scheduleDate,
    required this.status,
    required this.createdAt,
  });

  factory WorkSchedule.fromJson(Map<String, dynamic> json) {
    return WorkSchedule(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      employee: json['employee'] != null ? Employee.fromJson(json['employee'] as Map<String, dynamic>) : null,
      shift: json['shift'] != null ? Shift.fromJson(json['shift'] as Map<String, dynamic>) : null,
      scheduleDate: json['date']?.toString() ?? json['schedule_date']?.toString() ?? '',
      status: json['status']?.toString() ?? 'work',
      createdAt: json['created_at']?.toString() ?? '',
    );
  }
}

class Shift {
  final int id;
  final String code;
  final String name;
  final String startTime;
  final String endTime;
  final bool status;

  Shift({
    required this.id,
    required this.code,
    required this.name,
    required this.startTime,
    required this.endTime,
    required this.status,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'] is String ? int.parse(json['id']) : json['id'] as int,
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      startTime: json['shift_start']?.toString() ?? json['start_time']?.toString() ?? '',
      endTime: json['shift_end']?.toString() ?? json['end_time']?.toString() ?? '',
      status: json['status'] == 1 || json['status'] == true,
    );
  }
}