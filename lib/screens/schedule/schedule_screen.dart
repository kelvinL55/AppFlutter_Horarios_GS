import 'package:flutter/material.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';

class ScheduleScreen extends StatelessWidget {
  const ScheduleScreen({super.key});

  static const List<Map<String, String>> _weekSchedule = [
    {'day': 'Sábado', 'hours': '8 AM - 5 PM'},
    {'day': 'Domingo', 'hours': '9 AM - 6 PM'},
    {'day': 'Lunes', 'hours': '10 AM - 7 PM'},
    {'day': 'Martes', 'hours': '11 AM - 8 PM'},
    {'day': 'Miércoles', 'hours': '12 PM - 9 PM'},
    {'day': 'Jueves', 'hours': '1 PM - 10 PM'},
    {'day': 'Viernes', 'hours': '2 PM - 11 PM'},
  ];

  @override
  Widget build(BuildContext context) {
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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 20, 16, 8),
            child: Text(
              'Semana actual',
              style: TextStyle(
                color: Color(0xFF111418),
                fontWeight: FontWeight.bold,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.count(
                crossAxisCount: 2,
                childAspectRatio: 2.8,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                children: List.generate(_weekSchedule.length, (index) {
                  final item = _weekSchedule[index];
                  return Container(
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Color(0xFFdbe0e6), width: 1),
                        right: index % 2 == 0
                            ? BorderSide(color: Colors.transparent)
                            : BorderSide(color: Color(0xFFdbe0e6), width: 0),
                      ),
                      color: Colors.white,
                    ),
                    padding: EdgeInsets.only(
                      left: index % 2 == 0 ? 16 : 8,
                      right: index % 2 == 0 ? 8 : 16,
                      top: 16,
                      bottom: 16,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          item['day']!,
                          style: const TextStyle(
                            color: Color(0xFF60758a),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item['hours']!,
                          style: const TextStyle(
                            color: Color(0xFF111418),
                            fontSize: 14,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                      ],
                    ),
                  );
                }),
              ),
            ),
          ),
          // Botón para ir al calendario
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
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
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
