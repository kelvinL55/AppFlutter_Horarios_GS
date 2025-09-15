import 'package:flutter/material.dart';
import 'package:flutter_application_1/services/auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _authService = AuthService();
  bool _isLoading = false;
  bool _isAdminMode = false;
  bool _showPassword = false;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.forward();

    // Listener para detectar automáticamente el tipo de usuario
    _emailController.addListener(_detectUserType);
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // Detecta automáticamente si es administrador basado en el email
  void _detectUserType() {
    final email = _emailController.text.toLowerCase().trim();
    final isAdmin =
        email == 'gi.kelvi@gmail.com' ||
        email.contains('admin') ||
        email.endsWith('@admin.com');

    if (isAdmin != _isAdminMode) {
      setState(() {
        _isAdminMode = isAdmin;
      });
    }
  }

  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);

      try {
        final user = await _authService.signInWithEmailAndPassword(
          _emailController.text.trim(),
          _passwordController.text.trim(),
        );

        if (user != null && mounted) {
          Navigator.pushReplacementNamed(context, '/home', arguments: user);
        } else if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al iniciar sesión')),
          );
        }
      } finally {
        if (mounted) {
          setState(() => _isLoading = false);
        }
      }
    }
  }

  // Eliminado método de acceso rápido no utilizado (_loginAsPredefinedUser)

  void _quickAccessLogin(String userType) async {
    setState(() => _isLoading = true);

    try {
      String uid;
      if (userType == 'admin') {
        uid = '42P0T9DF2kUFY6SIzu393KJwhgv1';
      } else {
        uid = '1H9moElLzdQULSAdstIAbjg3Xah1';
      }

      final user = await _authService.signInAsPredefinedUser(uid);

      if (user != null && mounted) {
        Navigator.pushReplacementNamed(context, '/home', arguments: user);
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al iniciar sesión')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFFF8F9FA), // Gris muy claro
              Color(0xFFE9ECEF), // Gris claro
              Color(0xFFDEE2E6), // Gris medio
            ],
            stops: [0.0, 0.5, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Botón de acceso rápido en la parte superior
              Positioned(
                top: 16,
                right: 16,
                child: PopupMenuButton<String>(
                  onSelected: _quickAccessLogin,
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.flash_on,
                      color: Color(0xFF495057),
                      size: 20,
                    ),
                  ),
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'user',
                      child: Row(
                        children: [
                          Icon(Icons.person, color: Color(0xFF28A745)),
                          SizedBox(width: 8),
                          Text('Acceso Usuario'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'admin',
                      child: Row(
                        children: [
                          Icon(
                            Icons.admin_panel_settings,
                            color: Color(0xFFDC3545),
                          ),
                          SizedBox(width: 8),
                          Text('Acceso Admin'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Contenido principal
              Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24.0),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Card(
                      elevation: 12,
                      shadowColor: Colors.black.withOpacity(0.2),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          gradient: const LinearGradient(
                            begin: Alignment.topCenter,
                            end: Alignment.bottomCenter,
                            colors: [Color(0xFFFFFFFF), Color(0xFFFBFCFE)],
                          ),
                        ),
                        padding: const EdgeInsets.all(32.0),
                        child: Form(
                          key: _formKey,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // Icono y título
                              Container(
                                padding: const EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: const Color(
                                    0xFF4A90E2,
                                  ).withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                child: const Icon(
                                  Icons.access_time_rounded,
                                  size: 64,
                                  color: Color(0xFF4A90E2),
                                ),
                              ),
                              const SizedBox(height: 24),

                              const Text(
                                'Bienvenido',
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF2C3E50),
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),

                              AnimatedSwitcher(
                                duration: const Duration(milliseconds: 300),
                                child: Text(
                                  _isAdminMode
                                      ? 'Modo Administrador'
                                      : 'Modo Usuario',
                                  key: ValueKey(_isAdminMode),
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: _isAdminMode
                                        ? const Color(0xFFDC3545)
                                        : const Color(0xFF28A745),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 32),

                              // Campo de email mejorado
                              TextFormField(
                                controller: _emailController,
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  hintText: 'Ingresa tu correo',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF6C757D),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE9ECEF),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4A90E2),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                keyboardType: TextInputType.emailAddress,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu correo';
                                  }
                                  if (!RegExp(
                                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                                  ).hasMatch(value)) {
                                    return 'Por favor ingresa un correo válido';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 20),

                              // Campo de contraseña (ahora siempre visible)
                              TextFormField(
                                controller: _passwordController,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  hintText: 'Ingresa tu contraseña',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF6C757D),
                                  ),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _showPassword = !_showPassword;
                                      });
                                    },
                                    icon: Icon(
                                      _showPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF6C757D),
                                    ),
                                  ),
                                  filled: true,
                                  fillColor: const Color(0xFFF8F9FA),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: BorderSide.none,
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFFE9ECEF),
                                      width: 1,
                                    ),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF4A90E2),
                                      width: 2,
                                    ),
                                  ),
                                  contentPadding: const EdgeInsets.symmetric(
                                    horizontal: 16,
                                    vertical: 16,
                                  ),
                                ),
                                obscureText: !_showPassword,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Por favor ingresa tu contraseña';
                                  }
                                  if (value.length < 6) {
                                    return 'La contraseña debe tener al menos 6 caracteres';
                                  }
                                  return null;
                                },
                              ),

                              const SizedBox(height: 32),

                              // Botón de login elegante
                              SizedBox(
                                width: double.infinity,
                                height: 56,
                                child: ElevatedButton(
                                  onPressed: _isLoading ? null : _login,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF4A90E2),
                                    foregroundColor: Colors.white,
                                    elevation: 8,
                                    shadowColor: const Color(
                                      0xFF4A90E2,
                                    ).withOpacity(0.3),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(16),
                                    ),
                                  ),
                                  child: _isLoading
                                      ? const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child: CircularProgressIndicator(
                                            color: Colors.white,
                                            strokeWidth: 2,
                                          ),
                                        )
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.login, size: 20),
                                            const SizedBox(width: 8),
                                            const Text(
                                              'Iniciar Sesión',
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
