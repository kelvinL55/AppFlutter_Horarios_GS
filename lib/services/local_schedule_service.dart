import 'dart:async';
import 'package:evelyn/models/schedule_model.dart';

class LocalScheduleService {
  // Datos de horarios locales (sin Firestore)
  static final List<ScheduleModel> _localSchedules = [
    ScheduleModel(
      id: 'local_schedule_1',
      weekNumber: 1,
      weekLabel: 'Semana del 13/01 - 19/01/2025',
      startDate: DateTime(2025, 1, 13),
      endDate: DateTime(2025, 1, 19),
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
          endTime: '15:00',
          breakStart: '12:00',
          breakEnd: '13:00',
        ),
        ShiftModel(day: 'Sábado', startTime: '09:00', endTime: '13:00'),
        ShiftModel(day: 'Domingo', startTime: 'Libre', endTime: 'Libre'),
      ],
    ),
  ];

  // Obtener el horario actual activo (simulado)
  Stream<ScheduleModel?> getCurrentSchedule() {
    return Stream.value(
      _localSchedules.firstWhere(
        (schedule) => schedule.isActive,
        orElse: () => _localSchedules.first,
      ),
    );
  }

  // Obtener todos los horarios (simulado)
  Stream<List<ScheduleModel>> getAllSchedules() {
    return Stream.value(_localSchedules);
  }

  // Crear un nuevo horario (simulado)
  Future<String?> createSchedule(ScheduleModel schedule) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      final newSchedule = ScheduleModel(
        id: 'local_schedule_${DateTime.now().millisecondsSinceEpoch}',
        weekNumber: schedule.weekNumber,
        weekLabel: schedule.weekLabel,
        startDate: schedule.startDate,
        endDate: schedule.endDate,
        lastUpdated: DateTime.now(),
        isActive: schedule.isActive,
        shifts: schedule.shifts,
      );

      _localSchedules.add(newSchedule);
      return newSchedule.id;
    } catch (e) {
      print('Error al crear horario local: $e');
      return null;
    }
  }

  // Actualizar un horario existente (simulado)
  Future<bool> updateSchedule(ScheduleModel schedule) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      final index = _localSchedules.indexWhere((s) => s.id == schedule.id);
      if (index != -1) {
        _localSchedules[index] = schedule;
        return true;
      }
      return false;
    } catch (e) {
      print('Error al actualizar horario local: $e');
      return false;
    }
  }

  // Activar un horario (simulado)
  Future<bool> activateSchedule(String scheduleId) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      // Desactivar todos
      for (int i = 0; i < _localSchedules.length; i++) {
        _localSchedules[i] = ScheduleModel(
          id: _localSchedules[i].id,
          weekNumber: _localSchedules[i].weekNumber,
          weekLabel: _localSchedules[i].weekLabel,
          startDate: _localSchedules[i].startDate,
          endDate: _localSchedules[i].endDate,
          lastUpdated: _localSchedules[i].lastUpdated,
          isActive: false,
          shifts: _localSchedules[i].shifts,
        );
      }

      // Activar el seleccionado
      final index = _localSchedules.indexWhere((s) => s.id == scheduleId);
      if (index != -1) {
        _localSchedules[index] = ScheduleModel(
          id: _localSchedules[index].id,
          weekNumber: _localSchedules[index].weekNumber,
          weekLabel: _localSchedules[index].weekLabel,
          startDate: _localSchedules[index].startDate,
          endDate: _localSchedules[index].endDate,
          lastUpdated: DateTime.now(),
          isActive: true,
          shifts: _localSchedules[index].shifts,
        );
        return true;
      }
      return false;
    } catch (e) {
      print('Error al activar horario local: $e');
      return false;
    }
  }

  // Eliminar un horario (simulado)
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 500));

      _localSchedules.removeWhere((schedule) => schedule.id == scheduleId);
      return true;
    } catch (e) {
      print('Error al eliminar horario local: $e');
      return false;
    }
  }

  // Obtener horario por ID (simulado)
  Future<ScheduleModel?> getScheduleById(String id) async {
    try {
      // Simular delay de red
      await Future.delayed(const Duration(milliseconds: 300));

      return _localSchedules.firstWhere(
        (schedule) => schedule.id == id,
        orElse: () => throw Exception('Horario no encontrado'),
      );
    } catch (e) {
      print('Error al obtener horario local: $e');
      return null;
    }
  }
}

