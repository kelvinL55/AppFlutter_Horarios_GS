import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/user_model.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'users';

  // Usuarios predefinidos
  static const Map<String, Map<String, dynamic>> _predefinedUsers = {
    '1H9moElLzdQULSAdstIAbjg3Xah1': {
      'email': 'user1@example.com',
      'name': 'Usuario Común',
      'role': 'user',
      'department': 'General',
    },
    '42P0T9DF2kUFY6SIzu393KJwhgv1': {
      'email': 'gi.kelvi@gmail.com',
      'name': 'Kelvin (Administrador)',
      'role': 'admin',
      'department': 'Administración',
    },
  };

  // Obtener usuario por ID de Firebase Auth
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection(_collection).doc(uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return UserModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener usuario: $e');
      return null;
    }
  }

  // Obtener usuario por email
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      print('🔍 Buscando en Firestore por email: $email');

      // Primero buscar por campo 'email'
      var query = await _firestore
          .collection(_collection)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      print(
        '📊 Resultados búsqueda por "email": ${query.docs.length} documentos',
      );

      // Si no encuentra, buscar por campo 'correo' (compatibilidad)
      if (query.docs.isEmpty) {
        print('🔄 Buscando por campo "correo"...');
        query = await _firestore
            .collection(_collection)
            .where('correo', isEqualTo: email)
            .limit(1)
            .get();
        print(
          '📊 Resultados búsqueda por "correo": ${query.docs.length} documentos',
        );
      }

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        print('✅ Usuario encontrado: ${data}');
        return UserModel.fromMap(data);
      }

      print('❌ Usuario no encontrado en Firestore');
      return null;
    } catch (e) {
      print('Error al obtener usuario por email: $e');
      return null;
    }
  }

  // Crear o actualizar usuario
  Future<bool> createOrUpdateUser(UserModel user) async {
    try {
      await _firestore.collection(_collection).doc(user.id).set(user.toMap());
      return true;
    } catch (e) {
      print('Error al crear/actualizar usuario: $e');
      return false;
    }
  }

  // Verificar si un usuario es administrador
  Future<bool> isUserAdmin(String uid) async {
    try {
      final user = await getUserById(uid);
      return user?.isAdmin ?? false;
    } catch (e) {
      print('Error al verificar rol de administrador: $e');
      return false;
    }
  }

  // Obtener usuario predefinido por ID
  static UserModel? getPredefinedUser(String uid) {
    final userData = _predefinedUsers[uid];
    if (userData != null) {
      return UserModel(
        id: uid,
        email: userData['email']!,
        name: userData['name']!,
        role: userData['role']!,
        department: userData['department']!,
      );
    }
    return null;
  }

  // Verificar si un ID es de usuario predefinido
  static bool isPredefinedUser(String uid) {
    return _predefinedUsers.containsKey(uid);
  }

  // Obtener todos los usuarios predefinidos
  static List<UserModel> getAllPredefinedUsers() {
    return _predefinedUsers.entries.map((entry) {
      return UserModel(
        id: entry.key,
        email: entry.value['email']!,
        name: entry.value['name']!,
        role: entry.value['role']!,
        department: entry.value['department']!,
      );
    }).toList();
  }
}
