import 'package:firebase_auth/firebase_auth.dart';
import 'package:evelyn/models/user_model.dart';
import 'package:evelyn/services/user_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();

  // Stream para escuchar cambios en el estado de autenticación
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Iniciar sesión con email y contraseña
  Future<UserModel?> signInWithEmailAndPassword(
    String email,
    String password,
  ) async {
    try {
      final UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;

      if (user != null) {
        // Verificar si es un usuario predefinido
        UserModel? userModel = UserService.getPredefinedUser(user.uid);

        if (userModel != null) {
          // Es un usuario predefinido, crear/actualizar en Firestore
          await _userService.createOrUpdateUser(userModel);
          return userModel;
        } else {
          // Usuario no predefinido, intentar por email PRIMERO (más confiable)
          print('🔍 Buscando usuario por email: $email');
          userModel = await _userService.getUserByEmail(email);

          if (userModel == null) {
            print('🔍 No encontrado por email, buscando por UID: ${user.uid}');
            userModel = await _userService.getUserById(user.uid);
          }

          if (userModel != null) {
            print(
              '✅ Usuario encontrado: ${userModel.name} (${userModel.email})',
            );
            return userModel;
          } else {
            print('⚠️ Usuario no encontrado en Firestore, creando nuevo...');
            // Usuario nuevo, crear con rol por defecto
            userModel = UserModel(
              id: user.uid,
              email: user.email ?? '',
              name: user.displayName ?? 'Usuario',
              role: 'user',
              department: '',
            );
            await _userService.createOrUpdateUser(userModel);
            print('✅ Nuevo usuario creado: ${userModel.name}');
            return userModel;
          }
        }
      }
      return null;
    } catch (e) {
      print('Error en inicio de sesión: $e');
      return null;
    }
  }

  // Iniciar sesión como usuario predefinido (sin contraseña)
  Future<UserModel?> signInAsPredefinedUser(String uid) async {
    try {
      final userModel = UserService.getPredefinedUser(uid);
      if (userModel != null) {
        // Crear/actualizar usuario en Firestore
        await _userService.createOrUpdateUser(userModel);
        return userModel;
      }
      return null;
    } catch (e) {
      print('Error en inicio de sesión como usuario predefinido: $e');
      return null;
    }
  }

  // Cerrar sesión
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  // Obtener usuario actual
  User? get currentUser => _auth.currentUser;

  // Verificar si el usuario actual es administrador
  Future<bool> isCurrentUserAdmin() async {
    final user = currentUser;
    if (user != null) {
      return await _userService.isUserAdmin(user.uid);
    }
    return false;
  }
}
