import 'package:flutter/material.dart';
import 'package:evelyn/services/screen_timeout_service.dart';

class ScreenTimeoutSettings extends StatefulWidget {
  @override
  _ScreenTimeoutSettingsState createState() => _ScreenTimeoutSettingsState();
}

class _ScreenTimeoutSettingsState extends State<ScreenTimeoutSettings> {
  String _currentSetting = '2 minutos';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadCurrentSetting();
  }

  Future<void> _loadCurrentSetting() async {
    try {
      final setting = await ScreenTimeoutService.getCurrentSetting();
      setState(() {
        _currentSetting = setting;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error al cargar configuración: $e');
    }
  }

  Future<void> _updateSetting(String newSetting) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await ScreenTimeoutService.setSetting(newSetting);
      setState(() {
        _currentSetting = newSetting;
        _isLoading = false;
      });

      // Mostrar mensaje de confirmación
      _showSuccessMessage('Configuración guardada: $newSetting');
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showErrorMessage('Error al guardar configuración: $e');
    }
  }

  void _showSuccessMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.green,
        duration: Duration(seconds: 3),
      ),
    );
  }

  void _showErrorMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(Icons.error, color: Colors.white),
            SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: Colors.red,
        duration: Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⏰ Tiempo de Pantalla'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Colors.deepPurple),
                  SizedBox(height: 16),
                  Text('Cargando configuración...'),
                ],
              ),
            )
          : Column(
              children: [
                // Header con información
                Container(
                  width: double.infinity,
                  padding: EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.deepPurple,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.screen_lock_landscape,
                        size: 48,
                        color: Colors.white,
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Control de Tiempo de Pantalla',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Configura cuándo se debe bloquear la pantalla',
                        style: TextStyle(color: Colors.white70, fontSize: 14),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),

                // Estado actual
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.blue[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.blue[200]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue),
                      SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Configuración Actual',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                            Text(
                              ScreenTimeoutService.getStatusDescription(),
                              style: TextStyle(
                                color: Colors.blue[700],
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                // Lista de opciones
                Expanded(
                  child: ListView.builder(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    itemCount: ScreenTimeoutService.getAllOptions().length,
                    itemBuilder: (context, index) {
                      final option =
                          ScreenTimeoutService.getAllOptions()[index];
                      final isSelected = option == _currentSetting;

                      return Container(
                        margin: EdgeInsets.only(bottom: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: isSelected
                                ? Colors.deepPurple
                                : Colors.grey[300]!,
                            width: isSelected ? 2 : 1,
                          ),
                          color: isSelected
                              ? Colors.deepPurple[50]
                              : Colors.white,
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 4,
                          ),
                          leading: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.deepPurple
                                  : Colors.grey[200],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              _getIconForOption(option),
                              color: isSelected
                                  ? Colors.white
                                  : Colors.grey[600],
                              size: 20,
                            ),
                          ),
                          title: Text(
                            option,
                            style: TextStyle(
                              fontWeight: isSelected
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: isSelected
                                  ? Colors.deepPurple[800]
                                  : Colors.black87,
                            ),
                          ),
                          subtitle: Text(
                            _getDescriptionForOption(option),
                            style: TextStyle(
                              fontSize: 12,
                              color: isSelected
                                  ? Colors.deepPurple[600]
                                  : Colors.grey[600],
                            ),
                          ),
                          trailing: isSelected
                              ? Icon(
                                  Icons.check_circle,
                                  color: Colors.deepPurple,
                                  size: 24,
                                )
                              : Icon(
                                  Icons.radio_button_unchecked,
                                  color: Colors.grey[400],
                                  size: 24,
                                ),
                          onTap: () => _updateSetting(option),
                        ),
                      );
                    },
                  ),
                ),

                // Información adicional
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.orange[200]!),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.lightbulb, color: Colors.orange, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Información',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.orange[800],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 8),
                      Text(
                        '• "Nunca" mantiene la pantalla siempre activa mientras la app esté abierta\n'
                        '• Los demás tiempos usan la configuración del sistema\n'
                        '• Esta configuración solo afecta cuando "Evelyn" está en primer plano',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange[700],
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  IconData _getIconForOption(String option) {
    if (option.contains('30 segundos')) return Icons.timer;
    if (option.contains('1 minuto')) return Icons.timer;
    if (option.contains('2 minutos')) return Icons.timer_3;
    if (option.contains('5 minutos')) return Icons.timer;
    if (option.contains('10 minutos')) return Icons.timer_10;
    if (option.contains('30 minutos')) return Icons.schedule;
    if (option.contains('1 hora')) return Icons.access_time;
    if (option.contains('Nunca')) return Icons.lock_open;
    return Icons.timer;
  }

  String _getDescriptionForOption(String option) {
    if (option.contains('30 segundos')) return 'Para pruebas rápidas';
    if (option.contains('1 minuto')) return 'Tiempo muy corto';
    if (option.contains('2 minutos')) return 'Tiempo corto (recomendado)';
    if (option.contains('5 minutos')) return 'Tiempo moderado';
    if (option.contains('10 minutos')) return 'Tiempo largo';
    if (option.contains('30 minutos')) return 'Tiempo muy largo';
    if (option.contains('1 hora')) return 'Para sesiones extensas';
    if (option.contains('Nunca'))
      return 'Pantalla siempre activa (consume batería)';
    return 'Configuración personalizada';
  }
}
