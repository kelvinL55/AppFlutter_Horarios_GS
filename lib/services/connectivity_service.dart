import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();
  factory ConnectivityService() => _instance;
  ConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isConnected = false; // Cambiar a false por defecto
  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  // Stream para escuchar cambios de conexión
  Stream<bool> get connectionStream => _connectionController.stream;

  // Estado actual de conexión
  bool get isConnected => _isConnected;

  // Inicializar el servicio
  Future<void> initialize() async {
    // Verificar conexión inicial
    await _checkInitialConnection();

    // Escuchar cambios de conectividad
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      _onConnectivityChanged,
    );
  }

  // Verificar conexión inicial
  Future<void> _checkInitialConnection() async {
    try {
      print('🔍 Verificando conectividad inicial...');
      final connectivityResults = await _connectivity.checkConnectivity();
      print('📡 Resultados de conectividad: $connectivityResults');
      await _onConnectivityChanged(connectivityResults);
    } catch (e) {
      print('❌ Error checking initial connectivity: $e');
      _updateConnectionStatus(false);
    }
  }

  // Manejar cambios de conectividad
  Future<void> _onConnectivityChanged(List<ConnectivityResult> results) async {
    bool hasConnection = false;

    for (final result in results) {
      if (result == ConnectivityResult.mobile ||
          result == ConnectivityResult.wifi ||
          result == ConnectivityResult.ethernet) {
        hasConnection = true;
        print('✅ Conexión de red detectada: $result');
        break;
      }
    }

    print('🌐 Tiene conexión de red: $hasConnection');

    // Si hay conexión de red, verificar conectividad real a internet
    if (hasConnection) {
      print('🔍 Verificando conexión real a internet...');
      hasConnection = await _hasInternetConnection();
      print('🌍 Conexión real a internet: $hasConnection');
    }

    _updateConnectionStatus(hasConnection);
  }

  // Verificar si realmente hay conexión a internet
  Future<bool> _hasInternetConnection() async {
    try {
      // Para dispositivos móviles, usar un enfoque más simple
      // Solo verificar que tenemos conectividad de red, no internet real
      // Esto evita problemas con firewalls corporativos o restricciones de red
      print('✅ Asumiendo conexión a internet si hay conectividad de red');
      return true;

      // Código original comentado para debugging:
      /*
      final hosts = ['google.com', 'cloudflare.com', '1.1.1.1'];
 
      for (final host in hosts) {
        try {
          print('🔍 Probando host: $host');
          final result = await InternetAddress.lookup(
            host,
          ).timeout(const Duration(seconds: 3));
          if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
            print('✅ Host $host responde correctamente');
            return true;
          }
        } catch (e) {
          print('❌ Host $host falló: $e');
          continue;
        }
      }
      print('❌ Todos los hosts fallaron');
      return false;
      */
    } catch (e) {
      print('❌ Error checking internet connection: $e');
      return false;
    }
  }

  // Actualizar estado de conexión
  void _updateConnectionStatus(bool isConnected) {
    print(
      '🔄 ConnectivityService: Actualizando estado de $_isConnected a $isConnected',
    );
    if (_isConnected != isConnected) {
      _isConnected = isConnected;
      print('📢 ConnectivityService: Enviando notificación: $isConnected');
      _connectionController.add(_isConnected);
    } else {
      print('ℹ️ ConnectivityService: Estado sin cambios: $isConnected');
    }
  }

  // Verificar conexión manualmente
  Future<bool> checkConnection() async {
    try {
      final connectivityResults = await _connectivity.checkConnectivity();
      await _onConnectivityChanged(connectivityResults);
      return _isConnected;
    } catch (e) {
      print('Error checking connection: $e');
      return false;
    }
  }

  // Limpiar recursos
  void dispose() {
    _connectivitySubscription?.cancel();
    _connectionController.close();
  }
}
