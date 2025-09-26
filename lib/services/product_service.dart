import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/product_model.dart';

class ProductService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'products';

  // Obtener productos paginados (primera página)
  Future<List<ProductModel>> getProductsPaginated({int limit = 10}) async {
    final query = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ProductModel.fromMap(data);
    }).toList();
  }

  // Obtener la siguiente página de productos
  Future<List<ProductModel>> getNextProductsPaginated({
    required DocumentSnapshot lastDoc,
    int limit = 10,
  }) async {
    final query = await _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .startAfterDocument(lastDoc)
        .limit(limit)
        .get();
    return query.docs.map((doc) {
      final data = doc.data();
      data['id'] = doc.id;
      return ProductModel.fromMap(data);
    }).toList();
  }

  // Obtener todos los productos (stream)
  Stream<List<ProductModel>> getProducts() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProductModel.fromMap(data);
          }).toList();
        });
  }

  // Obtener un producto por ID
  Future<ProductModel?> getProductById(String id) async {
    try {
      final doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        final data = doc.data()!;
        data['id'] = doc.id;
        return ProductModel.fromMap(data);
      }
      return null;
    } catch (e) {
      print('Error al obtener producto: $e');
      return null;
    }
  }

  // Crear un nuevo producto
  Future<String?> createProduct(ProductModel product) async {
    try {
      final docRef = await _firestore.collection(_collection).add({
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'description': product.description,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return docRef.id;
    } catch (e) {
      print('Error al crear producto: $e');
      return null;
    }
  }

  // Actualizar un producto
  Future<bool> updateProduct(ProductModel product) async {
    try {
      await _firestore.collection(_collection).doc(product.id).update({
        'name': product.name,
        'price': product.price,
        'imageUrl': product.imageUrl,
        'category': product.category,
        'description': product.description,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error al actualizar producto: $e');
      return false;
    }
  }

  // Eliminar un producto
  Future<bool> deleteProduct(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error al eliminar producto: $e');
      return false;
    }
  }

  // Buscar productos por categoría
  Stream<List<ProductModel>> getProductsByCategory(String category) {
    return _firestore
        .collection(_collection)
        .where('category', isEqualTo: category)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
          return snapshot.docs.map((doc) {
            final data = doc.data();
            data['id'] = doc.id;
            return ProductModel.fromMap(data);
          }).toList();
        });
  }
}
