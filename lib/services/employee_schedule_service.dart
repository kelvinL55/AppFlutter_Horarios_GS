import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/employee_schedule_model.dart';

class EmployeeScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'employee_schedules';

  /// Obtener horario de empleado para una semana específica
  Future<EmployeeScheduleModel?> getEmployeeSchedule(
    String employeeId,
    int weekNumber,
    int year,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employeeId)
          .where('weekNumber', isEqualTo: weekNumber)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        final data = query.docs.first.data();
        data['id'] = query.docs.first.id;
        return EmployeeScheduleModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('❌ Error al obtener horario: $e');
      return null;
    }
  }

  /// Obtener horario actual del empleado (semana actual)
  Future<EmployeeScheduleModel?> getCurrentEmployeeSchedule(
    String employeeId,
  ) async {
    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    return getEmployeeSchedule(employeeId, weekNumber, now.year);
  }

  /// Crear o actualizar horario de empleado
  Future<String?> createOrUpdateSchedule(EmployeeScheduleModel schedule) async {
    try {
      // Buscar si ya existe un horario para esa semana
      final existing = await getEmployeeSchedule(
        schedule.employeeId,
        schedule.weekNumber,
        schedule.year,
      );

      if (existing != null) {
        // Actualizar existente
        final query = await _firestore
            .collection(_collection)
            .where('employeeId', isEqualTo: schedule.employeeId)
            .where('weekNumber', isEqualTo: schedule.weekNumber)
            .where('year', isEqualTo: schedule.year)
            .limit(1)
            .get();

        if (query.docs.isNotEmpty) {
          await query.docs.first.reference.update({
            'schedule': {
              'monday': schedule.monday.toMap(),
              'tuesday': schedule.tuesday.toMap(),
              'wednesday': schedule.wednesday.toMap(),
              'thursday': schedule.thursday.toMap(),
              'friday': schedule.friday.toMap(),
              'saturday': schedule.saturday.toMap(),
              'sunday': schedule.sunday.toMap(),
            },
            'updatedAt': FieldValue.serverTimestamp(),
          });
          print(
            '✅ Horario actualizado: ${schedule.employeeId} - Semana ${schedule.weekNumber}',
          );
          return query.docs.first.id;
        }
      } else {
        // Crear nuevo
        final docRef = await _firestore.collection(_collection).add({
          'employeeId': schedule.employeeId,
          'weekNumber': schedule.weekNumber,
          'year': schedule.year,
          'schedule': {
            'monday': schedule.monday.toMap(),
            'tuesday': schedule.tuesday.toMap(),
            'wednesday': schedule.wednesday.toMap(),
            'thursday': schedule.thursday.toMap(),
            'friday': schedule.friday.toMap(),
            'saturday': schedule.saturday.toMap(),
            'sunday': schedule.sunday.toMap(),
          },
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        });
        print(
          '✅ Horario creado: ${schedule.employeeId} - Semana ${schedule.weekNumber}',
        );
        return docRef.id;
      }
      return null;
    } catch (e) {
      print('❌ Error al crear/actualizar horario: $e');
      return null;
    }
  }

  /// Obtener todos los horarios de un empleado
  Future<List<EmployeeScheduleModel>> getEmployeeSchedules(
    String employeeId,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employeeId)
          .orderBy('year', descending: true)
          .orderBy('weekNumber', descending: true)
          .get();

      return query.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return EmployeeScheduleModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error al obtener horarios del empleado: $e');
      return [];
    }
  }

  /// Obtener horarios de múltiples empleados para una semana
  Future<List<EmployeeScheduleModel>> getSchedulesForWeek(
    int weekNumber,
    int year, {
    List<String>? employeeIds,
  }) async {
    try {
      Query query = _firestore
          .collection(_collection)
          .where('weekNumber', isEqualTo: weekNumber)
          .where('year', isEqualTo: year);

      if (employeeIds != null && employeeIds.isNotEmpty) {
        query = query.where('employeeId', whereIn: employeeIds);
      }

      final result = await query.get();

      return result.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return EmployeeScheduleModel.fromMap(data);
      }).toList();
    } catch (e) {
      print('❌ Error al obtener horarios de la semana: $e');
      return [];
    }
  }

  /// Crear horarios masivamente (para importar desde Excel)
  Future<int> createSchedulesBatch(
    List<EmployeeScheduleModel> schedules,
  ) async {
    int created = 0;
    final batch = _firestore.batch();

    try {
      for (final schedule in schedules) {
        // Verificar que no exista
        final existing = await getEmployeeSchedule(
          schedule.employeeId,
          schedule.weekNumber,
          schedule.year,
        );

        if (existing == null) {
          final docRef = _firestore.collection(_collection).doc();
          batch.set(docRef, {
            'employeeId': schedule.employeeId,
            'weekNumber': schedule.weekNumber,
            'year': schedule.year,
            'schedule': {
              'monday': schedule.monday.toMap(),
              'tuesday': schedule.tuesday.toMap(),
              'wednesday': schedule.wednesday.toMap(),
              'thursday': schedule.thursday.toMap(),
              'friday': schedule.friday.toMap(),
              'saturday': schedule.saturday.toMap(),
              'sunday': schedule.sunday.toMap(),
            },
            'createdAt': FieldValue.serverTimestamp(),
            'updatedAt': FieldValue.serverTimestamp(),
          });
          created++;
        }
      }

      await batch.commit();
      print('✅ Creados $created horarios en lote');
      return created;
    } catch (e) {
      print('❌ Error al crear horarios en lote: $e');
      return 0;
    }
  }

  /// Eliminar horario
  Future<bool> deleteSchedule(
    String employeeId,
    int weekNumber,
    int year,
  ) async {
    try {
      final query = await _firestore
          .collection(_collection)
          .where('employeeId', isEqualTo: employeeId)
          .where('weekNumber', isEqualTo: weekNumber)
          .where('year', isEqualTo: year)
          .limit(1)
          .get();

      if (query.docs.isNotEmpty) {
        await query.docs.first.reference.delete();
        print('✅ Horario eliminado: $employeeId - Semana $weekNumber');
        return true;
      }
      return false;
    } catch (e) {
      print('❌ Error al eliminar horario: $e');
      return false;
    }
  }

  /// Obtener número de semana del año
  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final dayOfYear = date.difference(startOfYear).inDays + 1;
    return ((dayOfYear - 1) / 7).floor() + 1;
  }

  /// Obtener fecha de inicio de una semana específica
  DateTime getWeekStartDate(int weekNumber, int year) {
    final startOfYear = DateTime(year, 1, 1);
    final daysToAdd = (weekNumber - 1) * 7;
    final weekStart = startOfYear.add(Duration(days: daysToAdd));

    // Ajustar al lunes de esa semana
    final daysFromMonday = weekStart.weekday - 1;
    return weekStart.subtract(Duration(days: daysFromMonday));
  }

  /// Obtener información de la semana actual
  Map<String, dynamic> getCurrentWeekInfo() {
    final now = DateTime.now();
    final weekNumber = _getWeekNumber(now);
    final weekStart = getWeekStartDate(weekNumber, now.year);
    final weekEnd = weekStart.add(Duration(days: 6));

    return {
      'weekNumber': weekNumber,
      'year': now.year,
      'startDate': weekStart,
      'endDate': weekEnd,
      'isCurrentWeek': true,
    };
  }

  /// Crear horario estándar para un empleado (todas las semanas del año)
  Future<int> createStandardYearSchedule(
    String employeeId, {
    int? year,
    String startTime = '08:00',
    String endTime = '17:00',
  }) async {
    final targetYear = year ?? DateTime.now().year;
    final schedules = <EmployeeScheduleModel>[];

    // Crear horario para 52 semanas
    for (int week = 1; week <= 52; week++) {
      schedules.add(
        EmployeeScheduleModel.standardWorkWeek(
          employeeId: employeeId,
          weekNumber: week,
          year: targetYear,
          startTime: startTime,
          endTime: endTime,
        ),
      );
    }

    return await createSchedulesBatch(schedules);
  }
}
