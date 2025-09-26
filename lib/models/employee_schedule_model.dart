import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:evelyn/models/work_day_model.dart';

class EmployeeScheduleModel {
  final String id;
  final String employeeId;
  final int weekNumber;
  final int year;
  final WorkDayModel monday;
  final WorkDayModel tuesday;
  final WorkDayModel wednesday;
  final WorkDayModel thursday;
  final WorkDayModel friday;
  final WorkDayModel saturday;
  final WorkDayModel sunday;
  final DateTime createdAt;
  final DateTime updatedAt;

  EmployeeScheduleModel({
    required this.id,
    required this.employeeId,
    required this.weekNumber,
    required this.year,
    required this.monday,
    required this.tuesday,
    required this.wednesday,
    required this.thursday,
    required this.friday,
    required this.saturday,
    required this.sunday,
    required this.createdAt,
    required this.updatedAt,
  });

  factory EmployeeScheduleModel.fromMap(Map<String, dynamic> map) {
    DateTime parseDate(dynamic value) {
      if (value is Timestamp) {
        return value.toDate();
      } else if (value is DateTime) {
        return value;
      } else if (value is String) {
        return DateTime.tryParse(value) ?? DateTime.now();
      } else {
        return DateTime.now();
      }
    }

    final schedule = map['schedule'] as Map<String, dynamic>? ?? {};

    return EmployeeScheduleModel(
      id: map['id'] ?? '',
      employeeId: map['employeeId'] ?? '',
      weekNumber: map['weekNumber'] ?? 1,
      year: map['year'] ?? DateTime.now().year,
      monday: WorkDayModel.fromMap(schedule['monday'] ?? {}),
      tuesday: WorkDayModel.fromMap(schedule['tuesday'] ?? {}),
      wednesday: WorkDayModel.fromMap(schedule['wednesday'] ?? {}),
      thursday: WorkDayModel.fromMap(schedule['thursday'] ?? {}),
      friday: WorkDayModel.fromMap(schedule['friday'] ?? {}),
      saturday: WorkDayModel.fromMap(schedule['saturday'] ?? {}),
      sunday: WorkDayModel.fromMap(schedule['sunday'] ?? {}),
      createdAt: parseDate(map['createdAt']),
      updatedAt: parseDate(map['updatedAt']),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'employeeId': employeeId,
      'weekNumber': weekNumber,
      'year': year,
      'schedule': {
        'monday': monday.toMap(),
        'tuesday': tuesday.toMap(),
        'wednesday': wednesday.toMap(),
        'thursday': thursday.toMap(),
        'friday': friday.toMap(),
        'saturday': saturday.toMap(),
        'sunday': sunday.toMap(),
      },
      'createdAt': createdAt,
      'updatedAt': updatedAt,
    };
  }

  // Crear horario estándar de trabajo (Lun-Vie 8:00-17:00, Sab-Dom libre)
  factory EmployeeScheduleModel.standardWorkWeek({
    required String employeeId,
    required int weekNumber,
    int? year,
    String startTime = '08:00',
    String endTime = '17:00',
  }) {
    final now = DateTime.now();
    return EmployeeScheduleModel(
      id: '', // Se asignará al guardar en Firestore
      employeeId: employeeId,
      weekNumber: weekNumber,
      year: year ?? now.year,
      monday: WorkDayModel.workDay(startTime: startTime, endTime: endTime),
      tuesday: WorkDayModel.workDay(startTime: startTime, endTime: endTime),
      wednesday: WorkDayModel.workDay(startTime: startTime, endTime: endTime),
      thursday: WorkDayModel.workDay(startTime: startTime, endTime: endTime),
      friday: WorkDayModel.workDay(startTime: startTime, endTime: endTime),
      saturday: WorkDayModel.dayOff(),
      sunday: WorkDayModel.dayOff(),
      createdAt: now,
      updatedAt: now,
    );
  }

  // Obtener día por nombre
  WorkDayModel getDayByName(String dayName) {
    switch (dayName.toLowerCase()) {
      case 'monday':
      case 'lunes':
        return monday;
      case 'tuesday':
      case 'martes':
        return tuesday;
      case 'wednesday':
      case 'miércoles':
      case 'miercoles':
        return wednesday;
      case 'thursday':
      case 'jueves':
        return thursday;
      case 'friday':
      case 'viernes':
        return friday;
      case 'saturday':
      case 'sábado':
      case 'sabado':
        return saturday;
      case 'sunday':
      case 'domingo':
        return sunday;
      default:
        return monday;
    }
  }

  // Obtener todos los días como lista
  List<WorkDayModel> getAllDays() {
    return [monday, tuesday, wednesday, thursday, friday, saturday, sunday];
  }

  // Obtener nombres de días en español
  static List<String> getDayNames() {
    return ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];
  }

  EmployeeScheduleModel copyWith({
    String? id,
    String? employeeId,
    int? weekNumber,
    int? year,
    WorkDayModel? monday,
    WorkDayModel? tuesday,
    WorkDayModel? wednesday,
    WorkDayModel? thursday,
    WorkDayModel? friday,
    WorkDayModel? saturday,
    WorkDayModel? sunday,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return EmployeeScheduleModel(
      id: id ?? this.id,
      employeeId: employeeId ?? this.employeeId,
      weekNumber: weekNumber ?? this.weekNumber,
      year: year ?? this.year,
      monday: monday ?? this.monday,
      tuesday: tuesday ?? this.tuesday,
      wednesday: wednesday ?? this.wednesday,
      thursday: thursday ?? this.thursday,
      friday: friday ?? this.friday,
      saturday: saturday ?? this.saturday,
      sunday: sunday ?? this.sunday,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'EmployeeScheduleModel(employeeId: $employeeId, week: $weekNumber/$year)';
  }
}
