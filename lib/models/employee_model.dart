class EmployeeModel {
  final String id;
  final String employeeId;
  final String employeeCode;
  final String cedula;
  final String name;
  final String email;
  final String department;
  final String position;
  final String phone;
  final DateTime? hireDate;
  final bool isActive;

  EmployeeModel({
    required this.id,
    required this.employeeId,
    required this.employeeCode,
    required this.cedula,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.phone,
    this.hireDate,
    this.isActive = true,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    return EmployeeModel(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      employeeCode: map['employeeCode'] ?? '',
      cedula: map['cedula'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      position: map['position'] ?? '',
      phone: map['phone'] ?? '',
      hireDate: map['hireDate'] != null
          ? DateTime.fromMillisecondsSinceEpoch(map['hireDate'])
          : null,
      isActive: map['isActive'] ?? true,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'employeeCode': employeeCode,
      'cedula': cedula,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      'phone': phone,
      'hireDate': hireDate?.millisecondsSinceEpoch,
      'isActive': isActive,
    };
  }

  EmployeeModel copyWith({
    String? id,
    String? employeeId,
    String? employeeCode,
    String? cedula,
    String? name,
    String? email,
    String? department,
    String? position,
    String? phone,
    DateTime? hireDate,
    bool? isActive,
  }) {
    return EmployeeModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      employeeCode: employeeCode ?? this.employeeCode,
      cedula: cedula ?? this.cedula,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      phone: phone ?? this.phone,
      hireDate: hireDate ?? this.hireDate,
      isActive: isActive ?? this.isActive,
    );
  }
}
