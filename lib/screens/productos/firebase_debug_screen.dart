import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/services/product_service.dart';
import 'package:evelyn/models/product_model.dart';

class FirebaseDebugScreen extends StatefulWidget {
  @override
  _FirebaseDebugScreenState createState() => _FirebaseDebugScreenState();
}

class _FirebaseDebugScreenState extends State<FirebaseDebugScreen> {
  final ProductService _productService = ProductService();
  String _debugInfo = 'Iniciando diagnóstico...';
  List<Map<String, dynamic>> _rawProducts = [];
  List<ProductModel> _products = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _runDiagnostics();
  }

  Future<void> _runDiagnostics() async {
    setState(() {
      _debugInfo = 'Ejecutando diagnósticos de Firebase...\n';
      _isLoading = true;
    });

    // Test 1: Conexión básica
    try {
      _addDebugInfo('🔍 Test 1: Probando conexión básica a Firestore...');
      final testQuery = await FirebaseFirestore.instance
          .collection('products')
          .limit(1)
          .get();
      _addDebugInfo('✅ Conexión exitosa a Firestore');
      _addDebugInfo('📊 Documentos encontrados: ${testQuery.docs.length}');
    } catch (e) {
      _addDebugInfo('❌ Error de conexión: $e');
    }

    // Test 2: Leer productos directamente
    try {
      _addDebugInfo('\n🔍 Test 2: Intentando leer productos directamente...');
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();

      _addDebugInfo('✅ Lectura directa exitosa');
      _addDebugInfo('📦 Total de productos: ${snapshot.docs.length}');

      setState(() {
        _rawProducts = snapshot.docs.map((doc) {
          final data = doc.data();
          data['id'] = doc.id;
          return data;
        }).toList();
      });

      if (snapshot.docs.isNotEmpty) {
        _addDebugInfo('📄 Primer producto:');
        final firstProduct = snapshot.docs.first.data();
        firstProduct.forEach((key, value) {
          _addDebugInfo('  • $key: $value');
        });
      }
    } catch (e) {
      _addDebugInfo('❌ Error al leer productos: $e');
    }

    // Test 3: Usar ProductService
    try {
      _addDebugInfo('\n🔍 Test 3: Usando ProductService...');
      final products = await _productService.getProductsPaginated(limit: 5);
      _addDebugInfo('✅ ProductService funcionando');
      _addDebugInfo('📦 Productos obtenidos: ${products.length}');

      setState(() {
        _products = products;
      });

      for (int i = 0; i < products.length; i++) {
        final product = products[i];
        _addDebugInfo('📱 Producto ${i + 1}:');
        _addDebugInfo('  • Nombre: ${product.name}');
        _addDebugInfo('  • Precio: \$${product.price}');
        _addDebugInfo('  • Imagen: ${product.imageUrl}');
        _addDebugInfo('  • Categoría: ${product.category}');
      }
    } catch (e) {
      _addDebugInfo('❌ Error en ProductService: $e');
    }

    // Test 4: Verificar imágenes
    _addDebugInfo('\n🔍 Test 4: Verificando URLs de imágenes...');
    for (final product in _products) {
      if (product.imageUrl.isNotEmpty) {
        _addDebugInfo('🖼️ Imagen: ${product.imageUrl}');
        if (product.imageUrl.startsWith('http')) {
          _addDebugInfo('  ✅ URL válida');
        } else {
          _addDebugInfo('  ⚠️ URL posiblemente inválida');
        }
      }
    }

    setState(() {
      _isLoading = false;
    });
    _addDebugInfo('\n🏁 Diagnóstico completado');
  }

  void _addDebugInfo(String info) {
    setState(() {
      _debugInfo += '$info\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔧 Diagnóstico Firebase'),
        backgroundColor: Colors.orange,
      ),
      body: Column(
        children: [
          // Botón para recargar diagnóstico
          Padding(
            padding: EdgeInsets.all(16),
            child: ElevatedButton.icon(
              onPressed: _isLoading ? null : _runDiagnostics,
              icon: Icon(_isLoading ? Icons.hourglass_empty : Icons.refresh),
              label: Text(
                _isLoading ? 'Diagnosticando...' : 'Ejecutar Diagnóstico',
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
              ),
            ),
          ),

          // Información de diagnóstico
          Expanded(
            child: Container(
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _debugInfo,
                  style: TextStyle(fontFamily: 'monospace', fontSize: 12),
                ),
              ),
            ),
          ),

          // Productos encontrados
          if (_products.isNotEmpty)
            Container(
              height: 100,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                itemCount: _products.length,
                itemBuilder: (context, index) {
                  final product = _products[index];
                  return Container(
                    width: 80,
                    margin: EdgeInsets.all(4),
                    child: Column(
                      children: [
                        Expanded(
                          child: product.imageUrl.isNotEmpty
                              ? Image.network(
                                  product.imageUrl,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Container(
                                      color: Colors.grey[300],
                                      child: Icon(Icons.error),
                                    );
                                  },
                                )
                              : Container(
                                  color: Colors.grey[300],
                                  child: Icon(Icons.image_not_supported),
                                ),
                        ),
                        Text(
                          product.name,
                          style: TextStyle(fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}
