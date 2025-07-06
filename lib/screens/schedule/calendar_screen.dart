import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/widgets/bottom_nav_bar.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedDay = DateTime.now();
  int _selectedDay = DateTime.now().day;

  List<Map<String, String>> get _eventsForSelectedDay {
    // Ejemplo de eventos fijos para el día 15
    if (_selectedDay == 15) {
      return [
        {
          'title': 'Team Meeting',
          'time': '9:00 AM - 12:00 PM',
          'icon': 'users',
        },
        {
          'title': 'Project Review',
          'time': '1:00 PM - 3:00 PM',
          'icon': 'presentation',
        },
        {'title': 'Client Call', 'time': '3:30 PM - 5:00 PM', 'icon': 'phone'},
      ];
    }
    return [];
  }

  void _goToPreviousMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month - 1, 1);
      _selectedDay = 1;
    });
  }

  void _goToNextMonth() {
    setState(() {
      _focusedDay = DateTime(_focusedDay.year, _focusedDay.month + 1, 1);
      _selectedDay = 1;
    });
  }

  @override
  Widget build(BuildContext context) {
    final daysInMonth = DateUtils.getDaysInMonth(
      _focusedDay.year,
      _focusedDay.month,
    );
    final firstWeekday =
        DateTime(_focusedDay.year, _focusedDay.month, 1).weekday % 7;
    final monthName = DateFormat('MMMM yyyy', 'es').format(_focusedDay);
    final weekDays = ['D', 'L', 'M', 'M', 'J', 'V', 'S'];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Schedule',
          style: TextStyle(
            color: Color(0xFF111418),
            fontWeight: FontWeight.bold,
            fontSize: 18,
            letterSpacing: -0.5,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF111418)),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 8),
            // Selector de mes
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_left,
                      color: Color(0xFF111418),
                    ),
                    onPressed: _goToPreviousMonth,
                  ),
                  Expanded(
                    child: Center(
                      child: Text(
                        toBeginningOfSentenceCase(monthName)!,
                        style: const TextStyle(
                          color: Color(0xFF111418),
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.chevron_right,
                      color: Color(0xFF111418),
                    ),
                    onPressed: _goToNextMonth,
                  ),
                ],
              ),
            ),
            // Días de la semana
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: weekDays
                    .map(
                      (d) => Expanded(
                        child: Center(
                          child: Text(
                            d,
                            style: const TextStyle(
                              color: Color(0xFF111418),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            // Grid de días
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 7,
                  mainAxisSpacing: 0,
                  crossAxisSpacing: 0,
                  childAspectRatio: 1,
                ),
                itemCount: daysInMonth + firstWeekday,
                itemBuilder: (context, index) {
                  if (index < firstWeekday) {
                    return const SizedBox();
                  }
                  final day = index - firstWeekday + 1;
                  final isSelected = day == _selectedDay;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedDay = day;
                      });
                    },
                    child: Container(
                      margin: const EdgeInsets.all(2),
                      decoration: isSelected
                          ? const BoxDecoration(
                              color: Color(0xFF0c7ff2),
                              shape: BoxShape.circle,
                            )
                          : null,
                      child: Center(
                        child: Text(
                          '$day',
                          style: TextStyle(
                            color: isSelected
                                ? Colors.white
                                : const Color(0xFF111418),
                            fontWeight: FontWeight.w500,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            // Eventos del día seleccionado
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  '${DateFormat('EEEE, d MMMM', 'es').format(DateTime(_focusedDay.year, _focusedDay.month, _selectedDay))}',
                  style: const TextStyle(
                    color: Color(0xFF111418),
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),
              ),
            ),
            ..._eventsForSelectedDay.map((event) => _EventTile(event: event)),
            const SizedBox(height: 16),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavBar(
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushNamed(context, '/home');
          } else if (index == 1) {
            // Ya estamos en Calendar
          } else if (index == 2) {
            Navigator.pushNamed(context, '/productos');
          }
        },
      ),
    );
  }
}

class _EventTile extends StatelessWidget {
  final Map<String, String> event;
  const _EventTile({required this.event});

  IconData get _icon {
    switch (event['icon']) {
      case 'users':
        return Icons.group;
      case 'presentation':
        return Icons.present_to_all;
      case 'phone':
        return Icons.phone;
      default:
        return Icons.event;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F5),
              borderRadius: BorderRadius.circular(8),
            ),
            width: 48,
            height: 48,
            child: Icon(_icon, color: const Color(0xFF111418), size: 28),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event['title']!,
                  style: const TextStyle(
                    color: Color(0xFF111418),
                    fontWeight: FontWeight.w500,
                    fontSize: 16,
                  ),
                ),
                Text(
                  event['time']!,
                  style: const TextStyle(
                    color: Color(0xFF60758a),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
