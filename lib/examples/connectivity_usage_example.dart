import 'package:flutter/material.dart';
import '../widgets/connectivity_wrapper.dart';
import '../widgets/no_internet_screen.dart';

/// Ejemplo de cómo usar los widgets de conectividad en tu aplicación
class ConnectivityUsageExample extends StatelessWidget {
  const ConnectivityUsageExample({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ejemplos de Conectividad')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Ejemplos de Uso',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            // Ejemplo 1: Pantalla completa sin conexión
            _buildExampleCard(
              title: '1. Pantalla Completa Sin Conexión',
              description:
                  'Muestra una pantalla completa cuando no hay internet',
              child: ElevatedButton(
                onPressed: () => _showFullScreenExample(context),
                child: const Text('Ver Ejemplo'),
              ),
            ),

            const SizedBox(height: 16),

            // Ejemplo 2: Wrapper con contenido
            _buildExampleCard(
              title: '2. Wrapper con Contenido',
              description:
                  'Envuelve tu contenido y muestra pantalla sin conexión cuando es necesario',
              child: ConnectivityWrapper(
                customTitle: 'Sin conexión',
                customSubtitle:
                    'Esta pantalla necesita internet para funcionar correctamente.',
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Contenido que necesita internet',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Ejemplo 3: Banner de conexión
            _buildExampleCard(
              title: '3. Banner de Conexión',
              description:
                  'Muestra un banner en la parte superior cuando no hay conexión',
              child: ConnectivityBanner(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.green[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Text(
                    'Contenido con banner de conexión',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExampleCard({
    required String title,
    required String description,
    required Widget child,
  }) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  void _showFullScreenExample(BuildContext context) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const NoInternetScreen(
          title: 'Ejemplo de Pantalla Sin Conexión',
          subtitle:
              'Esta es una demostración de cómo se ve la pantalla cuando no hay internet.',
          buttonText: 'Volver',
        ),
      ),
    );
  }
}

/// Ejemplo de cómo integrar en una pantalla existente
class ExampleScreenWithConnectivity extends StatelessWidget {
  const ExampleScreenWithConnectivity({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Mi Pantalla')),
      body: ConnectivityWrapper(
        customTitle: 'Sin conexión',
        customSubtitle:
            'Esta pantalla necesita internet para cargar los datos.',
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_download, size: 64, color: Colors.blue),
              SizedBox(height: 16),
              Text('Contenido de la pantalla', style: TextStyle(fontSize: 18)),
              SizedBox(height: 8),
              Text(
                'Este contenido se muestra cuando hay conexión a internet',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
