import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/user_model.dart';
import 'package:evelyn/services/user_service.dart';
import 'package:evelyn/services/firebase_functions_service.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final UserService _userService = UserService();
  final FirebaseFunctionsService _functionsService = FirebaseFunctionsService();

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

  // Registrar nuevo usuario con email y contraseña
  Future<UserModel?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    required String department,
    String role = 'user',
  }) async {
    try {
      final UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final User? user = result.user;

      if (user != null) {
        // Crear modelo de usuario
        final userModel = UserModel(
          id: user.uid,
          email: email,
          name: name,
          role: role,
          department: department,
        );

        // Guardar en Firestore
        await _userService.createOrUpdateUser(userModel);

        // Actualizar display name en Firebase Auth
        await user.updateDisplayName(name);

        return userModel;
      }
      return null;
    } catch (e) {
      print('Error en registro: $e');
      throw _getAuthErrorMessage(e);
    }
  }

  // Recuperar contraseña por email
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } catch (e) {
      print('Error al enviar email de recuperación: $e');
      throw _getAuthErrorMessage(e);
    }
  }

  // Iniciar sesión con código de empleado y número de cédula
  Future<UserModel?> signInWithEmployeeCode({
    required String employeeCode,
    required String cedula,
  }) async {
    try {
      // Usar Firebase Functions para autenticación segura
      final result = await _functionsService.authenticateEmployee(
        employeeCode: employeeCode,
        cedula: cedula,
      );

      if (result != null && result['success'] == true) {
        final userData = result['user'] as Map<String, dynamic>;

        // Crear modelo de usuario
        final userModel = UserModel(
          id: userData['id'] as String,
          email: userData['email'] as String,
          name: userData['name'] as String,
          role: userData['role'] as String,
          department: userData['department'] as String,
        );

        return userModel;
      } else {
        throw Exception('Empleado no encontrado o credenciales incorrectas');
      }
    } catch (e) {
      print('Error en autenticación con código de empleado: $e');
      throw e;
    }
  }

  // Verificar si un código de empleado existe
  Future<bool> verifyEmployeeCode(String employeeCode) async {
    try {
      return await _functionsService.verifyEmployeeCode(employeeCode);
    } catch (e) {
      print('Error al verificar código de empleado: $e');
      return false;
    }
  }

  // Obtener información del empleado por código
  Future<Map<String, dynamic>?> getEmployeeByCode(String employeeCode) async {
    try {
      return await _functionsService.getEmployeeByCode(employeeCode);
    } catch (e) {
      print('Error al obtener empleado: $e');
      return null;
    }
  }

  // Actualizar perfil de usuario
  Future<bool> updateUserProfile({
    required String uid,
    String? name,
    String? department,
    String? email,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Actualizar en Firebase Auth si es necesario
      if (email != null && email != user.email) {
        await user.updateEmail(email);
      }
      if (name != null && name != user.displayName) {
        await user.updateDisplayName(name);
      }

      // Actualizar en Firestore
      final userModel = await _userService.getUserById(uid);
      if (userModel != null) {
        final updatedUser = UserModel(
          id: userModel.id,
          email: email ?? userModel.email,
          name: name ?? userModel.name,
          role: userModel.role,
          department: department ?? userModel.department,
        );

        return await _userService.createOrUpdateUser(updatedUser);
      }

      return false;
    } catch (e) {
      print('Error al actualizar perfil: $e');
      return false;
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user == null) return false;

      // Reautenticar usuario
      final credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );

      await user.reauthenticateWithCredential(credential);

      // Cambiar contraseña
      await user.updatePassword(newPassword);

      return true;
    } catch (e) {
      print('Error al cambiar contraseña: $e');
      return false;
    }
  }

  // Obtener mensaje de error amigable
  String _getAuthErrorMessage(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No existe una cuenta con este correo electrónico';
        case 'wrong-password':
          return 'Contraseña incorrecta';
        case 'email-already-in-use':
          return 'Ya existe una cuenta con este correo electrónico';
        case 'weak-password':
          return 'La contraseña es muy débil';
        case 'invalid-email':
          return 'El correo electrónico no es válido';
        case 'user-disabled':
          return 'Esta cuenta ha sido deshabilitada';
        case 'too-many-requests':
          return 'Demasiados intentos fallidos. Intenta más tarde';
        case 'operation-not-allowed':
          return 'Esta operación no está permitida';
        default:
          return 'Error de autenticación: ${error.message}';
      }
    }
    return 'Error inesperado: $error';
  }
}
