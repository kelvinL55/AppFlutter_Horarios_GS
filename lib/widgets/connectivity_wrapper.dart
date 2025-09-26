import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/connectivity_provider.dart';
import 'no_internet_screen.dart';

/// Widget wrapper que muestra la pantalla sin conexión cuando no hay internet
/// y el contenido normal cuando hay conexión
class ConnectivityWrapper extends StatelessWidget {
  final Widget child;
  final String? customTitle;
  final String? customSubtitle;
  final String? customButtonText;
  final VoidCallback? onRetry;

  const ConnectivityWrapper({
    Key? key,
    required this.child,
    this.customTitle,
    this.customSubtitle,
    this.customButtonText,
    this.onRetry,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        if (!connectivityProvider.isConnected) {
          return NoInternetScreen(
            title: customTitle,
            subtitle: customSubtitle,
            buttonText: customButtonText,
            onRetry: onRetry ?? () => connectivityProvider.retryConnection(),
          );
        }

        return child;
      },
    );
  }
}

/// Widget que muestra un banner de conexión en la parte superior
class ConnectivityBanner extends StatelessWidget {
  final Widget child;

  const ConnectivityBanner({Key? key, required this.child}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, _) {
        return Column(
          children: [
            if (!connectivityProvider.isConnected)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                color: Colors.red[600],
                child: Row(
                  children: [
                    const Icon(Icons.wifi_off, color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text(
                        'Sin conexión a internet',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () => connectivityProvider.retryConnection(),
                      child: const Text(
                        'Reintentar',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            Expanded(child: child),
          ],
        );
      },
    );
  }
}
