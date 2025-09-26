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
      email: map['email'] ?? map['correo'] ?? '', // Compatibilidad con 'correo'
      name: map['name'] ?? map['usuario'] ?? '', // Compatibilidad con 'usuario'
      role: map['role'] ?? 'user',
      department: map['department'] ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'correo': email, // Compatibilidad con estructura existente
      'name': name,
      'usuario': name, // Compatibilidad con estructura existente
      'role': role,
      'department': department,
    };
  }

  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
