class WorkDayModel {
  final String startTime;
  final String endTime;
  final bool isWorkDay;
  final String? notes;

  WorkDayModel({
    required this.startTime,
    required this.endTime,
    required this.isWorkDay,
    this.notes,
  });

  factory WorkDayModel.fromMap(Map<String, dynamic> map) {
    return WorkDayModel(
      startTime: map['startTime'] ?? '08:00',
      endTime: map['endTime'] ?? '17:00',
      isWorkDay: map['isWorkDay'] ?? true,
      notes: map['notes'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startTime': startTime,
      'endTime': endTime,
      'isWorkDay': isWorkDay,
      'notes': notes,
    };
  }

  // Crear día libre
  factory WorkDayModel.dayOff({String? notes}) {
    return WorkDayModel(
      startTime: '00:00',
      endTime: '00:00',
      isWorkDay: false,
      notes: notes ?? 'Día libre',
    );
  }

  // Crear día de trabajo estándar
  factory WorkDayModel.workDay({
    String startTime = '08:00',
    String endTime = '17:00',
    String? notes,
  }) {
    return WorkDayModel(
      startTime: startTime,
      endTime: endTime,
      isWorkDay: true,
      notes: notes,
    );
  }

  WorkDayModel copyWith({
    String? startTime,
    String? endTime,
    bool? isWorkDay,
    String? notes,
  }) {
    return WorkDayModel(
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      isWorkDay: isWorkDay ?? this.isWorkDay,
      notes: notes ?? this.notes,
    );
  }

  @override
  String toString() {
    if (!isWorkDay) return 'Día libre';
    return '$startTime - $endTime';
  }
}
