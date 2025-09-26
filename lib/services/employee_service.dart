import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/employee_model.dart';

class EmployeeService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employees';

  /// Obtener empleado por ID
  Future<EmployeeModel?> getEmployeeById(String employeeId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        data['id'] = query.docs.first.id;
        return EmployeeModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener empleado: $e');
      return null;
    }
  }

  /// Crear nuevo empleado
  Future<String?> createEmployee(EmployeeModel employee) async {
    try {
      // Verificar que no exista un empleado con el mismo ID
      final existing = await getEmployeeById(employee.employeeId);
      if (existing != null) {
        print('⚠️ Ya existe un empleado con ID: ${employee.employeeId}');
        return null;
      }

      final docRef = await _firestore.collection(_collection).add({
        'employeeId': employee.employeeId,
        'name': employee.name,
        'email': employee.email,
        'department': employee.department,
        'position': employee.position,
        'isActive': employee.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Empleado creado: ${employee.employeeId}');
      return docRef.id;
    } catch (e) {
      print('❌ Error al crear empleado: $e');
      return null;
    }
  }

  /// Actualizar empleado
  Future<bool> updateEmployee(EmployeeModel employee) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employee.employeeId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('⚠️ Empleado no encontrado: ${employee.employeeId}');
        return false;
      }

      await query.docs.first.reference.update({
        'name': employee.name,
        'email': employee.email,
        'department': employee.department,
        'position': employee.position,
        'isActive': employee.isActive,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Empleado actualizado: ${employee.employeeId}');
      return true;
    } catch (e) {
      print('❌ Error al actualizar empleado: $e');
      return false;
    }
  }

  /// Obtener todos los empleados activos
  Future<List<EmployeeModel>> getActiveEmployees() async {
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
      print('❌ Error al obtener empleados activos: $e');
      return [];
    }
  }

  /// Obtener empleados por departamento
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
      print('❌ Error al obtener empleados por departamento: $e');
      return [];
    }
  }

  /// Buscar empleados por nombre
  Future<List<EmployeeModel>> searchEmployeesByName(String name) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .orderBy('name')
          .startAt([name])
          .endAt([name + '\uf8ff'])
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error al buscar empleados: $e');
      return [];
    }
  }

  /// Desactivar empleado (soft delete)
  Future<bool> deactivateEmployee(String employeeId) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employeeId)
          .limit(1)
          .get();

      if (query.docs.isEmpty) {
        print('⚠️ Empleado no encontrado: $employeeId');
        return false;
      }

      await query.docs.first.reference.update({
        'isActive': false,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      print('✅ Empleado desactivado: $employeeId');
      return true;
    } catch (e) {
      print('❌ Error al desactivar empleado: $e');
      return false;
    }
  }

  /// Crear empleados masivamente (para importar desde Excel)
  Future<int> createEmployeesBatch(List<EmployeeModel> employees) async {
    int created = 0;
    final batch = _firestore.batch();

    try {
      for (final employee in employees) {
        // Verificar que no exista
        final existing = await getEmployeeById(employee.employeeId);
        if (existing == null) {
          final docRef = _firestore.collection(_collection).doc();
          batch.set(docRef, {
            'employeeId': employee.employeeId,
            'name': employee.name,
            'email': employee.email,
            'department': employee.department,
            'position': employee.position,
            'isActive': employee.isActive,
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          created++;
        }
      }

      await batch.commit();
      print('✅ Creados $created empleados en lote');
      return created;
    } catch (e) {
      print('❌ Error al crear empleados en lote: $e');
      return 0;
    }
  }

  /// Obtener estadísticas de empleados
  Future<Map<String, int>> getEmployeeStats() async {
    try {
      final allEmployees = await _firestore.collection(_collection).get();
      final activeEmployees = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      // Contar por departamentos
      final departments = <String, int>{};
      for (final doc in activeEmployees.docs) {
        final dept = doc.data()['department'] as String? ?? 'Sin departamento';
        departments[dept] = (departments[dept] ?? 0) + 1;
      }

      return {
        'total': allEmployees.docs.length,
        'active': activeEmployees.docs.length,
        'inactive': allEmployees.docs.length - activeEmployees.docs.length,
        ...departments,
      };
    } catch (e) {
      print('❌ Error al obtener estadísticas: $e');
      return {};
    }
  }

  /// Validar credenciales de empleado (para login)
  Future<EmployeeModel?> validateEmployee(String employeeId) async {
    try {
      final employee = await getEmployeeById(employeeId);
      if (employee != null && employee.isActive) {
        print('✅ Empleado validado: ${employee.name}');
        return employee;
      } else {
        print('⚠️ Empleado no encontrado o inactivo: $employeeId');
        return null;
      }
    } catch (e) {
      print('❌ Error al validar empleado: $e');
      return null;
    }
  }
}
