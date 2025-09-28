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

  // Cache para usuarios consultados recientemente
  static final Map<String, UserModel> _userCache = {};
  static const Duration _cacheExpiration = Duration(minutes: 5);
  static final Map<String, DateTime> _cacheTimestamps = {};

  // Obtener usuario por email con cache
  Future<UserModel?> getUserByEmail(String email) async {
    try {
      // Verificar cache primero
      if (_userCache.containsKey(email)) {
        final timestamp = _cacheTimestamps[email];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _cacheExpiration) {
          print('📦 Usuario encontrado en cache: $email');
          return _userCache[email];
        } else {
          // Cache expirado, limpiar
          _userCache.remove(email);
          _cacheTimestamps.remove(email);
        }
      }

      print('🔍 Buscando en Firestore por email: $email');

      // Buscar en paralelo por ambos campos para mayor eficiencia
      final futures = await Future.wait([
        _firestore
            .collection(_collection)
            .where('email', isEqualTo: email)
            .limit(1)
            .get(),
        _firestore
            .collection(_collection)
            .where('correo', isEqualTo: email)
            .limit(1)
            .get(),
      ]);

      final emailQuery = futures[0];
      final correoQuery = futures[1];

      QuerySnapshot? resultQuery;
      if (emailQuery.docs.isNotEmpty) {
        resultQuery = emailQuery;
        print('📊 Usuario encontrado por campo "email"');
      } else if (correoQuery.docs.isNotEmpty) {
        resultQuery = correoQuery;
        print('📊 Usuario encontrado por campo "correo"');
      }

      if (resultQuery != null && resultQuery.docs.isNotEmpty) {
        final doc = resultQuery.docs.first;
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;

        final user = UserModel.fromMap(data);

        // Guardar en cache
        _userCache[email] = user;
        _cacheTimestamps[email] = DateTime.now();

        print('✅ Usuario encontrado y cacheado: ${user.name}');
        return user;
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
