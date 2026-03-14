class Leave {
  final int id;
  final int employeeId;
  final String name;
  final String position;
  final String department;
  final String status;
  final String dateRange;
  final String type;
  final String reason;
  final String rejectionReason;
  final String medicalImage;
  final int year;
  final String dateSubmitted;

  Leave({
    required this.id,
    required this.employeeId,
    required this.name,
    required this.position,
    required this.department,
    required this.status,
    required this.dateRange,
    required this.type,
    required this.reason,
    required this.rejectionReason,
    required this.medicalImage,
    required this.year,
    required this.dateSubmitted,
  });

  factory Leave.fromJson(Map<String, dynamic> json) {
    return Leave(
        id: json['id'],
        employeeId: json['employeeId'],
        name: json['name'],
        position: json['position'],
        department: json['department'],
        status: json['status'],
        dateRange: json['daterange'],
        type: json['type'],
        reason: json['reason'],
        rejectionReason: json['rejectionReason'] ?? "-",
        medicalImage: json['medicalImage'] ?? "-",
        year: int.parse(json['year'].toString()),
        dateSubmitted: json['dateSubmitted'] ?? "-");
  }
}

class LeaveResume {
  final String type;
  final int total;

  LeaveResume({
    required this.type,
    required this.total,
  });

  factory LeaveResume.fromJson(Map<String, dynamic> json) {
    return LeaveResume(
      type: json['type'],
      total: json['total'],
    );
  }
}

class LeaveResponse {
  final List<Leave> leaves;
  final List<LeaveResume> resume;

  LeaveResponse({
    required this.leaves,
    required this.resume,
  });

  factory LeaveResponse.fromJson(Map<String, dynamic> json) {
    final dataJson = json['data'] ?? {};
    final leavesList = (dataJson['data'] as List<dynamic>)
        .map((e) => Leave.fromJson(e))
        .toList();

    final resumeList = (dataJson['resume'] as List<dynamic>)
        .map((e) => LeaveResume.fromJson(e))
        .toList();

    return LeaveResponse(
      leaves: leavesList,
      resume: resumeList,
    );
  }
}
