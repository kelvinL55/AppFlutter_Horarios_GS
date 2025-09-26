import 'dart:async';
import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  StreamSubscription<bool>? _connectionSubscription;

  bool _isConnected = false; // Cambiar a false por defecto
  bool _isInitialized = false;

  bool get isConnected => _isConnected;
  bool get isInitialized => _isInitialized;

  // Inicializar el provider
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      print('🔧 ConnectivityProvider: Inicializando...');
      await _connectivityService.initialize();

      // Escuchar cambios de conexión
      _connectionSubscription = _connectivityService.connectionStream.listen(
        _onConnectionChanged,
        onError: (error) {
          print('❌ ConnectivityProvider: Error en stream: $error');
        },
      );

      _isInitialized = true;
      print('✅ ConnectivityProvider: Inicializado correctamente');

      // Verificar conexión inicial después de la inicialización
      print('🔍 ConnectivityProvider: Verificando conexión inicial...');
      final hasConnection = await checkConnection();
      print('🌐 ConnectivityProvider: Conexión inicial: $hasConnection');

      notifyListeners();
    } catch (e) {
      print('❌ Error initializing connectivity provider: $e');
      _isInitialized = true;
      notifyListeners();
    }
  }

  // Manejar cambios de conexión
  void _onConnectionChanged(bool isConnected) {
    print('🔄 ConnectivityProvider: Estado de conexión cambió a: $isConnected');
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      print('📢 ConnectivityProvider: Notificando cambio de estado');
      notifyListeners();
    }
  }

  // Verificar conexión manualmente
  Future<bool> checkConnection() async {
    try {
      print('🔍 ConnectivityProvider: Verificando conexión...');
      final hasConnection = await _connectivityService.checkConnection();
      print(
        '🌐 ConnectivityProvider: Resultado de verificación: $hasConnection',
      );

      // Actualizar el estado local si es diferente
      if (_isConnected != hasConnection) {
        _isConnected = hasConnection;
        print('📢 ConnectivityProvider: Actualizando estado a: $hasConnection');
        notifyListeners();
      }

      return hasConnection;
    } catch (e) {
      print('❌ Error checking connection: $e');
      return false;
    }
  }

  // Reintentar conexión
  Future<void> retryConnection() async {
    await checkConnection();
  }

  @override
  void dispose() {
    _connectionSubscription?.cancel();
    _connectivityService.dispose();
    super.dispose();
  }
}
