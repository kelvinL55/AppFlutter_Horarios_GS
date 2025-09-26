import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ScreenTimeoutService {
  static const String _timeoutKey = 'screen_timeout_setting';

  // Opciones de tiempo de espera disponibles
  static const Map<String, Duration?> timeoutOptions = {
    '30 segundos': Duration(seconds: 30),
    '1 minuto': Duration(minutes: 1),
    '2 minutos': Duration(minutes: 2),
    '5 minutos': Duration(minutes: 5),
    '10 minutos': Duration(minutes: 10),
    '30 minutos': Duration(minutes: 30),
    '1 hora': Duration(hours: 1),
    'Nunca (mantener activa)': null, // null significa nunca apagar
  };

  // Configuración actual
  static String _currentSetting = '2 minutos'; // Valor por defecto
  static bool _isWakelockEnabled = false;

  /// Obtiene la configuración actual guardada
  static Future<String> getCurrentSetting() async {
    final prefs = await SharedPreferences.getInstance();
    _currentSetting = prefs.getString(_timeoutKey) ?? '2 minutos';
    return _currentSetting;
  }

  /// Guarda la nueva configuración
  static Future<void> setSetting(String setting) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_timeoutKey, setting);
    _currentSetting = setting;
    await _applyWakelock();
  }

  /// Aplica la configuración de wakelock
  static Future<void> _applyWakelock() async {
    try {
      final duration = timeoutOptions[_currentSetting];

      if (duration == null) {
        // "Nunca" - mantener pantalla siempre activa
        if (!_isWakelockEnabled) {
          await WakelockPlus.enable();
          _isWakelockEnabled = true;
          print('🔒 Wakelock habilitado - Pantalla siempre activa');
        }
      } else {
        // Tiempo específico - desactivar wakelock y usar tiempo del sistema
        if (_isWakelockEnabled) {
          await WakelockPlus.disable();
          _isWakelockEnabled = false;
          print(
            '🔓 Wakelock deshabilitado - Usando tiempo: ${_currentSetting}',
          );
        }

        // Nota: Para tiempos específicos menores al sistema,
        // necesitaríamos implementar un timer personalizado
        // Por ahora, solo manejamos "nunca" vs "usar sistema"
      }
    } catch (e) {
      print('❌ Error al aplicar wakelock: $e');
    }
  }

  /// Inicializa el servicio al arrancar la app
  static Future<void> initialize() async {
    await getCurrentSetting();
    await _applyWakelock();
  }

  /// Verifica si wakelock está habilitado
  static Future<bool> isWakelockEnabled() async {
    try {
      return await WakelockPlus.enabled;
    } catch (e) {
      print('❌ Error al verificar wakelock: $e');
      return false;
    }
  }

  /// Desactiva wakelock (útil al cerrar la app o cambiar configuración)
  static Future<void> disable() async {
    try {
      if (_isWakelockEnabled) {
        await WakelockPlus.disable();
        _isWakelockEnabled = false;
        print('🔓 Wakelock deshabilitado');
      }
    } catch (e) {
      print('❌ Error al deshabilitar wakelock: $e');
    }
  }

  /// Obtiene descripción del estado actual
  static String getStatusDescription() {
    if (_currentSetting == 'Nunca (mantener activa)') {
      return 'Pantalla siempre activa';
    } else {
      return 'Tiempo de espera: $_currentSetting';
    }
  }

  /// Obtiene todas las opciones disponibles
  static List<String> getAllOptions() {
    return timeoutOptions.keys.toList();
  }

  /// Obtiene la configuración actual sin cargar desde preferencias
  static String getCurrentSettingSync() {
    return _currentSetting;
  }
}
