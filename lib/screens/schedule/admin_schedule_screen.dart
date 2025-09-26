import 'package:flutter/material.dart';
import 'package:evelyn/services/local_schedule_service.dart';
import 'package:evelyn/models/schedule_model.dart';

class AdminScheduleScreen extends StatelessWidget {
  const AdminScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin - Horarios'),
        backgroundColor: const Color(0xFF179EDD),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Panel de Administración',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Esta pantalla es temporal para insertar datos de ejemplo. '
                      'En producción, esto se manejará desde tu aplicación web.',
                      style: TextStyle(fontSize: 14),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final scheduleService = LocalScheduleService();
                  await scheduleService.createSchedule(
                    ScheduleModel(
                      id: 'admin_schedule_${DateTime.now().millisecondsSinceEpoch}',
                      weekNumber: 1,
                      weekLabel:
                          'Semana del ${DateTime.now().day}/${DateTime.now().month}',
                      startDate: DateTime.now(),
                      endDate: DateTime.now().add(const Duration(days: 6)),
                      lastUpdated: DateTime.now(),
                      isActive: true,
                      shifts: [
                        ShiftModel(
                          day: 'Lunes',
                          startTime: '08:00',
                          endTime: '17:00',
                        ),
                        ShiftModel(
                          day: 'Martes',
                          startTime: '08:00',
                          endTime: '17:00',
                        ),
                        ShiftModel(
                          day: 'Miércoles',
                          startTime: '08:00',
                          endTime: '17:00',
                        ),
                        ShiftModel(
                          day: 'Jueves',
                          startTime: '08:00',
                          endTime: '17:00',
                        ),
                        ShiftModel(
                          day: 'Viernes',
                          startTime: '08:00',
                          endTime: '15:00',
                        ),
                        ShiftModel(
                          day: 'Sábado',
                          startTime: '09:00',
                          endTime: '13:00',
                        ),
                        ShiftModel(
                          day: 'Domingo',
                          startTime: 'Libre',
                          endTime: 'Libre',
                        ),
                      ],
                    ),
                  );
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Horario de ejemplo creado exitosamente'),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.add),
              label: const Text('Crear Horario de Ejemplo'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              onPressed: () async {
                try {
                  final scheduleService = LocalScheduleService();
                  // Crear múltiples horarios de ejemplo
                  for (int i = 1; i <= 3; i++) {
                    await scheduleService.createSchedule(
                      ScheduleModel(
                        id: 'admin_schedule_${i}_${DateTime.now().millisecondsSinceEpoch}',
                        weekNumber: i,
                        weekLabel:
                            'Semana ${i} - ${DateTime.now().day}/${DateTime.now().month}',
                        startDate: DateTime.now().add(
                          Duration(days: (i - 1) * 7),
                        ),
                        endDate: DateTime.now().add(
                          Duration(days: (i - 1) * 7 + 6),
                        ),
                        lastUpdated: DateTime.now(),
                        isActive: i == 1, // Solo el primero activo
                        shifts: [
                          ShiftModel(
                            day: 'Lunes',
                            startTime: '08:00',
                            endTime: '17:00',
                          ),
                          ShiftModel(
                            day: 'Martes',
                            startTime: '08:00',
                            endTime: '17:00',
                          ),
                          ShiftModel(
                            day: 'Miércoles',
                            startTime: '08:00',
                            endTime: '17:00',
                          ),
                          ShiftModel(
                            day: 'Jueves',
                            startTime: '08:00',
                            endTime: '17:00',
                          ),
                          ShiftModel(
                            day: 'Viernes',
                            startTime: '08:00',
                            endTime: '15:00',
                          ),
                          ShiftModel(
                            day: 'Sábado',
                            startTime: '09:00',
                            endTime: '13:00',
                          ),
                          ShiftModel(
                            day: 'Domingo',
                            startTime: 'Libre',
                            endTime: 'Libre',
                          ),
                        ],
                      ),
                    );
                  }
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text(
                          'Múltiples horarios creados exitosamente',
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Error: $e'),
                        backgroundColor: Colors.red,
                      ),
                    );
                  }
                }
              },
              icon: const Icon(Icons.list),
              label: const Text('Crear Múltiples Horarios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
            ),
            const SizedBox(height: 24),
            const Card(
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estructura de Datos en Firestore:',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '• Colección: schedules\n'
                      '• Documento: ID único\n'
                      '• Campos: weekNumber, weekLabel, startDate, endDate, lastUpdated, isActive, shifts\n'
                      '• Solo un horario puede estar activo (isActive: true)',
                      style: TextStyle(fontSize: 12, fontFamily: 'monospace'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Volver a Horarios'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF179EDD),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
