import 'package:flutter/material.dart';
importpackage:flutter_application_1/services/firebase_test_service.dart;class FirebaseTestScreen extends StatefulWidget [object Object]const FirebaseTestScreen({super.key});

  @override
  State<FirebaseTestScreen> createState() => _FirebaseTestScreenState();
}

class _FirebaseTestScreenState extends State<FirebaseTestScreen> [object Object]final FirebaseTestService _testService = FirebaseTestService();
  bool _isLoading = false;
  String _status = '';
  List<Map<String, dynamic>> _products =   @override
  void initState() {
    super.initState();
    _testConnection();
  }

  Future<void> _testConnection() async[object Object]    setState(() [object Object]      _isLoading = true;
      _status = Probando conexión...';
    });

    try[object Object]   // Probar conexión básica
      final isConnected = await _testService.testConnection();
      
      if (isConnected) [object Object]       setState(() {
          _status = '✅ Conexión exitosa con Firebase';
        });

        // Obtener productos existentes
        final products = await _testService.getTestProducts();
        setState(() {
          _products = products;
          _status += '\n📦 Productos encontrados: ${products.length}';
        });
      } else [object Object]       setState(() {
          _status =❌ Error de conexión con Firebase';
        });
      }
    } catch (e) {
      setState(()[object Object]
        _status = '❌ Error: $e; });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _createTestProduct() async[object Object]    setState(() [object Object]      _isLoading = true;
      _status =Creando producto de prueba...';
    });

    try {
      final productId = await _testService.createTestProduct();
      
      if (productId != null) [object Object]       setState(() {
          _status = '✅ Producto de prueba creado exitosamente\nID: $productId';
        });
        
        // Actualizar lista de productos
        final products = await _testService.getTestProducts();
        setState(() {
          _products = products;
        });
      } else [object Object]       setState(() {
          _status =❌ Error al crear producto de prueba';
        });
      }
    } catch (e) {
      setState(()[object Object]
        _status = '❌ Error: $e; });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) [object Object]   return Scaffold(
      backgroundColor: Colors.grey50
      appBar: AppBar(
        title: const Text('Prueba de Firebase'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation:0       centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0     child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Card de estado
            Card(
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16
              ),
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
              Estado de Firebase',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (_isLoading)
                      const Row(
                        children: [
                          CircularProgressIndicator(),
                          SizedBox(width: 12),
                          Text(Procesando...                   ],
                      ),
                    if (!_isLoading)
                      Text(
                        _status,
                        style: const TextStyle(fontSize: 14),
                      ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _testConnection,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Probar Conexión'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _createTestProduct,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green,
                              foregroundColor: Colors.white,
                            ),
                            child: const Text('Crear Producto Test'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height:24),

            // Lista de productos
            if (_products.isNotEmpty) ...[
              const Text(
              Productos en la Base de Datos:,             style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16
              ..._products.map((product) => Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue[100],
                    child: Text(
                      product['name]?.toString().substring(0, 1).toUpperCase() ?? '?',
                      style: TextStyle(color: Colors.blue[700]),
                    ),
                  ),
                  title: Text(product['name']?.toString() ?? 'Sin nombre'),
                  subtitle: Text(
               Precio: \$${product[price']?.toString() ??0} | Categoría: ${product['category']?.toString() ?? 'N/A'}',
                  ),
                  trailing: Text(
                    ID: ${product[id]?.toString().substring(0, 8)}...',
                    style: const TextStyle(fontSize:12color: Colors.grey),
                  ),
                ),
              )).toList(),
            ],
          ],
        ),
      ),
    );
  }
} 