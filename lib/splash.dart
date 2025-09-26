import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'providers/connectivity_provider.dart';

class Splash extends StatefulWidget {
  @override
  _SplashState createState() => _SplashState();
}

class _SplashState extends State<Splash> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _opacityAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 5000), // Duración de la animación
      vsync: this,
    );

    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeIn));

    _scaleAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.elasticOut));

    // Inicia la animación
    _controller.forward();

    // Inicializar servicio de conectividad
    _initializeConnectivity();

    // Navega después del tiempo total
    _navigateHome();
  }

  _initializeConnectivity() async {
    final connectivityProvider = Provider.of<ConnectivityProvider>(
      context,
      listen: false,
    );
    await connectivityProvider.initialize();
  }

  @override
  void dispose() {
    _controller.dispose(); // Es muy importante liberar el controlador
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Opacity(
              opacity: _opacityAnimation.value,
              child: Transform.scale(
                scale: _scaleAnimation.value,
                // Usamos tu logo desde la carpeta de assets
                child: Image.asset('assets/images/logo.png', width: 150),
              ),
            );
          },
        ),
      ),
    );
  }

  _navigateHome() async {
    print('🚀 Splash: Iniciando navegación...');

    // Esperar el tiempo mínimo del splash
    await Future.delayed(const Duration(milliseconds: 3000));
    print('⏰ Splash: Tiempo mínimo completado');

    // Esperar a que se inicialice la conectividad
    final connectivityProvider = Provider.of<ConnectivityProvider>(
      context,
      listen: false,
    );

    // Esperar hasta 2 segundos adicionales para la verificación de conectividad
    int attempts = 0;
    while (!connectivityProvider.isInitialized && attempts < 20) {
      await Future.delayed(const Duration(milliseconds: 100));
      attempts++;
    }

    print(
      '🔍 Splash: ConnectivityProvider inicializado: ${connectivityProvider.isInitialized}',
    );
    print('🌐 Splash: Estado de conexión: ${connectivityProvider.isConnected}');

    // Si no hay conexión, la pantalla de "sin internet" se mostrará automáticamente
    // Si hay conexión, navegar normalmente
    if (connectivityProvider.isConnected) {
      print('✅ Splash: Hay conexión, navegando...');
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        print('🏠 Splash: Navegando a home');
        Navigator.pushReplacementNamed(context, '/home');
      } else {
        print('🔐 Splash: Navegando a login');
        Navigator.pushReplacementNamed(context, '/login');
      }
    } else {
      print('❌ Splash: No hay conexión, no navegando');
    }
    // Si no hay conexión, no navegar - la pantalla de sin internet se mostrará
  }
}
