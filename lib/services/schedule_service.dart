import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/schedule_model.dart';

class ScheduleService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'schedules';

  // Obtener el horario actual activo
  Stream<ScheduleModel?> getCurrentSchedule() {
    return _firestore
        .collection(_collection)
        .where('isActive', isEqualTo: true)
        .limit(1)
        .snapshots()
        .map((snapshot) {
          if (snapshot.docs.isNotEmpty) {
            return ScheduleModel.fromMap(
              snapshot.docs.first.data(),
              snapshot.docs.first.id,
            );
          }
          return null;
        });
  }

  // Obtener todos los horarios (para admin)
  Stream<List<ScheduleModel>> getAllSchedules() {
    return _firestore
        .collection(_collection)
        .orderBy('startDate', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            return ScheduleModel.fromMap(doc.data(), doc.id);
          }).toList();
        });
  }

  // Crear un nuevo horario (solo para admin)
  Future<String?> createSchedule(ScheduleModel schedule) async {
    try {
      final docRef = await _firestore
          .collection(_collection)
          .add(schedule.toMap());
      return docRef.id;
    } catch (e) {
      print('Error al crear horario: $e');
      return null;
    }
  }

  // Actualizar un horario existente (solo para admin)
  Future<bool> updateSchedule(ScheduleModel schedule) async {
    try {
      await _firestore
          .collection(_collection)
          .doc(schedule.id)
          .update(schedule.toMap());
      return true;
    } catch (e) {
      print('Error al actualizar horario: $e');
      return false;
    }
  }

  // Desactivar todos los horarios y activar uno nuevo
  Future<bool> activateSchedule(String scheduleId) async {
    try {
      // Desactivar todos los horarios
      final batch = _firestore.batch();
      final schedules = await _firestore
          .collection(_collection)
          .where('isActive', isEqualTo: true)
          .get();

      for (var doc in schedules.docs) {
        batch.update(doc.reference, {'isActive': false});
      }

      // Activar el horario seleccionado
      batch.update(_firestore.collection(_collection).doc(scheduleId), {
        'isActive': true,
        'lastUpdated': FieldValue.serverTimestamp(),
      });

      await batch.commit();
      return true;
    } catch (e) {
      print('Error al activar horario: $e');
      return false;
    }
  }

  // Eliminar un horario (solo para admin)
  Future<bool> deleteSchedule(String scheduleId) async {
    try {
      await _firestore.collection(_collection).doc(scheduleId).delete();
      return true;
    } catch (e) {
      print('Error al eliminar horario: $e');
      return false;
    }
  }

  // Obtener horario por ID específico
  Future<ScheduleModel?> getScheduleById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return ScheduleModel.fromMap(doc.data()!, doc.id);
      }
      return null;
    } catch (e) {
      print('Error al obtener horario: $e');
      return null;
    }
  }
}
