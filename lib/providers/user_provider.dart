import 'package:flutter/foundation.dart';
import 'package:evelyn/models/user_model.dart';
import 'package:evelyn/services/auth_service.dart';

class UserProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAdmin => _currentUser?.isAdmin ?? false;
  bool get isAuthenticated => _currentUser != null;

  // Inicializar con un usuario específico
  Future<void> initializeWithUser(String uid) async {
    _setLoading(true);
    try {
      final user = await _authService.signInAsPredefinedUser(uid);
      _setCurrentUser(user);
    } catch (e) {
      print('Error al inicializar usuario: $e');
      _setCurrentUser(null);
    } finally {
      _setLoading(false);
    }
  }

  // Cambiar usuario
  Future<void> switchUser(String uid) async {
    await initializeWithUser(uid);
  }

  // Cerrar sesión
  Future<void> signOut() async {
    await _authService.signOut();
    _setCurrentUser(null);
  }

  void _setCurrentUser(UserModel? user) {
    _currentUser = user;
    notifyListeners();
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  // Obtener información del usuario actual
  String get userName => _currentUser?.name ?? 'Usuario';
  String get userEmail => _currentUser?.email ?? '';
  String get userRole => _currentUser?.role ?? 'user';
  String get userDepartment => _currentUser?.department ?? '';
}
