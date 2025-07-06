import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_application_1/screens/auth/login_screen.dart';
import 'package:flutter_application_1/screens/home/home_screen.dart';
import 'package:flutter_application_1/screens/schedule/schedule_screen.dart';
import 'package:flutter_application_1/screens/schedule/calendar_screen.dart';
import 'firebase_options.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'splash.dart';
import 'screens/productos/productos_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es');
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
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
        '/splash': (context) => Splash(),
        '/home': (context) => HomeScreen(),
        '/schedule': (context) => const ScheduleScreen(),
        '/calendar': (context) => const CalendarScreen(),
        '/productos': (context) => ProductosScreen(),
      },
    );
  }
}
