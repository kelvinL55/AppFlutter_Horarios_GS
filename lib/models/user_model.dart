class UserModel {
  final String id;
  final String email;
  final String name;
  final String role; // 'admin' o 'user'
  final String department;

  UserModel({
    required this.id,
    required this.email,
    required this.name,
    required this.role,
    required this.department,
  });

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: map['role'] ?? 'user',
      department: map['department'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'role': role,
      'department': department,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
