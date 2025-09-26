import 'package:cloud_firestore/cloud_firestore.dart';

class UserUpdater {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Actualizar el documento de Andres con los campos necesarios
  static Future<void> updateAndresUser() async {
    try {
      print('🔧 Actualizando usuario de Andres...');

      await _firestore.collection('users').doc('TnuaVW4XouuCZHgc8sgR').update({
        'email': 'andres.sanchez01094@gmail.com',
        'name': 'Andres',
        'role': 'user',
        'department': 'General',
        // Mantener compatibilidad con campos existentes
        'correo': 'andres.sanchez01094@gmail.com',
        'usuario': 'Andres',
      });

      print('✅ Usuario de Andres actualizado correctamente');
    } catch (e) {
      print('❌ Error al actualizar usuario de Andres: $e');
    }
  }

  // Verificar y reparar cualquier usuario que le falten campos
  static Future<void> fixAllUsers() async {
    try {
      print('🔧 Verificando y reparando usuarios...');

      final snapshot = await _firestore.collection('users').get();

      for (final doc in snapshot.docs) {
        final data = doc.data();
        bool needsUpdate = false;
        Map<String, dynamic> updates = {};

        // Asegurar que tiene email
        if (!data.containsKey('email') && data.containsKey('correo')) {
          updates['email'] = data['correo'];
          needsUpdate = true;
        }

        // Asegurar que tiene name
        if (!data.containsKey('name') && data.containsKey('usuario')) {
          updates['name'] = data['usuario'];
          needsUpdate = true;
        }

        // Asegurar que tiene role
        if (!data.containsKey('role')) {
          updates['role'] = 'user';
          needsUpdate = true;
        }

        // Asegurar que tiene department
        if (!data.containsKey('department')) {
          updates['department'] = 'General';
          needsUpdate = true;
        }

        if (needsUpdate) {
          await doc.reference.update(updates);
          print('✅ Usuario ${doc.id} actualizado: $updates');
        }
      }

      print('🎉 Todos los usuarios verificados y reparados');
    } catch (e) {
      print('❌ Error al reparar usuarios: $e');
    }
  }
}
