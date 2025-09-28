import 'package:cloud_functions/cloud_functions.dart';
import 'package:evelyn/models/employee_model.dart';

class FirebaseFunctionsService {
  final FirebaseFunctions _functions = FirebaseFunctions.instance;

  // Autenticar empleado con código y cédula
  Future<Map<String, dynamic>?> authenticateEmployee({
    required String employeeCode,
    required String cedula,
  }) async {
    try {
      final callable = _functions.httpsCallable('authenticateEmployee');
      final result = await callable.call({
        'employeeCode': employeeCode,
        'cedula': cedula,
      });

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error en authenticateEmployee: $e');
      throw _getErrorMessage(e);
    }
  }

  // Verificar si un código de empleado existe
  Future<bool> verifyEmployeeCode(String employeeCode) async {
    try {
      final callable = _functions.httpsCallable('verifyEmployeeCode');
      final result = await callable.call({'employeeCode': employeeCode});

      final data = result.data as Map<String, dynamic>;
      return data['exists'] as bool? ?? false;
    } catch (e) {
      print('Error en verifyEmployeeCode: $e');
      return false;
    }
  }

  // Obtener información de empleado por código
  Future<Map<String, dynamic>?> getEmployeeByCode(String employeeCode) async {
    try {
      final callable = _functions.httpsCallable('getEmployeeByCode');
      final result = await callable.call({'employeeCode': employeeCode});

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error en getEmployeeByCode: $e');
      return null;
    }
  }

  // Crear nuevo empleado (solo administradores)
  Future<Map<String, dynamic>?> createEmployee(EmployeeModel employee) async {
    try {
      final callable = _functions.httpsCallable('createEmployee');
      final result = await callable.call({'employeeData': employee.toMap()});

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error en createEmployee: $e');
      throw _getErrorMessage(e);
    }
  }

  // Actualizar empleado (solo administradores)
  Future<Map<String, dynamic>?> updateEmployee({
    required String employeeId,
    required EmployeeModel employee,
  }) async {
    try {
      final callable = _functions.httpsCallable('updateEmployee');
      final result = await callable.call({
        'employeeId': employeeId,
        'employeeData': employee.toMap(),
      });

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error en updateEmployee: $e');
      throw _getErrorMessage(e);
    }
  }

  // Desactivar empleado (solo administradores)
  Future<Map<String, dynamic>?> deactivateEmployee(String employeeId) async {
    try {
      final callable = _functions.httpsCallable('deactivateEmployee');
      final result = await callable.call({'employeeId': employeeId});

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error en deactivateEmployee: $e');
      throw _getErrorMessage(e);
    }
  }

  // Obtener lista de empleados (solo administradores)
  Future<Map<String, dynamic>?> getEmployees({
    String? department,
    int limit = 50,
  }) async {
    try {
      final callable = _functions.httpsCallable('getEmployees');
      final result = await callable.call({
        'department': department,
        'limit': limit,
      });

      return result.data as Map<String, dynamic>?;
    } catch (e) {
      print('Error en getEmployees: $e');
      throw _getErrorMessage(e);
    }
  }

  // Obtener mensaje de error amigable
  String _getErrorMessage(dynamic error) {
    if (error is FirebaseFunctionsException) {
      switch (error.code) {
        case 'unauthenticated':
          return 'Usuario no autenticado';
        case 'permission-denied':
          return 'No tienes permisos para realizar esta acción';
        case 'invalid-argument':
          return 'Parámetros inválidos';
        case 'not-found':
          return 'Recurso no encontrado';
        case 'already-exists':
          return 'El recurso ya existe';
        case 'internal':
          return 'Error interno del servidor';
        default:
          return 'Error: ${error.message}';
      }
    }
    return 'Error inesperado: $error';
  }
}
