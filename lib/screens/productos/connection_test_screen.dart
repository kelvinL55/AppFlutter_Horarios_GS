import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ConnectionTestScreen extends StatefulWidget {
  @override
  _ConnectionTestScreenState createState() => _ConnectionTestScreenState();
}

class _ConnectionTestScreenState extends State<ConnectionTestScreen> {
  String _status = 'Iniciando prueba...';
  bool _isLoading = true;
  List<Map<String, dynamic>> _products = [];

  @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async {
    setState(() {
      _status = 'Probando conexión con Firebase...';
      _isLoading = true;
    });

    try {
      // Paso 1: Probar conexión básica
      _updateStatus('📡 Conectando a Firebase...');
      await Future.delayed(Duration(seconds: 1));

      // Paso 2: Intentar leer productos
      _updateStatus('📦 Leyendo productos de Firestore...');
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .limit(10)
          .get();

      _updateStatus('✅ ¡Conexión exitosa!');
      _updateStatus('📊 Productos encontrados: ${snapshot.docs.length}');

      // Mostrar productos
      final products = snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _products = products;
        _isLoading = false;
      });

      _updateStatus('🎉 ¡Todos los productos cargados correctamente!');

      // Mostrar detalles de cada producto
      for (int i = 0; i < products.length && i < 3; i++) {
        final product = products[i];
        _updateStatus('');
        _updateStatus('📱 Producto ${i + 1}:');
        _updateStatus('   • Nombre: ${product['name'] ?? 'Sin nombre'}');
        _updateStatus('   • Precio: \$${product['price'] ?? 0}');
        _updateStatus(
          '   • Categoría: ${product['category'] ?? 'Sin categoría'}',
        );
        _updateStatus(
          '   • Imagen: ${product['imageUrl']?.toString().substring(0, 50) ?? 'Sin imagen'}...',
        );
      }

      if (products.length > 3) {
        _updateStatus('');
        _updateStatus('... y ${products.length - 3} productos más');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });

      _updateStatus('❌ Error de conexión:');
      _updateStatus('$e');
      _updateStatus('');
      _updateStatus('💡 Posibles soluciones:');
      _updateStatus('1. Verificar reglas de Firestore');
      _updateStatus('2. Comprobar configuración de Firebase');
      _updateStatus('3. Verificar conexión a internet');
    }
  }

  void _updateStatus(String message) {
    setState(() {
      _status += '\n$message';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('🔗 Test de Conexión'),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _isLoading
                ? null
                : () {
                    setState(() {
                      _status = 'Reiniciando prueba...';
                      _products.clear();
                    });
                    _testConnection();
                  },
          ),
        ],
      ),
      body: Column(
        children: [
          // Status del test
          Expanded(
            flex: 2,
            child: Container(
              width: double.infinity,
              margin: EdgeInsets.all(16),
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey[300]!),
              ),
              child: SingleChildScrollView(
                child: Text(
                  _status,
                  style: TextStyle(
                    fontFamily: 'monospace',
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ),
            ),
          ),

          // Loading indicator
          if (_isLoading)
            Container(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(width: 16),
                  Text('Probando conexión...'),
                ],
              ),
            ),

          // Products preview
          if (_products.isNotEmpty)
            Expanded(
              flex: 1,
              child: Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '🖼️ Vista Previa de Productos:',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 8),
                    Expanded(
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _products.length,
                        itemBuilder: (context, index) {
                          final product = _products[index];
                          return Container(
                            width: 120,
                            margin: EdgeInsets.only(right: 8),
                            child: Card(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Container(
                                      width: double.infinity,
                                      child: product['imageUrl'] != null
                                          ? Image.network(
                                              product['imageUrl'],
                                              fit: BoxFit.cover,
                                              errorBuilder:
                                                  (context, error, stackTrace) {
                                                    return Container(
                                                      color: Colors.grey[300],
                                                      child: Icon(
                                                        Icons
                                                            .image_not_supported,
                                                        color: Colors.grey[600],
                                                      ),
                                                    );
                                                  },
                                            )
                                          : Container(
                                              color: Colors.grey[300],
                                              child: Icon(
                                                Icons.image_not_supported,
                                                color: Colors.grey[600],
                                              ),
                                            ),
                                    ),
                                  ),
                                  Padding(
                                    padding: EdgeInsets.all(8),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          product['name'] ?? 'Sin nombre',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            fontSize: 12,
                                          ),
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                        Text(
                                          '\$${product['price'] ?? 0}',
                                          style: TextStyle(
                                            color: Colors.green,
                                            fontSize: 11,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
