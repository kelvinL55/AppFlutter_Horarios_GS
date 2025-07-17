import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseTestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Probar conexión básica
  Future<bool> testConnection() async {
    try {
      await _firestore.collection('products').limit(1).get();
      return true;
    } catch (e) {
      print('Error de conexión: $e');
      return false;
    }
  }

  // Crear un producto de prueba
  Future<String?> createTestProduct() async {
    try {
      final docRef = await _firestore.collection('products').add({
        'name': 'Producto de Prueba',
        'price': 99.99,
        'imageUrl': 'https://via.placeholder.com/300?ext=Test',
        'category': 'smartphone',
        'description':
            'Este es un producto de prueba para verificar la conexión',
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error al crear producto de prueba: $e');
      return null;
    }
  }

  // Obtener todos los productos
  Future<List<Map<String, dynamic>>> getTestProducts() async {
    try {
      final snapshot = await _firestore.collection('products').get();
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      print('Error al obtener productos: $e');
      return [];
    }
  }
}
