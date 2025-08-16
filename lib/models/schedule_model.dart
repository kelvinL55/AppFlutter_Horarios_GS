import 'package:cloud_firestore/cloud_firestore.dart';

class ScheduleModel {
  final String id;
  final int weekNumber;
  final String weekLabel;
  final DateTime startDate;
  final DateTime endDate;
  final DateTime lastUpdated;
  final bool isActive;
  final List<ShiftModel> shifts;

  ScheduleModel({
    required this.id,
    required this.weekNumber,
    required this.weekLabel,
    required this.startDate,
    required this.endDate,
    required this.lastUpdated,
    required this.isActive,
    required this.shifts,
  });

  factory ScheduleModel.fromMap(Map<String, dynamic> map, String id) {
    return ScheduleModel(
      id: id,
      weekNumber: map['weekNumber'] ?? 0,
      weekLabel: map['weekLabel'] ?? '',
      startDate: (map['startDate'] as Timestamp).toDate(),
      endDate: (map['endDate'] as Timestamp).toDate(),
      lastUpdated: (map['lastUpdated'] as Timestamp).toDate(),
      isActive: map['isActive'] ?? false,
      shifts: List<ShiftModel>.from(
        (map['shifts'] ?? []).map((x) => ShiftModel.fromMap(x)),
      ),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'weekNumber': weekNumber,
      'weekLabel': weekLabel,
      'startDate': Timestamp.fromDate(startDate),
      'endDate': Timestamp.fromDate(endDate),
      'lastUpdated': Timestamp.fromDate(lastUpdated),
      'isActive': isActive,
      'shifts': shifts.map((x) => x.toMap()).toList(),
    };
  }
}

class ShiftModel {
  final String day;
  final String startTime;
  final String endTime;
  final String? breakStart;
  final String? breakEnd;

  ShiftModel({
    required this.day,
    required this.startTime,
    required this.endTime,
    this.breakStart,
    this.breakEnd,
  });

  factory ShiftModel.fromMap(Map<String, dynamic> map) {
    return ShiftModel(
      day: map['day'] ?? '',
      startTime: map['startTime'] ?? '',
      endTime: map['endTime'] ?? '',
      breakStart: map['breakStart'],
      breakEnd: map['breakEnd'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'day': day,
      'startTime': startTime,
      'endTime': endTime,
      'breakStart': breakStart,
      'breakEnd': breakEnd,
    };
  }

  String get formattedTime {
    if (breakStart != null && breakEnd != null) {
      return '$startTime - $endTime (Descanso: $breakStart - $breakEnd)';
    }
    return '$startTime - $endTime';
  }
}
