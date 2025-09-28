import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';
import 'package:evelyn/screens/auth/login_screen.dart';
import 'package:evelyn/screens/auth/register_screen.dart';
import 'package:evelyn/screens/auth/employee_login_screen.dart';
import 'package:evelyn/screens/auth/forgot_password_screen.dart';
import 'package:evelyn/screens/home/home_screen.dart';
import 'package:evelyn/screens/schedule/schedule_screen.dart';
import 'package:evelyn/screens/schedule/calendar_screen.dart';
import 'package:evelyn/screens/schedule/admin_schedule_screen.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'splash.dart';
import 'screens/productos/productos_screen.dart';
import 'screens/productos/add_edit_product_screen.dart';
import 'screens/admin/user_management_screen.dart';
import 'utils/firestore_seeder.dart';
import 'utils/user_updater.dart';
import 'utils/schedule_seeder.dart';
import 'services/screen_timeout_service.dart';
import 'providers/connectivity_provider.dart';
import 'providers/user_provider.dart';
import 'widgets/no_internet_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    await initializeDateFormatting('es');

    // Inicializar servicio de tiempo de pantalla
    await ScreenTimeoutService.initialize();

    // Inicializar datos de Firebase en segundo plano (no bloquea el inicio)
    _initializeFirebaseDataInBackground();
  } catch (e) {
    print('❌ Error al inicializar Firebase: $e');
    print('📱 La aplicación funcionará sin Firebase');
  }

  runApp(const MyApp());
}

// Función para inicializar datos de Firebase en segundo plano
void _initializeFirebaseDataInBackground() {
  Future.microtask(() async {
    try {
      // Ejecutar operaciones de inicialización de forma asíncrona
      await Future.wait([
        FirestoreSeeder.seedIfEmpty(),
        UserUpdater.fixAllUsers(),
        ScheduleSeeder.seedIfEmpty(),
      ]);
      print('✅ Datos de Firebase inicializados correctamente');
    } catch (e) {
      print('⚠️ Error al inicializar datos de Firebase: $e');
      print('📱 La aplicación funcionará en modo sin conexión');
    }
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ConnectivityProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: Consumer<ConnectivityProvider>(
        builder: (context, connectivityProvider, child) {
          return MaterialApp(
            title: 'Gestión de Horarios',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color.fromARGB(255, 23, 158, 221),
              ),
              useMaterial3: true,
            ),
            initialRoute: '/splash',
            routes: {
              '/login': (context) => const LoginScreen(),
              '/register': (context) => const RegisterScreen(),
              '/employee-login': (context) => const EmployeeLoginScreen(),
              '/forgot-password': (context) => const ForgotPasswordScreen(),
              '/splash': (context) => Splash(),
              '/home': (context) => HomeScreen(),
              '/schedule': (context) => const ScheduleScreen(),
              '/calendar': (context) => const CalendarScreen(),
              '/admin-schedule': (context) => const AdminScheduleScreen(),
              '/productos': (context) => ProductosScreen(),
              '/add-edit-product': (context) => const AddEditProductScreen(),
              '/user-management': (context) => const UserManagementScreen(),
            },
            builder: (context, child) {
              return NoInternetOverlay(
                isConnected: connectivityProvider.isConnected,
                onRetry: () => connectivityProvider.retryConnection(),
                child: child!,
              );
            },
          );
        },
      ),
    );
  }
}
