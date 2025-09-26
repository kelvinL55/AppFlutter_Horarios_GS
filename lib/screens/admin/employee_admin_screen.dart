import 'package:flutter/material.dart';
import 'package:evelyn/utils/employee_data_importer.dart';
import 'package:evelyn/services/employee_service.dart';
import 'package:evelyn/services/employee_schedule_service.dart';

class EmployeeAdminScreen extends StatefulWidget {
  @override
  _EmployeeAdminScreenState createState() => _EmployeeAdminScreenState();
}

class _EmployeeAdminScreenState extends State<EmployeeAdminScreen> {
  final EmployeeService _employeeService = EmployeeService();
  final EmployeeScheduleService _scheduleService = EmployeeScheduleService();

  bool _isLoading = false;
  Map<String, int> _stats = {};
  String _statusMessage = 'Listo para inicializar datos';

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Cargando estadísticas...';
    });

    try {
      final stats = await _employeeService.getEmployeeStats();
      setState(() {
        _stats = stats;
        _isLoading = false;
        _statusMessage = stats.isEmpty
            ? 'No hay empleados en la base de datos'
            : 'Estadísticas cargadas correctamente';
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = 'Error al cargar estadísticas: $e';
      });
    }
  }

  Future<void> _initializeSampleData() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Inicializando datos de ejemplo...';
    });

    try {
      await EmployeeDataImporter.initializeSampleData();
      await _loadStats();
      setState(() {
        _statusMessage = '✅ Datos de ejemplo inicializados correctamente';
      });

      _showSuccessDialog(
        'Datos inicializados',
        'Se han creado 5 empleados de ejemplo con sus horarios correspondientes.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error al inicializar datos: $e';
      });
      _showErrorDialog('Error', 'No se pudieron inicializar los datos: $e');
    }
  }

  Future<void> _validateDataIntegrity() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Validando integridad de datos...';
    });

    try {
      final results = await EmployeeDataImporter.validateDataIntegrity();
      setState(() {
        _isLoading = false;
        _statusMessage = 'Validación completada';
      });

      _showValidationResults(results);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error en validación: $e';
      });
    }
  }

  Future<void> _createMassiveData() async {
    final count = await _showNumberInputDialog();
    if (count == null || count <= 0) return;

    setState(() {
      _isLoading = true;
      _statusMessage = 'Creando $count empleados masivos...';
    });

    try {
      await EmployeeDataImporter.createMassiveEmployees(count);
      await _loadStats();
      setState(() {
        _statusMessage = '✅ Creados $count empleados masivos';
      });

      _showSuccessDialog(
        'Empleados creados',
        'Se han creado $count empleados masivos correctamente.',
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _statusMessage = '❌ Error al crear empleados: $e';
      });
    }
  }

  void _showSuccessDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.check_circle, color: Colors.green),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String title, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Text(title),
          ],
        ),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showValidationResults(Map<String, dynamic> results) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('🔍 Resultados de Validación'),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: results.entries.map((entry) {
              return Padding(
                padding: EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Icon(
                      entry.key.contains('error') ? Icons.error : Icons.info,
                      size: 16,
                      color: entry.key.contains('error')
                          ? Colors.red
                          : Colors.blue,
                    ),
                    SizedBox(width: 8),
                    Expanded(child: Text('${entry.key}: ${entry.value}')),
                  ],
                ),
              );
            }).toList(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cerrar'),
          ),
        ],
      ),
    );
  }

  Future<int?> _showNumberInputDialog() async {
    final controller = TextEditingController(text: '10');
    return showDialog<int>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Cantidad de Empleados'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            labelText: 'Número de empleados a crear',
            hintText: 'Ejemplo: 50',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              final value = int.tryParse(controller.text);
              Navigator.of(context).pop(value);
            },
            child: Text('Crear'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('👥 Administración de Empleados'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header con estado
            Container(
              width: double.infinity,
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.indigo[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.indigo[200]!),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.admin_panel_settings,
                    size: 48,
                    color: Colors.indigo,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'Panel de Administración',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo[800],
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    _statusMessage,
                    style: TextStyle(color: Colors.indigo[600], fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  if (_isLoading) ...[
                    SizedBox(height: 16),
                    CircularProgressIndicator(),
                  ],
                ],
              ),
            ),

            SizedBox(height: 24),

            // Estadísticas
            if (_stats.isNotEmpty) ...[
              Text(
                '📊 Estadísticas Actuales',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Wrap(
                  spacing: 16,
                  runSpacing: 8,
                  children: _stats.entries.map((entry) {
                    return Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.blue[300]!),
                      ),
                      child: Text(
                        '${entry.key}: ${entry.value}',
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: Colors.blue[800],
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              SizedBox(height: 24),
            ],

            // Acciones principales
            Text(
              '🛠️ Acciones Disponibles',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 12),

            // Botón: Inicializar datos de ejemplo
            _buildActionCard(
              icon: Icons.play_circle_filled,
              title: 'Inicializar Datos de Ejemplo',
              description:
                  'Crea 5 empleados con horarios para probar el sistema',
              color: Colors.green,
              onTap: _isLoading ? null : _initializeSampleData,
            ),

            SizedBox(height: 12),

            // Botón: Validar integridad
            _buildActionCard(
              icon: Icons.verified,
              title: 'Validar Integridad de Datos',
              description: 'Verifica que todos los empleados tengan horarios',
              color: Colors.orange,
              onTap: _isLoading ? null : _validateDataIntegrity,
            ),

            SizedBox(height: 12),

            // Botón: Crear empleados masivos
            _buildActionCard(
              icon: Icons.group_add,
              title: 'Crear Empleados Masivos',
              description: 'Simula importación masiva de empleados',
              color: Colors.purple,
              onTap: _isLoading ? null : _createMassiveData,
            ),

            SizedBox(height: 12),

            // Botón: Recargar estadísticas
            _buildActionCard(
              icon: Icons.refresh,
              title: 'Recargar Estadísticas',
              description: 'Actualiza los números mostrados arriba',
              color: Colors.blue,
              onTap: _isLoading ? null : _loadStats,
            ),

            SizedBox(height: 24),

            // Información adicional
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.amber[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.amber[800]),
                      SizedBox(width: 8),
                      Text(
                        'Información Importante',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.amber[800],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 8),
                  Text(
                    '• Los datos se guardan en Firebase Firestore\n'
                    '• Los empleados tienen IDs únicos (EMP001, EMP002, etc.)\n'
                    '• Cada empleado puede tener horarios por semana\n'
                    '• Los horarios se crean para la semana actual\n'
                    '• Puedes probar el login con los IDs creados',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.amber[700],
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String description,
    required Color color,
    required VoidCallback? onTap,
  }) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 24),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      description,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, color: Colors.grey[400], size: 16),
            ],
          ),
        ),
      ),
    );
  }
}
