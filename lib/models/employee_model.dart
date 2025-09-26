import 'package:cloud_firestore/cloud_firestore.dart';

class EmployeeModel {
  final String employeeId;
  final String name;
  final String email;
  final String department;
  final String position;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeModel({
    required this.employeeId,
    required this.name,
    required this.email,
    required this.department,
    required this.position,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    return EmployeeModel(
      employeeId: map['employeeId'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      department: map['department'] ?? '',
      position: map['position'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'employeeId': employeeId,
      'name': name,
      'email': email,
      'department': department,
      'position': position,
      'isActive': isActive,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  EmployeeModel copyWith({
    String? employeeId,
    String? name,
    String? email,
    String? department,
    String? position,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeModel(
      employeeId: employeeId ?? this.employeeId,
      name: name ?? this.name,
      email: email ?? this.email,
      department: department ?? this.department,
      position: position ?? this.position,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EmployeeModel(employeeId: $employeeId, name: $name, department: $department, position: $position)';
  }
}
