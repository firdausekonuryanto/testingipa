import 'employee.dart';
import 'work_schedule.dart';

class Attendance {
  final int id;
  final Employee employee;
  final WorkSchedule? workSchedule;
  final String? clockIn;
  final String? clockOut;
  final String? shiftIn;
  final String? shiftOut;
  final String? clockInStatus;
  final String? clockOutStatus;
  final String? clockInImage;
  final String? clockOutImage;
  final List<AttendanceLocation> locations;
  final List<AttendanceNote> notes;
  final DateTime createdAt;

  Attendance({
    required this.id,
    required this.employee,
    this.workSchedule,
    this.clockIn,
    this.clockOut,
    this.shiftIn,
    this.shiftOut,
    this.clockInStatus,
    this.clockOutStatus,
    this.clockInImage,
    this.clockOutImage,
    required this.locations,
    required this.notes,
    required this.createdAt,
  });

  factory Attendance.fromJson(Map<String, dynamic> json) {
    try {
      final data = json['data'] ?? json;

      return Attendance(
        id: int.tryParse(data['id'].toString()) ?? 0,
        employee: Employee(
          id: int.tryParse(data['employee_id'].toString()) ?? 0,
          name: '',
          phone: '',
          address: '',
          gender: '',
        ),
        workSchedule: data['work_schedule'] != null
            ? WorkSchedule.fromJson(data['work_schedule'])
            : null,
        clockIn: data['clock_in']?.toString(),
        clockOut: data['clock_out']?.toString(),
        shiftIn: data['shift_in']?.toString(),
        shiftOut: data['shift_out']?.toString(),
        clockInStatus: data['clock_in_status']?.toString(),
        clockOutStatus: data['clock_out_status']?.toString(),
        clockInImage: data['clock_in_image']?.toString(),
        clockOutImage: data['clock_out_image']?.toString(),
        locations: (data['locations'] as List<dynamic>?)
                ?.map((e) => AttendanceLocation.fromJson(e))
                .toList() ??
            [],
        notes: (data['attendance_notes'] as List<dynamic>?)
                ?.map((e) => AttendanceNote.fromJson(e))
                .toList() ??
            [],
        createdAt: DateTime.parse(
            data['created_at'] ?? DateTime.now().toIso8601String()),
      );
    } catch (e) {
      throw Exception('Failed to parse Attendance: $e');
    }
  }

  @override
  String toString() {
    return 'Attendance{'
        'id: $id, '
        'employee: ${employee.toString()}, '
        'workSchedule: ${workSchedule?.toString()}, '
        'clockIn: $clockIn, '
        'clockOut: $clockOut, '
        'shiftIn: $shiftIn, '
        'shiftOut: $shiftOut, '
        'clockInStatus: $clockInStatus, '
        'clockOutStatus: $clockOutStatus, '
        'clockInImage: $clockInImage, '
        'clockOutImage: $clockOutImage, '
        'locations: ${locations.map((e) => e.toString()).toList()}, '
        'notes: ${notes.map((e) => e.toString()).toList()}, '
        'createdAt: $createdAt'
        '}';
  }
}

class AttendanceLocation {
  final int id;
  final int attendanceId;
  final String? lat;
  final String? long;
  final String? place;
  final String status;
  final String attendanceType;
  final DateTime createdAt;

  AttendanceLocation({
    required this.id,
    required this.attendanceId,
    this.lat,
    this.long,
    this.place,
    required this.status,
    required this.attendanceType,
    required this.createdAt,
  });

  factory AttendanceLocation.fromJson(Map<String, dynamic> json) {
    return AttendanceLocation(
      id: int.tryParse(json['id'].toString()) ?? 0,
      attendanceId: int.tryParse(json['attendance_id'].toString()) ?? 0,
      lat: json['lat'],
      long: json['long'],
      place: json['place'],
      status: json['status'],
      attendanceType: json['attendance_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}

class AttendanceNote {
  final int id;
  final int attendanceId;
  final String notes;
  final String attendanceType;
  final DateTime createdAt;

  AttendanceNote({
    required this.id,
    required this.attendanceId,
    required this.notes,
    required this.attendanceType,
    required this.createdAt,
  });

  factory AttendanceNote.fromJson(Map<String, dynamic> json) {
    return AttendanceNote(
      id: int.tryParse(json['id'].toString()) ?? 0,
      attendanceId: int.tryParse(json['attendance_id'].toString()) ?? 0,
      notes: json['notes'],
      attendanceType: json['attendance_type'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'attendance_id': attendanceId,
        'notes': notes,
        'attendance_type': attendanceType,
        'created_at': createdAt.toIso8601String(),
      };
}

class AttendanceMontly {
  final String month;
  final int qtyPresent;
  final int qtyAbsent;
  final int qtyOffsite;
  final int countLog;
  final String group;
  final String clockIn;
  final String clockOut;
  final String inTime;
  final String outTime;
  final String inImage;
  final String outImage;
  final String resultHours;
  final String lateInTime;
  final String lateOutTime;
  final String averageInMonth;
  final List<String> stsLocation;
  final List<String> present;
  final List<String> shift;
  final List<AllSchedule> allSchedule;
  final List<String> absent;
  final List<String> offsite;

  AttendanceMontly({
    required this.month,
    required this.qtyPresent,
    required this.qtyAbsent,
    required this.qtyOffsite,
    required this.countLog,
    required this.group,
    required this.clockIn,
    required this.clockOut,
    required this.inTime,
    required this.outTime,
    required this.inImage,
    required this.outImage,
    required this.resultHours,
    required this.lateInTime,
    required this.lateOutTime,
    required this.averageInMonth,
    required this.stsLocation,
    required this.present,
    required this.shift,
    required this.allSchedule,
    required this.absent,
    required this.offsite,
  });

  factory AttendanceMontly.fromJson(Map<String, dynamic> json) {
    return AttendanceMontly(
      month: json['month'] ?? '',
      qtyPresent: int.tryParse(json['qty_present'].toString()) ?? 0,
      qtyAbsent: int.tryParse(json['qty_absent'].toString()) ?? 0,
      qtyOffsite: int.tryParse(json['qty_offsite'].toString()) ?? 0,
      countLog: int.tryParse(json['count_log'].toString()) ?? 0,
      group: json['group'] ?? '',
      clockIn: json['clock_in'] ?? '',
      clockOut: json['clock_out'] ?? '',
      inTime: json['in_time'] ?? '',
      outTime: json['out_time'] ?? '',
      inImage: json['in_image'] ?? '',
      outImage: json['out_image'] ?? '',
      resultHours: json['result_hours'] ?? '',
      lateInTime: json['late_in_time'] ?? '',
      lateOutTime: json['late_out_time'] ?? '',
      averageInMonth: json['average_in_month'] ?? '',
      stsLocation: List<String>.from(json['sts_location'] ?? []),
      present: List<String>.from(json['present'] ?? []),
      shift: List<String>.from(json['shift'] ?? []),
      allSchedule: (json['all_schedule'] as List<dynamic>? ?? [])
          .map((e) => AllSchedule.fromJson(e))
          .toList(),
      absent: List<String>.from(json['absent'] ?? []),
      offsite: List<String>.from(json['offsite'] ?? []),
    );
  }

  Map<String, dynamic> toJson() => {
        'month': month,
        'qty_present': qtyPresent,
        'qty_absent': qtyAbsent,
        'qty_offsite': qtyOffsite,
        'count_log': countLog,
        'group': group,
        'clock_in': clockIn,
        'clock_out': clockOut,
        'in_time': inTime,
        'out_time': outTime,
        'in_image': inImage,
        'out_image': outImage,
        'result_hours': resultHours,
        'late_in_time': lateInTime,
        'late_out_time': lateOutTime,
        'average_in_month': averageInMonth,
        'sts_location': stsLocation,
        'present': present,
        'shift': shift,
        'all_schedule': allSchedule.map((e) => e.toJson()).toList(),
        'absent': absent,
        'offsite': offsite,
      };
  @override
  String toString() {
    return '''
        AttendanceMontly(
          month: $month,
          group: $group,

          qtyPresent: $qtyPresent,
          qtyAbsent: $qtyAbsent,
          qtyOffsite: $qtyOffsite,
          countLog: $countLog,

          clockIn: $clockIn,
          clockOut: $clockOut,
          inTime: $inTime,
          outTime: $outTime,

          lateInTime: $lateInTime,
          lateOutTime: $lateOutTime,
          averageInMonth: $averageInMonth,
          resultHours: $resultHours,

          inImage: $inImage,
          outImage: $outImage,

          stsLocation: ${stsLocation.join(', ')},
          present: ${present.join(', ')},
          absent: ${absent.join(', ')},
          offsite: ${offsite.join(', ')},
          shift: ${shift.join(', ')},

          allScheduleCount: ${allSchedule.length}
        )
        ''';
  }
}

class AllSchedule {
  final String date;
  final String shiftName;
  final String shiftTime;

  AllSchedule({
    required this.date,
    required this.shiftName,
    required this.shiftTime,
  });

  factory AllSchedule.fromJson(Map<String, dynamic> json) {
    return AllSchedule(
      date: json['date'] ?? '',
      shiftName: json['shift_name'] ?? '',
      shiftTime: json['shift_time'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'date': date,
        'shift_name': shiftName,
        'shift_time': shiftTime,
      };
}
