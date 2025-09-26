import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/schedule_model.dart';

class ScheduleSeeder {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Crear horario de ejemplo
  static Future<void> seedSampleSchedule() async {
    try {
      print('🌱 Sembrando horario de ejemplo...');

      final now = DateTime.now();
      final startOfWeek = now.subtract(Duration(days: now.weekday - 1));

      final sampleSchedule = ScheduleModel(
        id: 'sample_schedule_${now.millisecondsSinceEpoch}',
        weekNumber: _getWeekNumber(now),
        weekLabel: _getWeekLabel(startOfWeek),
        startDate: startOfWeek,
        endDate: startOfWeek.add(const Duration(days: 6)),
        isActive: true,
        lastUpdated: now,
        shifts: [
          ShiftModel(
            day: 'Lunes',
            startTime: '08:00',
            endTime: '17:00',
            breakStart: '12:00',
            breakEnd: '13:00',
          ),
          ShiftModel(
            day: 'Martes',
            startTime: '08:00',
            endTime: '17:00',
            breakStart: '12:00',
            breakEnd: '13:00',
          ),
          ShiftModel(
            day: 'Miércoles',
            startTime: '08:00',
            endTime: '17:00',
            breakStart: '12:00',
            breakEnd: '13:00',
          ),
          ShiftModel(
            day: 'Jueves',
            startTime: '08:00',
            endTime: '17:00',
            breakStart: '12:00',
            breakEnd: '13:00',
          ),
          ShiftModel(
            day: 'Viernes',
            startTime: '08:00',
            endTime: '15:00',
            breakStart: '12:00',
            breakEnd: '13:00',
          ),
          ShiftModel(day: 'Sábado', startTime: '09:00', endTime: '13:00'),
          ShiftModel(day: 'Domingo', startTime: 'Libre', endTime: 'Libre'),
        ],
      );

      await _firestore
          .collection('schedules')
          .doc(sampleSchedule.id)
          .set(sampleSchedule.toMap());

      print('✅ Horario de ejemplo creado exitosamente');
    } catch (e) {
      print('❌ Error al sembrar horario: $e');
    }
  }

  // Verificar si ya existe un horario activo
  static Future<bool> hasActiveSchedule() async {
    try {
      final snapshot = await _firestore
          .collection('schedules')
          .where('isActive', isEqualTo: true)
          .limit(1)
          .get();
      return snapshot.docs.isNotEmpty;
    } catch (e) {
      print('Error al verificar horarios: $e');
      return false;
    }
  }

  // Sembrar horario solo si no existe
  static Future<void> seedIfEmpty() async {
    try {
      final hasSchedule = await hasActiveSchedule();
      if (!hasSchedule) {
        print('📅 No hay horarios activos. Creando horario de ejemplo...');
        await seedSampleSchedule();
      } else {
        print('📅 Ya existe un horario activo.');
      }
    } catch (e) {
      print('Error en seedIfEmpty: $e');
    }
  }

  static int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday - 1) / 7).floor() + 1;
  }

  static String _getWeekLabel(DateTime startOfWeek) {
    final endOfWeek = startOfWeek.add(const Duration(days: 6));
    return '${startOfWeek.day}/${startOfWeek.month} - ${endOfWeek.day}/${endOfWeek.month}/${endOfWeek.year}';
  }
}
