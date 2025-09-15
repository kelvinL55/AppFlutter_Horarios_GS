import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_application_1/models/user_model.dart';
import 'package:flutter_application_1/services/user_service.dart';

class FirestoreSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final UserService _userService = UserService();

  // Usuarios de ejemplo para sembrar en Firestore
  static final List<UserModel> _sampleUsers = [
    UserModel(
      id: '1H9moElLzdQULSAdstIAbjg3Xah1',
      email: 'user1@example.com',
      name: 'María González',
      role: 'user',
      department: 'Ventas',
    ),
    UserModel(
      id: '42P0T9DF2kUFY6SIzu393KJwhgv1',
      email: 'gi.kelvi@gmail.com',
      name: 'Kelvin Administrador',
      role: 'admin',
      department: 'Administración',
    ),
    UserModel(
      id: 'user_2_id_example',
      email: 'juan.perez@company.com',
      name: 'Juan Pérez',
      role: 'user',
      department: 'Marketing',
    ),
    UserModel(
      id: 'user_3_id_example',
      email: 'ana.rodriguez@company.com',
      name: 'Ana Rodríguez',
      role: 'user',
      department: 'Recursos Humanos',
    ),
    UserModel(
      id: 'admin_2_id_example',
      email: 'admin@company.com',
      name: 'Carlos Supervisor',
      role: 'admin',
      department: 'Operaciones',
    ),
  ];

  // Sembrar usuarios de ejemplo en Firestore
  static Future<bool> seedUsers() async {
    try {
      print('🌱 Sembrando usuarios en Firestore...');

      for (final user in _sampleUsers) {
        await _userService.createOrUpdateUser(user);
        print('✅ Usuario creado: ${user.name} (${user.email})');
      }

      print('🎉 ¡Usuarios sembrados exitosamente!');
      return true;
    } catch (e) {
      print('❌ Error al sembrar usuarios: $e');
      return false;
    }
  }

  // Verificar si ya existen usuarios en Firestore
  static Future<bool> checkIfUsersExist() async {
    try {
      final snapshot = await _firestore.collection('users').limit(1).get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar usuarios: $e');
      return false;
    }
  }

  // Sembrar solo si no hay usuarios
  static Future<void> seedIfEmpty() async {
    try {
      final usersExist = await checkIfUsersExist();
      if (!usersExist) {
        print('📭 No hay usuarios en Firestore. Sembrando datos de ejemplo...');
        await seedUsers();
      } else {
        print('👥 Ya existen usuarios en Firestore.');
      }
    } catch (e) {
      print('Error en seedIfEmpty: $e');
    }
  }

  // Obtener lista de todos los usuarios (para debug)
  static Future<List<UserModel>> getAllUsers() async {
    try {
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error al obtener usuarios: $e');
      return [];
    }
  }

  // Limpiar todos los usuarios (solo para desarrollo)
  static Future<void> clearAllUsers() async {
    try {
      print('🗑️ Limpiando todos los usuarios...');
      final snapshot = await _firestore.collection('users').get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
      print('✅ Usuarios eliminados');
    } catch (e) {
      print('❌ Error al limpiar usuarios: $e');
    }
  }
}
