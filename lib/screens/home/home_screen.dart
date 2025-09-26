import 'package:flutter/material.dart';
import 'package:evelyn/services/auth_service.dart';
import 'package:evelyn/widgets/bottom_nav_bar.dart';
import 'package:evelyn/models/user_model.dart';
import 'package:evelyn/services/user_service.dart';
import 'package:evelyn/screens/settings/screen_timeout_settings.dart';
import 'package:evelyn/screens/admin/employee_admin_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  UserModel? _currentUser;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    // No llamar _loadCurrentUser aquí para evitar el error de ModalRoute
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_isLoading) {
      _loadCurrentUser();
    }
  }

  Future<void> _loadCurrentUser() async {
    try {
      // Si viene un usuario desde Login por argumentos, úsalo
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is UserModel) {
        setState(() {
          _currentUser = args;
          _isLoading = false;
        });
        return;
      }

      // Fallback: si hay usuario en FirebaseAuth, traemos su documento
      final authUser = _authService.currentUser;
      if (authUser != null) {
        final userModel = await _userService.getUserById(authUser.uid);
        if (mounted) {
          setState(() {
            _currentUser = userModel;
            _isLoading = false;
          });
        }
      } else {
        // Último recurso: usuario por defecto de desarrollo
        final user = await _authService.signInAsPredefinedUser(
          _getCurrentUserId(),
        );
        if (mounted) {
          setState(() {
            _currentUser = user;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      print('Error al cargar usuario: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
          // En caso de error, usar un usuario por defecto o mostrar un mensaje
          _currentUser = null;
        });

        // Mostrar un mensaje de error al usuario
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Error al cargar datos del usuario. Modo sin conexión.',
            ),
            backgroundColor: Colors.orange,
            duration: Duration(seconds: 3),
          ),
        );
      }
    }
  }

  String _getCurrentUserId() {
    // Por defecto, usar usuario común
    // En una implementación real, esto vendría del estado de autenticación
    return '1H9moElLzdQULSAdstIAbjg3Xah1';
  }

  Future<void> _signOut() async {
    await _authService.signOut();
    if (mounted) {
      Navigator.pushReplacementNamed(context, '/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Cargando datos del usuario...'),
            ],
          ),
        ),
      );
    }

    // Si no hay usuario, mostrar una pantalla de error amigable
    if (_currentUser == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Inicio'),
          actions: [
            TextButton.icon(
              onPressed: _signOut,
              icon: const Icon(Icons.logout, color: Colors.redAccent),
              label: const Text(
                'Ir a Login',
                style: TextStyle(
                  color: Colors.redAccent,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off, size: 64, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'Sin conexión',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'No se pudieron cargar los datos del usuario.\nVerifica tu conexión a internet.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[500]),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = true;
                  });
                  _loadCurrentUser();
                },
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }

    final isAdmin = _currentUser?.isAdmin ?? false;
    final Color roleColor = isAdmin
        ? const Color(0xFF2ECC71)
        : const Color(0xFF4A90E2);

    return Scaffold(
      appBar: AppBar(
        title: Text('Bienvenido, ${_currentUser?.name ?? 'Usuario'}'),
        actions: [
          // Botón de configuración de tiempo de pantalla
          IconButton(
            icon: const Icon(
              Icons.screen_lock_landscape,
              color: Colors.deepPurple,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ScreenTimeoutSettings(),
                ),
              );
            },
            tooltip: 'Tiempo de Pantalla',
          ),
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.admin_panel_settings),
              onPressed: () {
                Navigator.pushNamed(context, '/admin-schedule');
              },
              tooltip: 'Administración',
            ),
          // Botón temporal para administración de empleados (solo para administradores)
          if (isAdmin)
            IconButton(
              icon: const Icon(Icons.people, color: Colors.indigo),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EmployeeAdminScreen(),
                  ),
                );
              },
              tooltip: 'Administrar Empleados',
            ),
          TextButton.icon(
            onPressed: _signOut,
            icon: const Icon(Icons.logout, color: Colors.redAccent),
            label: const Text(
              'Cerrar sesión',
              style: TextStyle(
                color: Colors.redAccent,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Información del usuario
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAdmin ? Icons.admin_panel_settings : Icons.person,
                          color: roleColor,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                _currentUser?.name ?? 'Usuario',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                _currentUser?.email ?? '',
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey[600],
                                ),
                              ),
                              Container(
                                margin: const EdgeInsets.only(top: 8),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: roleColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  isAdmin
                                      ? 'Usuario Administrativo'
                                      : 'Usuario',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Sección de Notificaciones
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notificaciones Importantes',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildNotificationItem(
                      'Cambios en horarios',
                      'Se han actualizado los horarios para la próxima semana',
                      Icons.schedule_send,
                    ),
                    const Divider(),
                    _buildNotificationItem(
                      'Recordatorio',
                      'No olvides revisar tu horario semanal',
                      Icons.notifications_active_outlined,
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Botón de Horarios
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  Navigator.pushNamed(context, '/schedule');
                },
                icon: const Icon(Icons.schedule),
                label: const Text(
                  'Ver Mis Horarios',
                  style: TextStyle(fontSize: 18),
                ),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 16,
                  ),
                ),
              ),
            ),

            // Contenido adicional para administradores
            if (isAdmin) ...[
              const SizedBox(height: 24),
              Card(
                elevation: 4,
                color: Colors.orange[50],
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: Colors.orange[700],
                            size: 24,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Panel de Administración',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[700],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Como administrador, tienes acceso a funciones especiales:',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.orange[700],
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildAdminFeature('Gestionar horarios', Icons.schedule),
                      _buildAdminFeature('Crear nuevos turnos', Icons.add),
                      _buildAdminFeature(
                        'Modificar horarios existentes',
                        Icons.edit,
                      ),
                      _buildAdminFeature('Gestionar usuarios', Icons.people),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(context, '/admin-schedule');
                              },
                              icon: const Icon(Icons.admin_panel_settings),
                              label: const Text('Horarios'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton.icon(
                              onPressed: () {
                                Navigator.pushNamed(
                                  context,
                                  '/user-management',
                                );
                              },
                              icon: const Icon(Icons.people),
                              label: const Text('Usuarios'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.green,
                                foregroundColor: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 0,
        onTap: (index) {
          if (index == 0) return;
          if (index == 1) {
            Navigator.pushNamed(context, '/schedule');
          } else if (index == 2) {
            Navigator.pushNamed(context, '/productos');
          }
        },
      ),
    );
  }

  Widget _buildNotificationItem(String title, String message, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                Text(
                  message,
                  style: TextStyle(color: Colors.grey[600], fontSize: 14),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdminFeature(String text, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.orange[600], size: 16),
          const SizedBox(width: 8),
          Text(text, style: TextStyle(fontSize: 14, color: Colors.orange[700])),
        ],
      ),
    );
  }
}
