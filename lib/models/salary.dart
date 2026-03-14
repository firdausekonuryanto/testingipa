class Salary {
  final int id;
  final int employeeId;
  final String employeeName;
  final String salaryMonth;
  final String basicSalaryAmount;
  final String bonus;
  final String deduction;
  final String allowance;
  final String totalSalary;
  final int paymentStatus;
  final String createdAt;
  final List<Deduction> deductions;
  final List<Allowance> allowances;

  Salary({
    required this.id,
    required this.employeeId,
    required this.employeeName,
    required this.salaryMonth,
    required this.basicSalaryAmount,
    required this.bonus,
    required this.deduction,
    required this.allowance,
    required this.totalSalary,
    required this.paymentStatus,
    required this.createdAt,
    required this.deductions,
    required this.allowances,
  });

  factory Salary.fromJson(Map<String, dynamic> json) {
    return Salary(
      id: json['id'],
      employeeId: int.tryParse(json['employee_id'].toString()) ?? 0,
      employeeName: json['employee_name'] ?? '',
      salaryMonth: json['salary_month'] ?? '',
      basicSalaryAmount: json['basic_salary_amount'] ?? '0',
      bonus: json['bonus'] ?? '0',
      deduction: json['deduction'] ?? '0',
      allowance: json['allowance'] ?? '0',
      totalSalary: json['total_salary'] ?? '0',
      paymentStatus: int.tryParse(json['payment_status'].toString()) ?? 0,
      createdAt: json['created_at'] ?? '',
      deductions: (json['deductions'] as List?)
              ?.map((e) => Deduction.fromJson(e))
              .toList() ??
          [],
      allowances: (json['allowances'] as List?)
              ?.map((e) => Allowance.fromJson(e))
              .toList() ??
          [],
    );
  }

  @override
  String toString() {
    final deductionList = deductions.isNotEmpty
        ? deductions.map((d) => '- ${d.name}: ${d.amount}').join('\n')
        : '- Tidak ada potongan';
    final allowanceList = allowances.isNotEmpty
        ? allowances.map((a) => '- ${a.name}: ${a.amount}').join('\n')
        : '- Tidak ada tunjangan';

    return '''
Salary {
  id: $id,
  employee: $employeeName,
  salaryMonth: $salaryMonth,
  basicSalary: $basicSalaryAmount,
  bonus: $bonus,
  totalSalary: $totalSalary,
  paymentStatus: $paymentStatus,
  createdAt: $createdAt,
  Deductions:
    $deductionList
  Allowances:
    $allowanceList
}
''';
  }
}

class Deduction {
  final String name;
  final String amount;

  Deduction({
    required this.name,
    required this.amount,
  });

  factory Deduction.fromJson(Map<String, dynamic> json) {
    return Deduction(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '0',
    );
  }
}

class Allowance {
  final String name;
  final String amount;

  Allowance({
    required this.name,
    required this.amount,
  });

  factory Allowance.fromJson(Map<String, dynamic> json) {
    return Allowance(
      name: json['name'] ?? '',
      amount: json['amount'] ?? '0',
    );
  }
}
