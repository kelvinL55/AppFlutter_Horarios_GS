import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';
import 'package:flutter_application_1/services/schedule_service.dart';
import 'package:flutter_application_1/models/schedule_model.dart';
import 'package:intl/intl.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ScheduleService _scheduleService = ScheduleService();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF111418)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Horario',
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<ScheduleModel?>(
        stream: _scheduleService.getCurrentSchedule(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF179EDD)),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar horarios',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Verifica tu conexión a internet',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          final schedule = snapshot.data;

          if (schedule == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.schedule_outlined,
                    size: 64,
                    color: Color(0xFF60758a),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay horarios disponibles',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Los horarios se cargarán próximamente',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header con información de la semana
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: const Color(0xFFf8f9fa),
                  borderRadius: BorderRadius.circular(12),
                ),
                margin: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            'Semana Actual',
                            style: const TextStyle(
                              color: Color(0xFF111418),
                              fontWeight: FontWeight.bold,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFF179EDD),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'Semana ${schedule.weekNumber}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      schedule.weekLabel,
                      style: const TextStyle(
                        color: Color(0xFF60758a),
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(
                          Icons.update,
                          size: 16,
                          color: Color(0xFF179EDD),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Actualizado: ${DateFormat('dd/MM/yyyy HH:mm').format(schedule.lastUpdated)}',
                          style: const TextStyle(
                            color: Color(0xFF60758a),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Lista de horarios
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: ListView.separated(
                    itemCount: schedule.shifts.length,
                    separatorBuilder: (context, index) =>
                        const Divider(height: 1, color: Color(0xFFdbe0e6)),
                    itemBuilder: (context, index) {
                      final shift = schedule.shifts[index];
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 16,
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Text(
                                shift.day,
                                style: const TextStyle(
                                  color: Color(0xFF60758a),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                            Expanded(
                              flex: 3,
                              child: Text(
                                shift.formattedTime,
                                style: const TextStyle(
                                  color: Color(0xFF111418),
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                                textAlign: TextAlign.end,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Botón para ir al calendario
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/calendar');
                        },
                        icon: const Icon(Icons.calendar_month),
                        label: const Text('Ver Calendario'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          backgroundColor: const Color(0xFF179EDD),
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    // Botón temporal de administración (solo para desarrollo)
                    // En producción, esto se mostraría solo para administradores
                    Center(
                      child: TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/admin-schedule');
                        },
                        icon: const Icon(Icons.admin_panel_settings, size: 16),
                        label: const Text('Admin (Desarrollo)'),
                        style: TextButton.styleFrom(
                          foregroundColor: const Color(0xFF60758a),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // Ya estamos en Schedule
          } else if (index == 2) {
            Navigator.pushNamed(context, '/productos');
          }
        },
      ),
    );
  }
}
