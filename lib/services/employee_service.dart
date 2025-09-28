import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  // Crear nuevo empleado
  Future<bool> createEmployee(EmployeeModel employee) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(employee.id)
          .set(employee.toMap());
      return true;
    } catch (e) {
      print('Error al crear empleado: $e');
      return false;
    }
  }

  // Obtener empleado por ID
  Future<EmployeeModel?> getEmployeeById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener empleado: $e');
      return null;
    }
  }

  // Obtener empleado por código de empleado
  Future<EmployeeModel?> getEmployeeByCode(String employeeCode) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeCode', isEqualTo: employeeCode)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener empleado por código: $e');
      return null;
    }
  }

  // Obtener empleado por cédula
  Future<EmployeeModel?> getEmployeeByCedula(String cedula) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('cedula', isEqualTo: cedula)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener empleado por cédula: $e');
      return null;
    }
  }

  // Verificar empleado por código y cédula
  Future<EmployeeModel?> verifyEmployee(
    String employeeCode,
    String cedula,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeCode', isEqualTo: employeeCode)
          .where('cedula', isEqualTo: cedula)
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final doc = query.docs.first;
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al verificar empleado: $e');
      return null;
    }
  }

  // Actualizar empleado
  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(employee.id)
          .update(employee.toMap());
      return true;
    } catch (e) {
      print('Error al actualizar empleado: $e');
      return false;
    }
  }

  // Desactivar empleado
  Future<bool> deactivateEmployee(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).update({
        'isActive': false,
      });
      return true;
    } catch (e) {
      print('Error al desactivar empleado: $e');
      return false;
    }
  }

  // Obtener todos los empleados activos
  Future<List<EmployeeModel>> getAllActiveEmployees() async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error al obtener empleados: $e');
      return [];
    }
  }

  // Obtener empleados por departamento
  Future<List<EmployeeModel>> getEmployeesByDepartment(
    String department,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('department', isEqualTo: department)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('Error al obtener empleados por departamento: $e');
      return [];
    }
  }

  // Verificar si un código de empleado ya existe
  Future<bool> employeeCodeExists(
    String employeeCode, {
    String? excludeId,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('employeeCode', isEqualTo: employeeCode);

      if (excludeId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
      }

      final result = await query.limit(1).get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar código de empleado: $e');
      return false;
    }
  }

  // Verificar si una cédula ya existe
  Future<bool> cedulaExists(String cedula, {String? excludeId}) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('cedula', isEqualTo: cedula);

      if (excludeId != null) {
        query = query.where(FieldPath.documentId, isNotEqualTo: excludeId);
      }

      final result = await query.limit(1).get();
      return result.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar cédula: $e');
      return false;
    }
  }

  // Cache para búsquedas de empleados
  static final Map<String, List<EmployeeModel>> _searchCache = {};
  static final Map<String, DateTime> _searchCacheTimestamps = {};
  static const Duration _searchCacheExpiration = Duration(minutes: 3);

  // Buscar empleados por nombre con cache y optimización
  Future<List<EmployeeModel>> searchEmployeesByName(String name) async {
    try {
      final searchKey = name.toLowerCase().trim();

      // Verificar cache
      if (_searchCache.containsKey(searchKey)) {
        final timestamp = _searchCacheTimestamps[searchKey];
        if (timestamp != null &&
            DateTime.now().difference(timestamp) < _searchCacheExpiration) {
          print('📦 Búsqueda encontrada en cache: $searchKey');
          return _searchCache[searchKey]!;
        } else {
          _searchCache.remove(searchKey);
          _searchCacheTimestamps.remove(searchKey);
        }
      }

      // Si la búsqueda es muy corta, no hacer consulta
      if (searchKey.length < 2) {
        return [];
      }

      // Optimización: usar límite para evitar cargar todos los empleados
      final query = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .limit(50) // Limitar resultados para mejor rendimiento
          .get();

      final employees = query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }).toList();

      // Filtrar por nombre con optimización
      final filteredEmployees = employees
          .where((employee) => employee.name.toLowerCase().contains(searchKey))
          .toList();

      // Guardar en cache
      _searchCache[searchKey] = filteredEmployees;
      _searchCacheTimestamps[searchKey] = DateTime.now();

      print(
        '🔍 Búsqueda completada: ${filteredEmployees.length} empleados encontrados',
      );
      return filteredEmployees;
    } catch (e) {
      print('Error al buscar empleados: $e');
      return [];
    }
  }

  // Crear múltiples empleados en lote
  Future<int> createEmployeesBatch(List<EmployeeModel> employees) async {
    try {
      final batch = _firestore.batch();

      for (final employee in employees) {
        final docRef = _firestore.collection(_collection).doc();
        batch.set(docRef, employee.toMap());
      }

      await batch.commit();
      return employees.length;
    } catch (e) {
      print('Error al crear empleados en lote: $e');
      return 0;
    }
  }

  // Obtener estadísticas de empleados
  Future<Map<String, int>> getEmployeeStats() async {
    try {
      final query = await _firestore.collection(_collection).get();

      int total = query.docs.length;
      int active = 0;
      int inactive = 0;

      for (final doc in query.docs) {
        final data = doc.data();
        if (data['isActive'] == true) {
          active++;
        } else {
          inactive++;
        }
      }

      return {'total': total, 'active': active, 'inactive': inactive};
    } catch (e) {
      print('Error al obtener estadísticas: $e');
      return {'total': 0, 'active': 0, 'inactive': 0};
    }
  }

  // Obtener todos los empleados activos (alias para getAllActiveEmployees)
  Future<List<EmployeeModel>> getActiveEmployees() async {
    return getAllActiveEmployees();
  }
}
