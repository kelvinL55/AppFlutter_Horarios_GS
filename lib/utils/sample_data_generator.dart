import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/schedule_model.dart';

class SampleDataGenerator {
  static Future<void> generateSampleSchedule() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Crear horario de ejemplo
    final schedule = ScheduleModel(
      id: '', // Se generará automáticamente
      weekNumber: 15,
      weekLabel: 'Semana del 8 al 14 de Abril 2024',
      startDate: DateTime(2024, 4, 8),
      endDate: DateTime(2024, 4, 14),
      lastUpdated: DateTime.now(),
      isActive: true,
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
          endTime: '16:00',
          breakStart: '12:00',
          breakEnd: '13:00',
        ),
        ShiftModel(day: 'Sábado', startTime: '09:00', endTime: '14:00'),
        ShiftModel(day: 'Domingo', startTime: 'Cerrado', endTime: 'Cerrado'),
      ],
    );

    try {
      // Insertar el horario
      final docRef = await _firestore
          .collection('schedules')
          .add(schedule.toMap());
      print('Horario de ejemplo creado con ID: ${docRef.id}');

      // Marcar como activo
      await _firestore.collection('schedules').doc(docRef.id).update({
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      print('Horario marcado como activo exitosamente');
    } catch (e) {
      print('Error al crear horario de ejemplo: $e');
    }
  }

  static Future<void> generateMultipleSchedules() async {
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    // Horario Semana 14
    final schedule14 = ScheduleModel(
      id: '',
      weekNumber: 14,
      weekLabel: 'Semana del 1 al 7 de Abril 2024',
      startDate: DateTime(2024, 4, 1),
      endDate: DateTime(2024, 4, 7),
      lastUpdated: DateTime.now().subtract(const Duration(days: 7)),
      isActive: false,
      shifts: [
        ShiftModel(
          day: 'Lunes',
          startTime: '09:00',
          endTime: '18:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        ),
        ShiftModel(
          day: 'Martes',
          startTime: '09:00',
          endTime: '18:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        ),
        ShiftModel(
          day: 'Miércoles',
          startTime: '09:00',
          endTime: '18:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        ),
        ShiftModel(
          day: 'Jueves',
          startTime: '09:00',
          endTime: '18:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        ),
        ShiftModel(
          day: 'Viernes',
          startTime: '09:00',
          endTime: '17:00',
          breakStart: '13:00',
          breakEnd: '14:00',
        ),
        ShiftModel(day: 'Sábado', startTime: '10:00', endTime: '15:00'),
        ShiftModel(day: 'Domingo', startTime: 'Cerrado', endTime: 'Cerrado'),
      ],
    );

    // Horario Semana 16 (futuro)
    final schedule16 = ScheduleModel(
      id: '',
      weekNumber: 16,
      weekLabel: 'Semana del 15 al 21 de Abril 2024',
      startDate: DateTime(2024, 4, 15),
      endDate: DateTime(2024, 4, 21),
      lastUpdated: DateTime.now().add(const Duration(days: 7)),
      isActive: false,
      shifts: [
        ShiftModel(
          day: 'Lunes',
          startTime: '07:30',
          endTime: '16:30',
          breakStart: '11:30',
          breakEnd: '12:30',
        ),
        ShiftModel(
          day: 'Martes',
          startTime: '07:30',
          endTime: '16:30',
          breakStart: '11:30',
          breakEnd: '12:30',
        ),
        ShiftModel(
          day: 'Miércoles',
          startTime: '07:30',
          endTime: '16:30',
          breakStart: '11:30',
          breakEnd: '12:30',
        ),
        ShiftModel(
          day: 'Jueves',
          startTime: '07:30',
          endTime: '16:30',
          breakStart: '11:30',
          breakEnd: '12:30',
        ),
        ShiftModel(
          day: 'Viernes',
          startTime: '07:30',
          endTime: '15:30',
          breakStart: '11:30',
          breakEnd: '12:30',
        ),
        ShiftModel(day: 'Sábado', startTime: '08:30', endTime: '13:30'),
        ShiftModel(day: 'Domingo', startTime: 'Cerrado', endTime: 'Cerrado'),
      ],
    );

    try {
      // Insertar horarios
      await _firestore.collection('schedules').add(schedule14.toMap());
      await _firestore.collection('schedules').add(schedule16.toMap());

      print('Horarios de ejemplo creados exitosamente');
    } catch (e) {
      print('Error al crear horarios de ejemplo: $e');
    }
  }
}
