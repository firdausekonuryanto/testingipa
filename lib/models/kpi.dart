class KpiResponse {
  final InformasiKaryawan informasiKaryawan;
  final RingkasanKinerja ringkasanKinerja;
  final List<HasilPerhitunganKpi> hasilPerhitunganKpi;
  final String message;

  KpiResponse({
    required this.informasiKaryawan,
    required this.ringkasanKinerja,
    required this.hasilPerhitunganKpi,
    required this.message,
  });

  factory KpiResponse.fromJson(Map<String, dynamic> json) {
    final data = json['data'] ?? {};
    return KpiResponse(
      informasiKaryawan:
          InformasiKaryawan.fromJson(data['informasi_karyawan'] ?? {}),
      ringkasanKinerja:
          RingkasanKinerja.fromJson(data['ringkasan_kinerja'] ?? {}),
      hasilPerhitunganKpi: (data['hasil_perhitungan_kpi'] as List? ?? [])
          .map((e) => HasilPerhitunganKpi.fromJson(e))
          .toList(),
      message: json['message'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "informasi_karyawan": informasiKaryawan.toJson(),
        "ringkasan_kinerja": ringkasanKinerja.toJson(),
        "hasil_perhitungan_kpi":
            hasilPerhitunganKpi.map((e) => e.toJson()).toList(),
        "message": message,
      };
}

class InformasiKaryawan {
  final int employeeId;
  final String employeeName;
  final String department;
  final String period;
  final String template;

  InformasiKaryawan({
    required this.employeeId,
    required this.employeeName,
    required this.department,
    required this.period,
    required this.template,
  });

  factory InformasiKaryawan.fromJson(Map<String, dynamic> json) {
    return InformasiKaryawan(
      employeeId: json['employeeId'] ?? 0,
      employeeName: json['employeeName'] ?? '',
      department: json['department'] ?? '',
      period: json['period'] ?? '',
      template: json['template'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "employeeId": employeeId,
        "employeeName": employeeName,
        "department": department,
        "period": period,
        "template": template,
      };
}

class listKpi {
  final int id;
  final int employeeId;
  final String employeeName;
  final String period;
  final String place;

  listKpi({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.period,
    required this.place,
  });

  factory listKpi.fromJson(Map<String, dynamic> json) {
    return listKpi(
      id: json['id'] ?? 0,
      employeeId: json['employee_id'] ?? 0,
      employeeName: json['employee_name'] ?? '',
      period: json['period'] ?? '',
      place: json['place'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "id": id,
        "employee_id": employeeId,
        "employee_name": employeeName,
        "period": period,
        "place": place,
      };

  @override
  String toString() {
    return 'listKpi(id: $id, employeeName: $employeeName, period: $period)';
  }
}

class LevelKinerja {
  final String level;
  final String color;
  final String description;

  LevelKinerja({
    required this.level,
    required this.color,
    required this.description,
  });

  factory LevelKinerja.fromJson(Map<String, dynamic> json) {
    return LevelKinerja(
      level: json['level'] ?? '',
      color: json['color'] ?? '',
      description: json['description'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "level": level,
        "color": color,
        "description": description,
      };
}

class RingkasanKinerja {
  final int tugasBelumDikerjakan;
  final LevelKinerja? level;
  final String color;
  final String description;
  final double totalSkorKpi;

  RingkasanKinerja({
    required this.tugasBelumDikerjakan,
    required this.level,
    required this.color,
    required this.description,
    required this.totalSkorKpi,
  });

  factory RingkasanKinerja.fromJson(Map<String, dynamic> json) {
    return RingkasanKinerja(
      tugasBelumDikerjakan: json['tugas_belum_dikerjakan'] ?? 0,
      level:
          json['level'] != null ? LevelKinerja.fromJson(json['level']) : null,
      color: json['color'] ?? '',
      description: json['description'] ?? '',
      totalSkorKpi: (json['total_skor_kpi'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() => {
        "tugas_belum_dikerjakan": tugasBelumDikerjakan,
        "level": level?.toJson(),
        "color": color,
        "description": description,
        "total_skor_kpi": totalSkorKpi,
      };
}

class HasilPerhitunganKpi {
  final int no;
  final String indicator;
  final String bobot;
  final int targetValue;
  final int totalTask;
  final int aktualisasi;
  final double skorKpi;
  final String? task;
  final List<DetailTask> detailTask;

  HasilPerhitunganKpi({
    required this.no,
    required this.indicator,
    required this.bobot,
    required this.targetValue,
    required this.totalTask,
    required this.aktualisasi,
    required this.skorKpi,
    this.task,
    required this.detailTask,
  });

  factory HasilPerhitunganKpi.fromJson(Map<String, dynamic> json) {
    return HasilPerhitunganKpi(
      no: json['no'] ?? 0,
      indicator: json['indicator'] ?? '',
      bobot: json['bobot'] ?? '',
      targetValue: int.tryParse(json['target_value'].toString()) ?? 0,
      totalTask: json['total_task'] ?? 0,
      aktualisasi: json['aktualisasi'] ?? 0,
      skorKpi: (json['skor_kpi'] ?? 0).toDouble(),
      task: json['task'],
      detailTask: (json['detail_task'] as List? ?? [])
          .map((e) => DetailTask.fromJson(e))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
        "no": no,
        "indicator": indicator,
        "bobot": bobot,
        "target_value": targetValue,
        "total_task": totalTask,
        "aktualisasi": aktualisasi,
        "skor_kpi": skorKpi,
        "task": task,
        "detail_task": detailTask.map((e) => e.toJson()).toList(),
      };
}

class DetailTask {
  final String taskDetailName;
  final String assignDate;
  final String place;
  final String status;

  DetailTask({
    required this.taskDetailName,
    required this.assignDate,
    required this.place,
    required this.status,
  });

  factory DetailTask.fromJson(Map<String, dynamic> json) {
    return DetailTask(
      taskDetailName: json['task_detail_name'] ?? '',
      assignDate: json['assign_date'] ?? '',
      place: json['place'] ?? '',
      status: json['status'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        "task_detail_name": taskDetailName,
        "assign_date": assignDate,
        "place": place,
        "status": status,
      };
}
